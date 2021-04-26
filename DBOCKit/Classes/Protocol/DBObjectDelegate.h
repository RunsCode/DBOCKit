//
//  DBOperationDelegate.h
//  Object_C_Advance
//
//  Created by WangYajun on 2021/4/26.
//  Copyright © 2021 王亚军. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DBOperaterProtocol;

NS_ASSUME_NONNULL_BEGIN

@protocol DBOperationDelegate <NSObject>

@required

/// fetch table name
/// @param operater operater description
- (NSString *)tableNameWithOperater:(id<DBOperaterProtocol>)operater;


@optional

/// Some ignore don't participate in data field of the operation
/// Example:
///     @[ @"id", @"data",..., @"ts"]
///
/// @param operater operater description
- (NSArray<NSString *> * _Nullable)ignoreTheFieldsWithOperater:(id<DBOperaterProtocol>)operater;


/// All child objects need to resolve the mapping of the conversion operation class
/// Example:
///     @{ "session" : IMSession.class }
///
/// @param operater operater description
- (NSDictionary<NSString *, Class> * _Nullable)childFiledMappingWithOperater:(id<DBOperaterProtocol>)operater;


- (void)didFinishConvertToObj:(id<DBOperaterProtocol>)operater;

- (void)didFinishConvertToJSONString:(id<DBOperaterProtocol>)operater;


@end

NS_ASSUME_NONNULL_END
