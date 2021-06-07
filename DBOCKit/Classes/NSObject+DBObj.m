//
//  NSObject+DBObj.m
//  DBOCKit
//
//  Created by WangYajun on 2021/6/4.
//

#import <objc/runtime.h>
#import <MJExtension/MJExtension.h>
#include "string_common.h"
#import "NSObject+DBObj.h"
//#import "DBObjectProtocol.h"

//@interface NSObject ()//<DBObjectProtocol>
//
//@end

@implementation NSObject (DBObj)

+ (NSArray<NSString *> *)dboc_ignoreFields {
    NSMutableSet *mutable = [NSMutableSet setWithObjects:@"hash", @"superclass", @"description", @"debugDescription", nil];
    if ([self respondsToSelector:@selector(ignoreTheFields)]) {
        NSArray *res = [self ignoreTheFields];
        if (res) {
            [mutable addObjectsFromArray:res];
        }
    }
    return mutable.allObjects;
}

+ (NSString *)dbocDefaultCreateTableSql {
    NSString *table = [self dbocTableName];
    //
    unsigned int countOfProperty = 0;
    objc_property_t *propertyPtr = class_copyPropertyList(self.class, &countOfProperty);
    const char *prefix = "CREATE TABLE IF NOT EXISTS ";
    const char *pkSql = "( pk INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL DEFAULT(0)";

    char buffer[1024] = {0};
    MutableMemoryCopyDest(buffer, prefix, table.UTF8String, pkSql, NULL);
    //
    NSArray<NSString *> *ignoreFields = [self dboc_ignoreFields];
    for (int i = 0; i < countOfProperty; i++) {
        objc_property_t property = propertyPtr[i];
        //
        const char *field = property_getName(property);
        NSString *ocField = [NSString stringWithCString:field encoding:NSUTF8StringEncoding];
        if ([ignoreFields containsObject:ocField]) {
            continue;
        }

        const char *type = property_getAttributes(property);
        const char *dbType = [self dboc_dbTypeWithPropertyType:type];
        MutableMemoryCopyDest(buffer,  ", ", field, " ", dbType, NULL);
    }
    MutableMemoryCopyDest(buffer, ");", NULL);
    NSLog(@"buffer length : %lu", strlen(buffer));
    //
    free(propertyPtr);
    return [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
}

+ (NSSet<NSString *> *)dbocAlterTableSqlSetWithFields:(NSSet<NSString *> *)fields {
    if (fields.count <= 0) {
        return nil;
    }
    const char *prefix = "ALTER TABLE ";
    const char *addColumnSql = "ADD COLUMN ";
    const char *tName = self.dbocTableName.UTF8String;

    NSMutableSet *set = [NSMutableSet setWithCapacity:fields.count];
    for (NSString *field in fields) {
        char buffer[1024] = {0};
        NSString *ocDBType = st_propertyMap[field];
        MutableMemoryCopyDest(buffer, prefix, tName, " ", addColumnSql, field, " ", ocDBType, ";",NULL);
        NSString *res = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
        if (res.length > 0) {
            [set addObject:res];
        }
    }
    return set;
}

static NSDictionary<NSString *, NSString *> *st_propertyMap = nil;
+ (NSDictionary<NSString *, NSString *> *)dbocPropertyMap {
    if (st_propertyMap.count > 0) {
        return st_propertyMap;
    }
    unsigned int countOfProperty = 0;
    objc_property_t *propertyPtr = class_copyPropertyList(self.class, &countOfProperty);
    NSMutableDictionary *map = [NSMutableDictionary dictionaryWithCapacity:countOfProperty];
    for (int i = 0; i < countOfProperty; i++) {
        objc_property_t property = propertyPtr[i];
        const char *field = property_getName(property);
        NSString *ocField = [NSString stringWithCString:field encoding:NSUTF8StringEncoding];
        const char *type = property_getAttributes(property);
        const char *dbType = [self dboc_dbTypeWithPropertyType:type];
        NSString *ocDBType = [NSString stringWithCString:dbType encoding:NSUTF8StringEncoding];
        if (ocField.length > 0 && ocDBType.length > 0) {
            map[ocField] = ocDBType;
        }
    }
    st_propertyMap = [map copy];
    return st_propertyMap;
}

+ (instancetype)dbocObjWithJsonMap:(NSDictionary *)map {
    if (map.count <= 0) {
        return nil;
    }
    __auto_type obj = [self mj_objectWithKeyValues:map];
    return obj;
}

+ (NSArray<DBObjectProtocol> *)dbocObjArrayWithArrayJsonMap:(NSArray<NSDictionary *> *)array {
    if (array.count <= 0) {
        return nil;
    }
    __auto_type obj = [self mj_objectArrayWithKeyValuesArray:array];
    return obj;

}

+ (instancetype)dbocObjWithJsonString:(NSString *)jsonString {
    if (jsonString.length <= 0) {
        return nil;
    }
    NSDictionary *kv = [jsonString mj_JSONObject];
    __auto_type obj = [self mj_objectWithKeyValues:kv];
    return obj;
}

- (NSString *)dbocJsonString {
    return self.mj_JSONString;
}


#pragma mark -- private method

+ (const char *)dboc_dbTypeWithPropertyType:(const char *)type {
    if (StringHasPrefix("T@\"NSString\"", type)) {
        return "TEXT";
    }

    if (StringHasPrefix("Td", type) || StringHasPrefix("TD", type)) {
        return "DOUBLE";
    }

    if (StringHasPrefix("T@\"NSData\"", type)) {
        return "BLOB";
    }

    if (StringHasPrefix("Ti", type)
        || StringHasPrefix("TI", type)
        || StringHasPrefix("Ts", type)
        || StringHasPrefix("TS", type)
        || StringHasPrefix("Tq", type)
        || StringHasPrefix("TQ", type)) {
        return "INTEGER";
    }
    return "TEXT";
}

#pragma mark -- setter & getter

+ (NSString *)dbocTableName {
    if ([self respondsToSelector:@selector(tableName)]) {
        return [self tableName];
    }
    return NSStringFromClass(self);
}

- (void)setDbocCustomObjClassMap:(NSDictionary<NSString *,NSString *> *)dbocCustomObjClassMap {
    objc_setAssociatedObject(self, @selector(dbocCustomObjClassMap), dbocCustomObjClassMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary<NSString *,NSString *> *)dbocCustomObjClassMap {
    id obj = objc_getAssociatedObject(self, _cmd);
    if (!obj) {
        unsigned int countOfProperty = 0;
        objc_property_t *propertyPtr = class_copyPropertyList(self.class, &countOfProperty);
        NSMutableDictionary *map = [NSMutableDictionary dictionaryWithCapacity:countOfProperty];
        for (int i = 0; i < countOfProperty; i++) {
            objc_property_t property = propertyPtr[i];
            const char *field = property_getName(property);
            const char *type = property_getAttributes(property);

            // 类名长度超过128 Nope Crashed ？
            char buffer[128] = {0};
            StringSplit(type, buffer, "\"", 1);
//            NSLog(@"type : %s, buffer : %s, length : %lu", type, buffer, strlen(buffer));
            if (0 == strlen(buffer)) continue;
            //
            NSString *key = [NSString stringWithCString:field encoding:NSUTF8StringEncoding];
            NSString *value = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
            map[key] = value;
        }
        free(propertyPtr);
        //
        obj = [map copy];
        self.dbocCustomObjClassMap = obj;
    }
    return obj;
}

@end
