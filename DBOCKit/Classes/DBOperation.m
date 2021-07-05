//
//  DBOperation.m
//  Object_C_Advance
//
//  Created by WangYajun on 2021/4/26.
//  Copyright © 2021 王亚军. All rights reserved.
//
#import "DBOCKit.h"
#import <fmdb/FMDB.h>
#import "DBFile.h"
#import "DBOperation.h"
#import "DBOperatorProtocol.h"
#import "DBObserverProtocol.h"
#import "DBObjectProtocol.h"
#import "NSObject+DBObj.h"
#import "NSString+DBOCCTool.h"
#import "DBSqlObject.h"

@interface DBOperation () <DBOperatorProtocol>

@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

@property (nonatomic, strong) NSMapTable<NSString *, NSHashTable<DBObserverProtocol> *> *observerMap;

@end

@implementation DBOperation

#ifdef DEBUG
- (void)dealloc {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}
#endif

- (instancetype)initWithDBURL:(NSURL *)url {
    self = [super init];
    if (self) {
        NSAssert(nil != url, @"DBCO Error init db with url, due to url: %@ is nil", url);
        _dbQueue = [[FMDatabaseQueue alloc] initWithURL:url];
    }
    return self;
}

- (instancetype)initWithDBPath:(NSString *)path {
    self = [super init];
    if (self) {
        NSAssert(!isAbnormalString(path), @"DBCO Error init db with path, due to path: %@ is illegal", path);
        _dbQueue = [[FMDatabaseQueue alloc] initWithPath:path];
    }
    return self;
}

- (instancetype)initWithDBName:(NSString *)name directory:(NSString *)dir {
    self = [super init];
    if (self) {
        NSString *path = [DBFile pathWithName:name directory:dir];
        NSAssert(!isAbnormalString(path), @"DBCO Error initWithDBName, due to path is illegal that maybe name: %@, or dir: %@ is illagal", name, dir);
        _dbQueue = [[FMDatabaseQueue alloc] initWithPath:path];
    }
    return self;
}

- (BOOL)existsTableWithName:(NSString *)name {
    if (isAbnormalString(name)) {
        return NO;
    }
    __block BOOL res = NO;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        res = [db tableExists:name];
    }];
    return res;
}

- (BOOL)createTableWithObjClass:(Class<DBObjectProtocol>)cls {
    NSString *tableName = [cls dbocTableName];
    BOOL isExists = [self existsTableWithName:tableName];
    __block BOOL res = NO;
    if (isExists) {
        return [self tryAlterTableWithObjClass:cls];
    }
    NSString *sql = [cls dbocDefaultCreateTableSql];
    if (isAbnormalString(sql)) {
        return res;
    }
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        NSError *err = nil;
        res = [db executeUpdate:sql withErrorAndBindings:&err];
        if (err) NSLog(@"DBOC Create Error: %@, sql: %@", err, sql);
    }];
    return res;
}

- (BOOL)executeWithSql:(NSString *)sql {
    if (isAbnormalString(sql)) {
        return NO;
    }
    __block BOOL res = NO;
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        NSError *err = nil;
        res = [db executeUpdate:sql withErrorAndBindings:&err];
        if (err) NSLog(@"DBOC Execute Error: %@, sql: %@", err, sql);
    }];
    if (res) {
        [self shouldTriggerObserverWithSql:sql];
    }
    return res;
}

- (BOOL)updateSql:(NSString *)sql observable:(id<DBObjectProtocol>)obj {
    if (isAbnormalString(sql)) {
        return NO;
    }
    __block BOOL res = NO;
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        NSError *err = nil;
        res = [db executeUpdate:sql withErrorAndBindings:&err];
        if (err) NSLog(@"DBOC Update Error: %@, sql: %@", err, sql);
    }];
    if (res) {
        sql = sql.uppercaseString;
        if ([sql containsString:@"UPDATE"]) {
            [self fireUpdateEventWithTable:obj.class.dbocTableName obj:obj];
        } else {
            [self fireInsertOrDeleteEventWithTable:obj.class.dbocTableName obj:obj];
        }
    }
    return res;
}

- (NSArray<NSDictionary<NSString *, id> *> *)selectWithSql:(NSString *)sql {
    if (isAbnormalString(sql)) {
        return nil;
    }
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:8];
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        NSError *err = nil;
        FMResultSet *resultSet = [db executeQuery:sql values:nil error:&err];
        if (err) NSLog(@"DBOC Query Error: %@, sql: %@", err, sql);
        while (resultSet.next) {
            if (resultSet.resultDictionary) {
                [results addObject:resultSet.resultDictionary];
            }
        }
    }];
    return results;
}

