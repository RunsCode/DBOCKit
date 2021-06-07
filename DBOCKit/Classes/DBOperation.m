//
//  DBOperation.m
//  Object_C_Advance
//
//  Created by WangYajun on 2021/4/26.
//  Copyright © 2021 王亚军. All rights reserved.
//

#import <fmdb/FMDB.h>
#import "DBFile.h"
#import "DBOperation.h"
#import "DBOperaterProtocol.h"
#import "DBObserverProtocol.h"
#import "DBObjectProtocol.h"
#import "NSObject+DBObj.h"

@interface DBOperation () <DBOperaterProtocol>

@property (nonatomic, copy) NSString *fileName;

@property (nonatomic, copy) NSString *fileDirctory;

@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

@property (nonatomic, strong) NSMapTable<Class, NSHashTable<DBObserverProtocol> *> *observerMap;

@end

@implementation DBOperation

#ifdef DEBUG
- (void)dealloc {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}
#endif

- (instancetype)initWithDBName:(NSString *)name directory:(NSString *)dir {
    self = [super init];
    if (self) {
        _fileName = name;
        _fileDirctory = dir;
    }
    return self;
}

- (BOOL)existsTableWithName:(NSString *)name {
    if (name.length <= 0) {
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
    if (sql.length <= 0) {
        return res;
    }
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        res = [db executeUpdate:sql];
    }];
    return res;
}

- (BOOL)executeWithSql:(NSString *)sql objClass:(Class<DBObjectProtocol>)cls {
    if (sql.length <= 0) {
        return NO;
    }
    __block BOOL res = NO;
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        res = [db executeUpdate:sql];
    }];
    return YES;
}

- (BOOL)updateSql:(NSString *)sql observable:(id<DBObserverProtocol>)obj {
    if (sql.length <= 0) {
        return NO;
    }
    __block BOOL res = NO;
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        res = [db executeUpdate:sql];
    }];
    if (res) {
        [self fireEventWithObj:obj];
    }
    return res;
}

- (NSArray<NSDictionary<NSString *, id> *> *)selectWithSql:(NSString *)sql {
    if (sql.length <= 0) {
        return nil;
    }
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:8];
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        FMResultSet *resultSet = [db executeQuery:sql];
        while (resultSet.next) {
            if (resultSet.resultDictionary) {
                [results addObject:resultSet.resultDictionary];
            }
        }
    }];
    return results;
}

- (NSArray<DBObjectProtocol> *)selectWithSql:(NSString *)sql objClass:(Class<DBObjectProtocol>)cls {
    NSArray<NSDictionary *> *results = [self selectWithSql:sql];
    if (results.count <= 0) {
        return nil;
    }
    NSArray *resultObjArray = [cls dbocObjArrayWithArrayJsonMap:results];
    return resultObjArray;
}

- (NSInteger)countWithSql:(NSString *)sql {
    if (sql.length <= 0) {
        return 0;
    }
    __block NSUInteger count = 0;
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        FMResultSet *res = [db executeQuery:sql];
        count = [res longForColumnIndex:0];
    }];
    return count;
}

#pragma mark -- private method

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

- (void)fireEventWithObj:(id)obj {
    Class cls = [obj class];
    if (!cls) return;
    //
    NSHashTable *t = [self.observerMap objectForKey:cls];
    for (id<DBObserverProtocol> observer in t) {
        [observer updateClass:cls withObj:obj];
    }
}

#pragma mark -- observer

- (void)addObserver:(id<DBObserverProtocol>)observer {
    if (!observer) return;
    //
    NSArray<Class> *arr = [observer observeObjClassArray];
    if (arr.count <= 0) return;
    //
    for (Class cls in arr) {
        NSHashTable *t = [self.observerMap objectForKey:cls];
        if (!t) {
            t = [NSHashTable weakObjectsHashTable];
            [self.observerMap setObject:(NSHashTable<DBObserverProtocol> *)t forKey:cls];
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
        NSHashTable *t = [self.observerMap objectForKey:cls];
        if (!t) continue;
        //
        [t removeObject:observer];
        if (t.count <= 0) {
            [self.observerMap removeObjectForKey:cls];
        }
    }
}

#pragma mark -- getter

- (FMDatabaseQueue *)dbQueue {
    if (_dbQueue) return _dbQueue;
    //
    NSString *path = [DBFile pathWithName:_fileName directory:_fileDirctory];
    _dbQueue = [[FMDatabaseQueue alloc] initWithPath:path];
    return _dbQueue;
}

- (NSMapTable<Class, NSHashTable<DBObserverProtocol> *> *)observerMap {
    if (_observerMap) return _observerMap;
    //
    _observerMap = [NSMapTable weakToWeakObjectsMapTable];
    return _observerMap;
}

@end
