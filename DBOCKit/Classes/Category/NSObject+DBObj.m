//
//  NSObject+DBObj.m
//  DBOCKit
//
//  Created by WangYajun on 2021/6/4.
//

#include "string_common.h"
#import <objc/runtime.h>
#import <MJExtension/MJExtension.h>
#import "NSObject+DBObj.h"
#import "NSString+Tool.h"
#import "DBObjectProtocol.h"
#import "DBSqlObject.h"
#include "stdlib.h"

//@interface NSObject ()//<DBObjectProtocol>
//
//@end

@implementation NSObject (DBObj)

@dynamic primaryKeyId;

+ (NSSet<NSString *> *)dbocIgnoreFields {
    NSMutableSet *mutable = [NSMutableSet setWithObjects:
                             @"hash",
                             @"superclass",
                             @"description",
                             @"debugDescription",
                             @"primaryKeyId",
                             @"dbocNonBasicValueTypeClassMap",
                             nil];
    if ([self respondsToSelector:@selector(ignoreTheFields)]) {
        NSArray *res = [self ignoreTheFields];
        if (res) {
            [mutable addObjectsFromArray:res];
        }
    }
    return mutable.copy;
}

+ (NSString *)dbocDefaultCreateTableSql {
    NSString *table = [self dbocTableName];
    //
    const char *prefix = "CREATE TABLE IF NOT EXISTS ";
    const char *pkSql = "(primaryKeyId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL DEFAULT(0)";

    char buffer[1024] = {0};
    MutableMemoryCopyDest(buffer, prefix, table.UTF8String, pkSql, NULL);
    //
    NSMutableSet<NSString *> *ignoreFields = self.dbocIgnoreFields.mutableCopy;
    //
    NSDictionary<NSString *, NSString *> *map = [self dbocPropertyMap];
    NSMutableSet *propertySet = [NSMutableSet setWithArray:map.allKeys];
    [propertySet minusSet:ignoreFields];
    //
    for (NSString *properyName in propertySet) {
        const char *dbType = map[properyName].UTF8String;
        MutableMemoryCopyDest(buffer,  ", ", properyName.UTF8String, " ", dbType, NULL);
    }
    MutableMemoryCopyDest(buffer, ");", NULL);
    NSLog(@"buffer length : %lu", strlen(buffer));
    //
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
        if (isAbnormalString(res)) continue;
        [set addObject:res];
    }
    return set;
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
/**
 INSERT INTO JYHitchMessage(data,myUserId,bizType,passengerOrderGuid,driverOrderGuid,msgId,type,fromUserGuid,fromAvatarIndex,fromAvatarUrl,fromNickname,toUserGuid,toAvatarIndex,toAvatarUrl,toNickName,ts,localRead,localState,os,ignore,readReceipt,quickMsgType,implicit) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);
 */

- (id)valueTransfrom:(id)obj {
    NSObject *value = obj;
    if ([value isKindOfClass:NSSet.class]) {
        value = ((NSSet *)value).allObjects;
    }
    if ([value isKindOfClass:NSArray.class]) {
        NSSet<NSString *> *ignoreSet = [self.class dbocIgnoreFields];
        value = [value.class mj_keyValuesArrayWithObjectArray:(NSArray *)value ignoredKeys:ignoreSet.allObjects];
        return [value dbocJsonString];
    }
    if ([value isKindOfClass:NSDate.class]) {
        return @(((NSDate *)value).timeIntervalSince1970).stringValue;
    }
    if ([value isKindOfClass:NSData.class]) {
        return value;
    }
    return [value dbocJsonString];
}

