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

#define OCMutableMemoryCopyDest(exp) \
va_list ap; \
va_start(ap, exp); \
NSString *str = [[NSString alloc] initWithFormat:exp arguments:ap]; \
mutableMemoryCopyDest(self->_bufferSql, str.UTF8String); \
va_end(ap); \


@interface DBSQLChain ()

@property (nonatomic, assign) DBSQLChainActionEnum actionType;

@property (nonatomic, strong) NSMutableString *sqlJoinedString;

@end

@implementation DBSQLChain {
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
        [self sqlBufferInit];
    }
    return self;
}

- (NSString *)sql {
    [self semicolon];
    NSString *res = [NSString stringWithUTF8String:_bufferSql];
    return res;
}

- (NSMutableString *)sqlJoinedString {
    if (_sqlJoinedString) return _sqlJoinedString;
    //
    _sqlJoinedString = [[NSMutableString alloc] init];
    return _sqlJoinedString;
}

- (void)sqlBufferInit {
    switch (_actionType) {
        case DBSQLChainActionCreate: {
            memcpy(_bufferSql, kDBOCSQLACtionCREATE, strlen(kDBOCSQLACtionCREATE));
        }

            break;
        case DBSQLChainActionDrop: {
            memcpy(_bufferSql, kDBOCSQLACtionDROP, strlen(kDBOCSQLACtionDROP));
        }

            break;
        case DBSQLChainActionAlter: {
            memcpy(_bufferSql, kDBOCSQLACtionALTER, strlen(kDBOCSQLACtionALTER));
        }

            break;
        case DBSQLChainActionInsert: {
            memcpy(_bufferSql, kDBOCSQLACtionINSERT, strlen(kDBOCSQLACtionINSERT));
        }

            break;
        case DBSQLChainActionDelete: {
            memcpy(_bufferSql, kDBOCSQLACtionDELETE, strlen(kDBOCSQLACtionDELETE));
        }

            break;
        case DBSQLChainActionUpdate: {
            memcpy(_bufferSql, kDBOCSQLACtionUPDATE, strlen(kDBOCSQLACtionUPDATE));
        }

            break;
        case DBSQLChainActionSelect: {
            memcpy(_bufferSql, kDBOCSQLACtionSELECT, strlen(kDBOCSQLACtionSELECT));
        }

            break;

        default:
            break;
    }
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


@implementation DBSQLChain (SubAction)

- (DBSQLChain *)column {
    mutableMemoryCopyDest(self->_bufferSql, "COLUMN ", NULL);
    return self;
}

- (DBSQLChain *)desc {
    mutableMemoryCopyDest(self->_bufferSql, "DESC ", NULL);
    return self;
}

- (DBSQLChain *)distinct {
    mutableMemoryCopyDest(self->_bufferSql, "DISTINCT ", NULL);
    return self;
}


- (DBSQLChain * (^)(const char *))add {
    return ^(const char *propertyAndType) {
        if (propertyAndType && 0 < strlen(propertyAndType)) {
            mutableMemoryCopyDest(self->_bufferSql, "ADD COLUMN ", propertyAndType, NULL);
        }
        return self.space;
    };
}

- (DBSQLChain * (^)(const char *, ...))where {
    return ^(const char *expression, ...) {
        va_list ap;
        va_start(ap, expression);
        char buffer[512] = { 0 };
        vsnprintf(buffer, 512, expression, ap);
        va_end(ap);
        mutableMemoryCopyDest(self->_bufferSql, "WHERE ", buffer, NULL);
        return self.space;
    };
}

- (DBSQLChain * (^)(const char *, ...))set {
    return ^(const char *expression, ...) {
        va_list ap;
        va_start(ap, expression);
        char buffer[512] = { 0 };
        vsnprintf(buffer, 512, expression, ap);
        va_end(ap);
        mutableMemoryCopyDest(self->_bufferSql, "SET ", buffer, NULL);
        return self.space;
    };
}

- (DBSQLChain * (^)(const char *, ...))and {
    return ^(const char *expression, ...) {
        va_list ap;
        va_start(ap, expression);
        char buffer[512] = { 0 };
        vsnprintf(buffer, 512, expression, ap);
        va_end(ap);
        mutableMemoryCopyDest(self->_bufferSql, "AND ", buffer, NULL);
        return self.space;
    };
}

- (DBSQLChain * (^)(const char *, ...))or {
    return ^(const char *expression, ...) {
        va_list ap;
        va_start(ap, expression);
        char buffer[512] = { 0 };
        vsnprintf(buffer, 512, expression, ap);
        va_end(ap);
        mutableMemoryCopyDest(self->_bufferSql, "OR ", buffer, NULL);
        return self.space;
    };
}


@end


@implementation DBSQLChain (PropertyValues)


- (DBSQLChain * (^)(NSUInteger))limit {
    return ^(NSUInteger limit) {
        if (0 >= limit) {
            return self;
        }
        const char *value = @(limit).stringValue.UTF8String;
        mutableMemoryCopyDest(self->_bufferSql, "LIMIT ", value, NULL);
        return self.space;
    };
}

- (DBSQLChain * (^)(NSInteger))offset {
    return ^(NSInteger offset) {
        if (0 >= offset) {
            return self;
        }
        const char *value = @(offset).stringValue.UTF8String;
        mutableMemoryCopyDest(self->_bufferSql, "OFFSET ", value, NULL);
        return self.space;
    };
}

- (DBSQLChain * (^)(const char *))table {
    return ^(const char *tName) {
        if (tName && 0 < strlen(tName)) {
            mutableMemoryCopyDest(self->_bufferSql, "TABLE ", tName, NULL);
        }
        return self.space;
    };
}

- (DBSQLChain * (^)(const char *))from {
    return ^(const char *tName) {
        if (tName && 0 < strlen(tName)) {
            mutableMemoryCopyDest(self->_bufferSql, "FROM ", tName, NULL);
        }
        return self.space;
    };
}

- (DBSQLChain * (^)(const char *))field {
    return ^(const char *fieldName) {
        if (!fieldName && 0 == strlen(fieldName)) {
            return self;
        }
        mutableMemoryCopyDest(self->_bufferSql, "`", fieldName, "`", NULL);
        return self;
    };
}

- (DBSQLChain * (^)(const char *))count {
    return ^(const char *fieldName) {
        if (!fieldName && 0 == strlen(fieldName)) {
            mutableMemoryCopyDest(self->_bufferSql, "COUNT( * ) ", NULL);
            return self;
        }
        mutableMemoryCopyDest(self->_bufferSql, "COUNT( `", fieldName, "` ) ", NULL);
        return self;
    };
}

- (DBSQLChain * (^)(const char *))orderBy {
    return ^(const char *fieldName) {
        if (!fieldName && 0 == strlen(fieldName)) {
            return self;
        }
        mutableMemoryCopyDest(self->_bufferSql, "ORDER BY `", fieldName, "` ", NULL);
        return self;
    };
}

@end

@implementation DBSQLChain (Assist)

- (DBSQLChain *)comma {
    mutableMemoryCopyDest(self->_bufferSql, ",", NULL);
    return self;
}

- (DBSQLChain *)semicolon {
    mutableMemoryCopyDest(self->_bufferSql, ";", NULL);
    return self;

}

- (DBSQLChain *)space {
    mutableMemoryCopyDest(self->_bufferSql, " ", NULL);
    return self;
}

- (DBSQLChain * (^)(const char *, ...))append {
    return ^(const char *sql, ...) {
        va_list ap;
        va_start(ap, sql);
        char buffer[512] = { 0 };
        vsnprintf(buffer, 512, sql, ap);
        va_end(ap);
        mutableMemoryCopyDest(self->_bufferSql, buffer, NULL);
        return self.space;
    };
}

@end


@implementation DBSQLChain (DotSyntaxAdditions)

@end