- (NSUInteger)countWithSql:(NSString *)sql {
    if (isAbnormalString(sql)) {
        return 0;
    }
    __block NSUInteger count = 0;
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        NSError *err = nil;
        FMResultSet *res = [db executeQuery:sql values:nil error:&err];
        if (err) NSLog(@"DBOC Query Error: %@, sql: %@", err, sql);
        while (res.next) {
            count = [res longForColumnIndex:0];
            //NSLog(@"count = %lu", (unsigned long)count);
        }
    }];
    return count;
}

- (NSUInteger)countOfTable:(NSString *)tName {
    if (isAbnormalString(tName)) {
        return 0;
    }
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@", tName];
    return [self countWithSql:sql];
}

#pragma mark -- Convenience methods

- (BOOL)insertOrUpdateObj:(id<DBObjectProtocol>)obj {
    if (obj.primaryKeyId <= 0) {
        return [self insertObj:obj];
    }
    return [self udpateObj:obj];
}

- (BOOL)deleteObj:(id<DBObjectProtocol>)obj {
    if (!obj) {
        return NO;
    }
    NSString *tName = [obj.class dbocTableName];
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE primaryKeyId='%lu'", tName, obj.primaryKeyId];
    __block BOOL res = NO;
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        NSError *err = nil;
        res = [db executeUpdate:sql withErrorAndBindings:&err];
        if (err) {
            NSLog(@"DBOC DELETE Occured Error. while primaryKeyId: %lu", obj.primaryKeyId);
        }
    }];
    if (res) {
        [self fireInsertOrDeleteEventWithTable:tName obj:obj];
    }
    return res;
}

- (NSArray<DBObjectProtocol> *)fecthWithClass:(Class<DBObjectProtocol>)cls {
    NSString *tableName = [cls dbocTableName];
    if (isAbnormalString(tableName)) {
        return nil;
    }

    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@", tableName];
    NSArray<NSDictionary *> *results = [self selectWithSql:sql];
    if (results.count <= 0) {
        return nil;
    }
    NSArray *resultObjArray = [cls dbocObjArrayWithArrayJsonMap:results];
    return resultObjArray;
}

- (BOOL)insertOrUpdateObjs:(NSArray<DBObjectProtocol> *)objs {
    if (objs.count <= 0) {
        return NO;
    }
    for (id obj in objs) {
        BOOL res = [self insertOrUpdateObj:obj];
        if (!res) {
            return res;
        }
    }
    return YES;
}

- (BOOL)deleteObjs:(NSArray<DBObjectProtocol> *)objs {
    if (objs.count <= 0) {
        return NO;
    }
    for (id obj in objs) {
        BOOL res = [self deleteObj:obj];
        if (!res) {
            return res;
        }
    }
    return YES;
}

#pragma mark -- observer

- (void)addObserver:(id<DBObserverProtocol>)observer {
    if (!observer) return;
    //
    NSArray<Class> *arr = [observer observeObjClassArray];
    if (arr.count <= 0) return;
    //
    for (Class cls in arr) {
        NSString *tName = cls.dbocTableName.uppercaseString;
        NSHashTable *t = [self.observerMap objectForKey:tName];
        if (!t) {
            t = [NSHashTable weakObjectsHashTable];
            [self.observerMap setObject:(NSHashTable<DBObserverProtocol> *)t forKey:tName];
        }
        if ([t containsObject:observer]) continue;
        //
        [t addObject:observer];
    }
}

- (void)removeObserver:(id<DBObserverProtocol>)observer {
    if (!observer) return;
    //
    NSArray<Class> *arr = [observer observeObjClassArray];
    if (arr.count <= 0) return;
    //
    for (Class cls in arr) {
        NSString *tName = cls.dbocTableName.uppercaseString;
        NSHashTable *t = [self.observerMap objectForKey:tName];
        if (!t) continue;
        //
        [t removeObject:observer];
        if (t.count <= 0) {
            [self.observerMap removeObjectForKey:tName];
        }
    }
}

#pragma mark -- private method

- (BOOL)insertObj:(id<DBObjectProtocol>)obj {
    DBSqlObject *sqlObj = [obj dbocInsertSqlObj];
    if (isAbnormalString(sqlObj.sql) || sqlObj.values.count <= 0) {
        NSLog(@"DBOC INSERT Occured Error. Maybe `values` is empty or sql: %@", sqlObj.sql);
        return NO;
    }
    __block BOOL res = NO;
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        NSError *err = nil;
        res = [db executeUpdate:sqlObj.sql values:sqlObj.values error:&err];
        if (!res || err) {
            NSLog(@"DBOC INSERT Failed, sql: %@, error: %@", sqlObj.sql, err);
            return;
        }
        obj.primaryKeyId = db.lastInsertRowId;
    }];
    if (res) {
        [self fireInsertOrDeleteEventWithTable:obj.class.dbocTableName obj:obj];
    }
    return res;
}

