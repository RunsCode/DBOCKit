//
//  DBChain.m
//  Object_C_Advance
//
//  Created by WangYajun on 2021/4/26.
//  Copyright © 2021 王亚军. All rights reserved.
//

#import "DBSQLChain.h"
#include <string.h>
#include "string_common.h"

int const kDBOCMaxSQLBufferLength = 1024;
char const * const kDBOCSQLACtionCREATE = "CREATE ";
char const * const kDBOCSQLACtionDROP = "DROP ";
char const * const kDBOCSQLACtionALTER = "ALTER ";
char const * const kDBOCSQLACtionINSERT = "INSERT ";
char const * const kDBOCSQLACtionDELETE = "DELETE ";
char const * const kDBOCSQLACtionUPDATE = "UPDATE ";
char const * const kDBOCSQLACtionSELECT = "SELECT ";

@interface DBSQLChain ()

@property (nonatomic, assign) DBSQLChainActionEnum actionType;

@end

@implementation DBSQLChain {
    char const *_sqlActions[8];
    char _bufferSql[kDBOCMaxSQLBufferLength];
}

#ifdef DEBUG
- (void)dealloc {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}
#endif

- (instancetype)initWithActionEnum:(DBSQLChainActionEnum)action {
    self = [super init];
    if (self) {
        _actionType = action;
        [self sqlActionsInit];
        [self sqlBufferInit];
    }
    return self;
}

- (void)sqlActionsInit {

    _sqlActions[DBSQLChainActionCreate] = kDBOCSQLACtionCREATE;
    _sqlActions[DBSQLChainActionDrop] = kDBOCSQLACtionDROP;
    _sqlActions[DBSQLChainActionAlter] = kDBOCSQLACtionALTER;
    _sqlActions[DBSQLChainActionInsert] = kDBOCSQLACtionINSERT;
    _sqlActions[DBSQLChainActionDelete] = kDBOCSQLACtionDELETE;
    _sqlActions[DBSQLChainActionUpdate] = kDBOCSQLACtionUPDATE;
    _sqlActions[DBSQLChainActionSelect] = kDBOCSQLACtionSELECT;
}

- (void)sqlBufferInit {

    char const *action = _sqlActions[_actionType];
    if (!action || strlen(action) == 0) {
        return;
    }
    memcpy(_bufferSql, action, strlen(action));
}

- (NSString *)sql {
    [self semicolon];
    NSString *res = [NSString stringWithUTF8String:_bufferSql];
    return res;
}

@end


@implementation DBSQLChain (MainAction)

+ (DBSQLChain *)create {
    return [self.class.alloc initWithActionEnum:DBSQLChainActionCreate];
}

+ (DBSQLChain *)drop {
    return [self.class.alloc initWithActionEnum:DBSQLChainActionDrop];
}

+ (DBSQLChain *)alter {
    return [self.class.alloc initWithActionEnum:DBSQLChainActionAlter];
}

+ (DBSQLChain *)insert {
    return [self.class.alloc initWithActionEnum:DBSQLChainActionInsert];
}

+ (DBSQLChain *)delete {
    return [self.class.alloc initWithActionEnum:DBSQLChainActionDelete];
}

+ (DBSQLChain *)update {
    return [self.class.alloc initWithActionEnum:DBSQLChainActionUpdate];
}

+ (DBSQLChain *)select {
    return [self.class.alloc initWithActionEnum:DBSQLChainActionSelect];
}

@end


#define DBOCSUBACTIONFUNC(name) \
return ^(const char *expression, ...) { \
    va_list ap; \
    va_start(ap, expression); \
    char buffer[512] = { 0 }; \
    vsnprintf(buffer, 512, expression, ap); \
    va_end(ap); \
    if (name && strlen(name) > 0) { \
        MutableMemoryCopyDest(self->_bufferSql, name, buffer, NULL);\
    } else { \
        MutableMemoryCopyDest(self->_bufferSql, buffer, NULL);\
    } \
    return self.space; \
}; \


@implementation DBSQLChain (SubAction)

- (DBSQLChain *)column {
    MutableMemoryCopyDest(self->_bufferSql, "COLUMN ", NULL);
    return self;
}

