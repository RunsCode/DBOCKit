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

@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

@property (nonatomic, strong) NSMapTable<Class, NSHashTable<DBObserverProtocol> *> *observerMap;

@end

@implementation DBOperation

#ifdef DEBUG
- (void)dealloc {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}
#endif

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
    NSString *tableName = [cls dboc_tableName];
    BOOL isExists = [self existsTableWithName:tableName];
    __block BOOL res = YES;
    if (isExists) {
        // check and alert
        return res;
    }
    NSString *sql = [cls dboc_defaultCreateTableSql];
    if (sql.length <= 0) {
        return res;
    }
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        res = [db executeUpdate:sql];
    }];
    return res;
}

- (BOOL)executeWithSql:(NSString *)sql objClass:(Class<DBObjectProtocol>)cls {
    return YES;
}

- (BOOL)updateSql:(NSString *)sql observable:(id<DBObserverProtocol>)obj {

    /// fire event when over update
    [self fireEventWithObj:obj];
    return YES;
}

- (NSArray *)selectWithSql:(NSString *)sql objClass:(Class<DBObjectProtocol>)cls {
    return @[];
}

- (NSInteger)countWithSql:(NSString *)sql {
    return 0;
}

#pragma mark -- private method

- (BOOL)tryAlterTableWithObjClass:(Class<DBObjectProtocol>)cls {
    __block BOOL res = YES;
    NSString *tableName = [cls dboc_tableName];
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        NSMutableSet *columnSet = [NSMutableSet setWithCapacity:4];
        FMResultSet *resultSet = [db getTableSchema:tableName];
        while (resultSet.next) {
            NSString *column = [resultSet stringForColumn:@"name"];
            if (column.length <= 0 ) continue;
            [columnSet addObject:column];
        }
        //
        NSDictionary<NSString *, NSString *> *map = [cls dboc_propertyMap];
        NSMutableSet *propertyNameSet = [NSMutableSet setWithArray:map.allKeys];
        [propertyNameSet minusSet:columnSet];
        //

        NSSet<NSString *> *sqlSet = [cls dboc_alterTableSqlSetWithFields:propertyNameSet];
        for (NSString *sql in sqlSet) {
            if (![db executeUpdate:sql]) {
                res = NO;
                *rollback = YES;
                return;
            }
        }
        res = sqlSet.count > 0 ? res : NO;
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
    NSString *path = [DBFile pathWithName:nil directory:nil];
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
