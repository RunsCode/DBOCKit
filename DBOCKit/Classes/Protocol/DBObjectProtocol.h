//
//  DBObjectProtocol.h
//  Object_C_Advance
//
//  Created by WangYajun on 2021/4/26.
//  Copyright © 2021 王亚军. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DBOperaterProtocol;

NS_ASSUME_NONNULL_BEGIN

@protocol DBObjectProtocol <NSObject>

@required
/// fetch table name
+ (NSString *)tableName;


@optional

+ (NSString *)dboc_tableName;
+ (NSString *)dboc_defaultCreateTableSql;
+ (NSDictionary<NSString *, NSString *> *)dboc_propertyMap;
+ (NSSet<NSString *> *)dboc_alterTableSqlSetWithFields:(NSSet<NSString *> *)fields;

/// Some ignore don't participate in data field of the operation
/// Example:
///     @[ @"id", @"data",..., @"ts"]
///
+ (NSArray<NSString *> * _Nullable)ignoreTheFields;


/// All array child objects need to resolve the mapping of the conversion operation class
/// Example:
///     @property (nonatomic, copy) NSArray<IMObject *> *imObjs;
///
///     return @{ "imObjs" : IMObject.class  }
///
+ (NSDictionary<NSString *, Class> * _Nullable)arrayElementtFiledMapping;

@optional

- (void)didFinishConvertToObjByOperation:(id<DBOperaterProtocol>)operater;

- (void)didFinishConvertToJSONStringByOperation:(id<DBOperaterProtocol>)operater;


@end

NS_ASSUME_NONNULL_END
