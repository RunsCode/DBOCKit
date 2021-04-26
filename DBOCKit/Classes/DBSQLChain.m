//
//  DBChain.m
//  Object_C_Advance
//
//  Created by WangYajun on 2021/4/26.
//  Copyright © 2021 王亚军. All rights reserved.
//

#import "DBSQLChain.h"

@interface DBSQLChain ()

@property (nonatomic, assign) DBSQLChainActionEnum actionType;

@property (nonatomic, strong) NSMutableString *sqlJoinedString;

@end

@implementation DBSQLChain

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

- (DBSQLChain *)column {
    return self;
}

- (DBSQLChain *)orderBy {
    return self;
}

- (DBSQLChain * (^)(void))desc {
    return ^{
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

- (DBSQLChain * (^)(NSString *))count {
    return ^(NSString *fieldName) {
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

- (DBSQLChain * (^)(NSString *, ...))property {
    return ^(NSString *tName, ...) {
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
