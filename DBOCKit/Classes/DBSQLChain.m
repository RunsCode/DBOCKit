//
//  DBChain.m
//  Object_C_Advance
//
//  Created by WangYajun on 2021/4/26.
//  Copyright © 2021 王亚军. All rights reserved.
//

#import "DBSQLChain.h"
#include "string_common.h"

const int kMaxSQLBufferLength = 1024;


@interface DBSQLChain ()

@property (nonatomic, assign) DBSQLChainActionEnum actionType;

@property (nonatomic, strong) NSMutableString *sqlJoinedString;

@end

@implementation DBSQLChain {
    char _bufferSql[kMaxSQLBufferLength];
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
    }
    return self;
}

- (NSString *)sql {
    return _sqlJoinedString.copy;
}

- (NSMutableString *)sqlJoinedString {
    if (_sqlJoinedString) return _sqlJoinedString;
    //
    _sqlJoinedString = [[NSMutableString alloc] init];
    return _sqlJoinedString;
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

- (DBSQLChain *)distinct {
    return self;
}

- (DBSQLChain *)column {
    return self;
}

- (DBSQLChain *)desc {
    return self;
}

- (DBSQLChain * (^)(NSString *))orderBy {
    return ^(NSString *FieldName){
        return self;
    };
}

- (DBSQLChain * (^)(NSString *))count {
    return ^(NSString *fieldName) {
        return self;
    };
}

- (DBSQLChain * (^)(NSInteger))limit {
    return ^(NSInteger limit) {
        return self;
    };
}

- (DBSQLChain * (^)(NSInteger))offset {
    return ^(NSInteger offset) {
        return self;
    };
}

- (DBSQLChain * (^)(NSString *))add {
    return ^(NSString *property) {
        return self;
    };
}

- (DBSQLChain * (^)(NSString *, ...))where {
    return ^(NSString *expression, ...) {
        va_list ap;
        va_start(ap, expression);
        NSString *str = [[NSString alloc] initWithFormat:expression arguments:ap];
        va_end(ap);

        immutableCopyCatDest(self->_bufferSql, str.UTF8String);
        return self;
    };
}

- (DBSQLChain * (^)(NSString *, ...))set {
    return ^(NSString *expression, ...) {
        return self;
    };
}

- (DBSQLChain * (^)(NSString *, ...))and {
    return ^(NSString *expression, ...) {
        return self;
    };
}

- (DBSQLChain * (^)(NSString *, ...))or {
    return ^(NSString *expression, ...) {
        return self;
    };
}

- (DBSQLChain * (^)(NSString *, ...))append {
    return ^(NSString *sql, ...) {
        return self;
    };
}

@end


@implementation DBSQLChain (PropertyValues)

- (DBSQLChain * (^)(NSString *))table {
    return ^(NSString *tName) {
        return self;
    };
}

- (DBSQLChain * (^)(NSString *))from {
    return ^(NSString *tName) {
        return self;
    };
}

- (DBSQLChain * (^)(NSString *))property {
    return ^(NSString *tName) {
        return self;
    };
}

- (DBSQLChain * (^)(NSString *))field {
    return ^(NSString *fieldName) {
        return self;
    };
}

- (DBSQLChain * (^)(NSString *, ...))fields {
    return ^(NSString *fields, ...) {
        return self;
    };
}

- (DBSQLChain * (^)(id))value {
    return ^(id value) {
        return self;
    };
}

- (DBSQLChain * (^)(id, ...))values {
    return ^(id values, ...) {
        return self;
    };
}

@end


@implementation DBSQLChain (CStringExpression)

- (DBSQLChain * (^)(const char *))c_orderBy {
    return ^(const char *fieldName) {
        return self;
    };
}

- (DBSQLChain * (^)(const char *))c_count {
    return ^(const char *fieldName) {
        return self;
    };
}

- (DBSQLChain * (^)(const char *))c_field {
    return ^(const char *fieldName) {
        return self;
    };
}

- (DBSQLChain * (^)(const char *))c_add {
    return ^(const char *property) {
        return self;
    };
}

- (DBSQLChain * (^)(const char *))c_table {
    return ^(const char *tName) {
        return self;
    };
}

- (DBSQLChain * (^)(const char *))c_from {
    return ^(const char *tName) {
        return self;
    };
}

- (DBSQLChain * (^)(const char *, ...))c_where {
    return ^(const char *expression, ...) {
        return self;
    };
}

- (DBSQLChain * (^)(const char *, ...))c_set {
    return ^(const char *expression, ...) {
        return self;
    };
}

- (DBSQLChain * (^)(const char *, ...))c_and {
    return ^(const char *expression, ...) {
        return self;
    };
}

- (DBSQLChain * (^)(const char *, ...))c_or {
    return ^(const char *expression, ...) {
        return self;
    };
}

- (DBSQLChain * (^)(const char *, ...))c_append {
    return ^(const char *sql, ...) {
        return self;
    };
}


@end

/**
 //va_list args;
 //va_start(args, format);
 //NSString *str = [[NSString alloc] initWithFormat:format arguments:args];
 //va_end(args);
 */