- (DBSQLChain *)desc {
    MutableMemoryCopyDest(self->_bufferSql, "DESC ", NULL);
    return self;
}

- (DBSQLChain *)distinct {
    MutableMemoryCopyDest(self->_bufferSql, "DISTINCT ", NULL);
    return self;
}


- (DBSQLChain * (^)(const char *))add {
    return ^(const char *propertyAndType) {
        if (propertyAndType && 0 < strlen(propertyAndType)) {
            MutableMemoryCopyDest(self->_bufferSql, "ADD COLUMN ", propertyAndType, NULL);
        }
        return self.space;
    };
}

- (DBSQLChain * (^)(const char *, ...))where {
    DBOCSUBACTIONFUNC("WHERE ")
}

- (DBSQLChain * (^)(const char *, ...))set {
    DBOCSUBACTIONFUNC("SET ")
}

- (DBSQLChain * (^)(const char *, ...))and {
    DBOCSUBACTIONFUNC("AND ")
}

- (DBSQLChain * (^)(const char *, ...))or {
    DBOCSUBACTIONFUNC("OR ")
}


@end


@implementation DBSQLChain (PropertyValues)


- (DBSQLChain * (^)(NSUInteger))limit {
    return ^(NSUInteger limit) {
        if (0 >= limit) {
            return self;
        }
        const char *value = @(limit).stringValue.UTF8String;
        MutableMemoryCopyDest(self->_bufferSql, "LIMIT ", value, NULL);
        return self.space;
    };
}

- (DBSQLChain * (^)(NSInteger))offset {
    return ^(NSInteger offset) {
        if (0 >= offset) {
            return self;
        }
        const char *value = @(offset).stringValue.UTF8String;
        MutableMemoryCopyDest(self->_bufferSql, "OFFSET ", value, NULL);
        return self.space;
    };
}

- (DBSQLChain * (^)(const char *))table {
    return ^(const char *tName) {
        if (tName && 0 < strlen(tName)) {
            MutableMemoryCopyDest(self->_bufferSql, "TABLE ", tName, NULL);
        }
        return self.space;
    };
}

- (DBSQLChain * (^)(const char *))from {
    return ^(const char *tName) {
        if (tName && 0 < strlen(tName)) {
            MutableMemoryCopyDest(self->_bufferSql, "FROM ", tName, NULL);
        }
        return self.space;
    };
}

- (DBSQLChain * (^)(const char *))field {
    return ^(const char *fieldName) {
        if (!fieldName && 0 == strlen(fieldName)) {
            return self;
        }
        MutableMemoryCopyDest(self->_bufferSql, "`", fieldName, "`", NULL);
        return self;
    };
}

- (DBSQLChain * (^)(const char *))count {
    return ^(const char *fieldName) {
        if (!fieldName && 0 == strlen(fieldName)) {
            MutableMemoryCopyDest(self->_bufferSql, "COUNT( * ) ", NULL);
            return self;
        }
        MutableMemoryCopyDest(self->_bufferSql, "COUNT( `", fieldName, "` ) ", NULL);
        return self;
    };
}

- (DBSQLChain * (^)(const char *))orderBy {
    return ^(const char *fieldName) {
        if (!fieldName && 0 == strlen(fieldName)) {
            return self;
        }
        MutableMemoryCopyDest(self->_bufferSql, "ORDER BY `", fieldName, "` ", NULL);
        return self;
    };
}

@end

@implementation DBSQLChain (Assist)

- (DBSQLChain *)comma {
    MutableMemoryCopyDest(self->_bufferSql, ",", NULL);
    return self;
}

- (DBSQLChain *)semicolon {
    MutableMemoryCopyDest(self->_bufferSql, ";", NULL);
    return self;

}

- (DBSQLChain *)space {
    MutableMemoryCopyDest(self->_bufferSql, " ", NULL);
    return self;
}

- (DBSQLChain * (^)(const char *, ...))append {
    DBOCSUBACTIONFUNC(NULL)
}

@end


@implementation DBSQLChain (DotSyntaxAdditions)

@end
