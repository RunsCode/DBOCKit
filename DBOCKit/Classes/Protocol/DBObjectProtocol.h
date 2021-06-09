//
//  DBObjectProtocol.h
//  Object_C_Advance
//
//  Created by WangYajun on 2021/4/26.
//  Copyright © 2021 王亚军. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DBOperatorProtocol;

NS_ASSUME_NONNULL_BEGIN

@protocol DBObjectProtocol <NSObject>
@optional

@property (nonatomic, strong, readonly) NSDictionary<NSString *, NSString *> *dbocCustomObjClassMap;

/// fetch table name
+ (NSString *)tableName;

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

/// implementation by category
+ (NSString *)dbocTableName;
+ (NSString *)dbocDefaultCreateTableSql;
+ (NSDictionary<NSString *, NSString *> *)dbocPropertyMap;
+ (NSSet<NSString *> *)dbocAlterTableSqlSetWithFields:(NSSet<NSString *> *)fields;

+ (instancetype _Nullable)dbocObjWithJsonMap:(NSDictionary *)map;
+ (NSArray<DBObjectProtocol> *_Nullable)dbocObjArrayWithArrayJsonMap:(NSArray<NSDictionary *> *)array;
+ (instancetype _Nullable)dbocObjWithJsonString:(NSString *)jsonString;
- (NSString * _Nullable)dbocJsonString;


//@optional
//
//- (void)didFinishConvertToObjByOperation:(id<DBOperaterProtocol>)operater;
//
//- (void)didFinishConvertToJSONStringByOperation:(id<DBOperaterProtocol>)operater;


@end

NS_ASSUME_NONNULL_END
