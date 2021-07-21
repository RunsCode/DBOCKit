//
//  DBObjectProtocol.h
//  Object_C_Advance
//
//  Created by WangYajun on 2021/4/26.
//  Copyright © 2021 王亚军. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DBSqlObject;
@protocol DBOperatorProtocol;

NS_ASSUME_NONNULL_BEGIN

@protocol DBObjectProtocol <NSObject>

@required
@property (nonatomic, assign) NSUInteger dbocPrimaryKeyId;

@optional
/// [field:NonBasicValueType]
@property (nonatomic, strong, readonly) NSDictionary<NSString *, NSString *> *dbocNonBasicValueTypeClassMap;

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
+ (NSSet<NSString *> *)dbocIgnoreFields;
+ (NSString *)dbocDefaultCreateTableSql;
+ (NSDictionary<NSString *, NSString *> *)dbocPropertyMap;
+ (NSSet<NSString *> *)dbocAlterTableSqlSetWithFields:(NSSet<NSString *> *)fields;

/// JSON -> Model
+ (instancetype _Nullable)dbocObjWithJsonMap:(NSDictionary *)map;
/// JSON String -> Model
+ (instancetype _Nullable)dbocObjWithJsonString:(NSString *)jsonString;
/// JSON Array -> Model Array
+ (NSArray<DBObjectProtocol> *_Nullable)dbocObjArrayWithArrayJsonMap:(NSArray<NSDictionary *> *)array;
/// Model -> JSON String
- (NSString * _Nullable)dbocJsonString;

///
- (DBSqlObject *_Nullable)dbocInsertSqlObj;
- (DBSqlObject *_Nullable)dbocUpdateSqlObj;

@end

NS_ASSUME_NONNULL_END