- (DBSqlObject *)dbocInsertSqlObj {
    NSString *tName = [self.class dbocTableName];
    if (isAbnormalString(tName))  return nil;
    //
    NSMutableSet *propertySet = [NSMutableSet setWithArray:self.class.dbocPropertyMap.allKeys];
    NSSet<NSString *> *ignoreSet = [self.class dbocIgnoreFields];
    [propertySet minusSet:ignoreSet];
    //
    NSArray<NSString *> *objTypeArray = self.dbocNonBasicValueTypeClassMap.allKeys;
    NSMutableArray *symbolArray = [NSMutableArray arrayWithCapacity:propertySet.count];
    NSMutableArray *valueArray = [NSMutableArray arrayWithCapacity:propertySet.count];

    for (NSString *propertyName in propertySet) {
        [symbolArray addObject:@"?"];
        id<DBObjectProtocol> value = [self valueForKey:propertyName];
        if (!value) {
            [valueArray addObject:@""];
            continue;
        }
        //
        BOOL isOCObj = [objTypeArray containsObject:propertyName];
        if (isOCObj) {//非基本类型 转 json string
            value = [self valueTransfrom:value];
        }
        [valueArray addObject:value];
    }
    char buffer[1024] = {0};
    const char *keySql = [propertySet.allObjects componentsJoinedByString:@", "].UTF8String;
    const char *symbolSql = [symbolArray componentsJoinedByString:@", "].UTF8String;;
    MutableMemoryCopyDest(buffer, "INSERT INTO ", tName.UTF8String, " (" , keySql, ") VALUES (", symbolSql, ");", NULL);
    NSString *sql = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
    //
    return [DBSqlObject objWithSql:sql values:valueArray];
}

/**
 UPDATE JYHitchConversation SET  myUserGuid=?, bizType=?, driverOrderGuid=?, passengerOrderGuid=?, userGuid=?, nickname=?, avatar=?, avatarIndex=?, message=?, lastMessageData=?, lastMessageFromUserGuid=?, lastMessageType=?, ts=?, unread=?, readReceipt=? WHERE pk = ?;

 */
- (DBSqlObject *)dbocUpdateSqlObj {
    NSString *tName = [self.class dbocTableName];
    if (isAbnormalString(tName))  return nil;
    //
    NSMutableSet *propertySet = [NSMutableSet setWithArray:self.class.dbocPropertyMap.allKeys];
    NSSet<NSString *> *ignoreSet = [self.class dbocIgnoreFields];
    [propertySet minusSet:ignoreSet];
    //
    NSArray<NSString *> *objTypeArray = self.dbocNonBasicValueTypeClassMap.allKeys;
    NSMutableArray *valueArray = [NSMutableArray arrayWithCapacity:propertySet.count];
    for (NSString *propertyName in propertySet) {
        id<DBObjectProtocol> value = [self valueForKey:propertyName];
        if (!value) {
            [valueArray addObject:@""];
            continue;
        }
        //
        BOOL isOCObj = [objTypeArray containsObject:propertyName];
        if (isOCObj) {//非基本类型 转 json string
            value = [self valueTransfrom:value];
        }
        [valueArray addObject:value];
    }
    char buffer[1024] = {0};
    char primaryKeyId[64] = {0};
    sprintf(primaryKeyId, "%lu;", (unsigned long)self.primaryKeyId);
    const char *keySql = [propertySet.allObjects componentsJoinedByString:@"=?, "].UTF8String;
    MutableMemoryCopyDest(buffer, "UPDATE ", tName.UTF8String, " SET " , keySql, "=?, WHERE primaryKeyId=", primaryKeyId, NULL);
    NSString *sql = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
    //
    return [DBSqlObject objWithSql:sql values:valueArray];;
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
//// [field:dbtype]
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

+ (NSString *)dbocTableName {
    if ([self respondsToSelector:@selector(tableName)]) {
        return [self tableName];
    }
    return NSStringFromClass(self);
}

- (void)setDbocNonBasicValueTypeClassMap:(NSDictionary<NSString *,NSString *> *)dbocNonBasicValueTypeClassMap {
    objc_setAssociatedObject(self, @selector(dbocNonBasicValueTypeClassMap), dbocNonBasicValueTypeClassMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

/// [field:NonBasicValueType]
- (NSDictionary<NSString *,NSString *> *)dbocNonBasicValueTypeClassMap {
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
            if (0 == strlen(buffer)) continue;
            if (0 == strcmp(buffer, "NSString")) continue;
            if (0 == strcmp(buffer, "NSData")) continue;
            //
            NSString *key = [NSString stringWithCString:field encoding:NSUTF8StringEncoding];
            NSString *value = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
            if (isAbnormalString(key) || isAbnormalString(value)) continue;
            map[key] = value;
        }
        free(propertyPtr);
        //
        obj = [map copy];
        self.dbocNonBasicValueTypeClassMap = obj;
    }
    return obj;
}

@end