- (BOOL)udpateObj:(id<DBObjectProtocol>)obj {
    DBSqlObject *sqlObj = [obj dbocUpdateSqlObj];
    if (isAbnormalString(sqlObj.sql) || sqlObj.values.count <= 0) {
        NSLog(@"DBOC UPDATE Occured Error. Maybe `values` is empty or sql: %@", sqlObj.sql);
        return NO;
    }
    __block BOOL res = NO;
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        NSError *err = nil;
        res = [db executeUpdate:sqlObj.sql values:sqlObj.values error:&err];
        if (!res || err) {
            NSLog(@"DBOC UPDATE Failed, sql: %@, error: %@", sqlObj.sql, err);
        }
    }];
    if (res) {
        [self fireUpdateEventWithTable:obj.class.dbocTableName obj:obj];
    }
    return res;
}

- (id<DBObjectProtocol>)objWithJsonString:(NSString *)jsonString cls:(Class<DBObjectProtocol>)cls {
    return [cls dbocObjWithJsonString:jsonString];
}

- (BOOL)tryAlterTableWithObjClass:(Class<DBObjectProtocol>)cls {
    __block BOOL res = NO;
    NSString *tableName = [cls dbocTableName];
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        NSMutableSet *columnSet = [NSMutableSet setWithCapacity:4];
        FMResultSet *resultSet = [db getTableSchema:tableName];
        while (resultSet.next) {
            NSString *column = [resultSet stringForColumn:@"name"];
            if (column.length <= 0 ) continue;
            [columnSet addObject:column];
        }
        // 利用Set去重 然后进行alter
        NSDictionary<NSString *, NSString *> *map = [cls dbocPropertyMap];
        NSMutableSet *propertyNameSet = [NSMutableSet setWithArray:map.allKeys];
        [propertyNameSet minusSet:columnSet];
        NSSet *ignoreSet = [cls dbocIgnoreFields];
        [propertyNameSet minusSet:ignoreSet];
        //
        NSSet<NSString *> *sqlSet = [cls dbocAlterTableSqlSetWithFields:propertyNameSet];
        for (NSString *sql in sqlSet) {
            res = [db executeUpdate:sql];
            if (!res) {
                *rollback = YES;
                return;
            }
        }
    }];
    return res;
}

- (void)shouldTriggerObserverWithSql:(NSString *)sql {
    if (isAbnormalString(sql)) {
        return;
    }
    sql = [sql uppercaseString];
    NSArray<NSString *> *tNameArr = [sql componentsSeparatedByString:@" "];
    if ([sql containsString:@"UPDATE"]) {
        if (tNameArr.count > 2) {
            NSString *tName = tNameArr[1];
            [self fireUpdateEventWithTable:tName obj:nil];
        }
        return;
    }
    if ([sql containsString:@"INSERT"] || [sql containsString:@"DELETE"]) {
        if (tNameArr.count > 3) {
            NSString *tName = tNameArr[2];
            [self fireInsertOrDeleteEventWithTable:tName obj:nil];
        }
    }
}

- (void)fireUpdateEventWithTable:(NSString *)tName obj:(id<DBObjectProtocol> _Nullable)obj {
    if (isAbnormalString(tName)) {
        return;
    }
    tName = [tName uppercaseString];
    NSHashTable *t = [self.observerMap objectForKey:tName];
    for (id<DBObserverProtocol> observer in t) {
        [observer updateClass:obj.class withObj:obj];
    }
}

- (void)fireInsertOrDeleteEventWithTable:(NSString *)tName obj:(id<DBObjectProtocol> _Nullable)obj {
    if (isAbnormalString(tName)) {
        return;
    }
    tName = [tName uppercaseString];
    NSUInteger count = [self countOfTable:tName];
    NSHashTable *t = [self.observerMap objectForKey:tName];
    for (id<DBObserverProtocol> observer in t) {
        [observer updateTable:tName withObj:obj newTableCount:count];
    }
}

#pragma mark -- getter

- (NSMapTable<NSString *, NSHashTable<DBObserverProtocol> *> *)observerMap {
    if (_observerMap) return _observerMap;
    //
    _observerMap = [NSMapTable strongToStrongObjectsMapTable];
    return _observerMap;
}

@end
