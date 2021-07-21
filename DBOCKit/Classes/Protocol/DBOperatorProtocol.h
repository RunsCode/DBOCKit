//
//  DBOperatorProtocol.h
//  Object_C_Advance
//
//  Created by WangYajun on 2021/4/26.
//  Copyright © 2021 王亚军. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DBObjectProtocol;
@protocol DBObserverProtocol;

NS_ASSUME_NONNULL_BEGIN

@protocol DBOperatorProtocol <NSObject>

- (instancetype)init __attribute__((unavailable("use protocol `DBOperatorProtocol` method instead")));
+ (instancetype)new __attribute__((unavailable("use protocol `DBOperatorProtocol` method instead")));

- (instancetype)initWithDBPath:(NSString *)path;
- (instancetype)initWithDBURL:(NSURL *)url;
- (instancetype)initWithDBName:(NSString *)name directory:(NSString *)dir;

- (BOOL)existsTableWithName:(NSString *)name;
- (BOOL)createTableWithObjClass:(Class<DBObjectProtocol>)cls;

/// alter drop
- (BOOL)executeWithSql:(NSString *)sql;

/// isnert delete update
///
/// @param sql sql description
/// @param obj an object model
- (BOOL)updateSql:(NSString *)sql observable:(id<DBObjectProtocol>)obj;

/// select
- (NSArray<NSDictionary<NSString *, id> *> * _Nullable)selectWithSql:(NSString *)sql;
- (NSArray<DBObjectProtocol> *)selectObjClass:(Class)cls withSql:(NSString *)sql;

/// count
- (NSUInteger)countWithSql:(NSString *)sql;
- (NSUInteger)countOfTable:(NSString *)tName;

/// convenience methods
- (BOOL)insertOrUpdateObj:(id<DBObjectProtocol>)obj;
- (BOOL)deleteObj:(id<DBObjectProtocol>)obj;
- (NSArray<DBObjectProtocol> * _Nullable)fecthWithClass:(Class<DBObjectProtocol>)cls;

/// batch behavior
- (BOOL)insertOrUpdateObjs:(NSArray<DBObjectProtocol> *)objs;
- (BOOL)deleteObjs:(NSArray<DBObjectProtocol> *)objs;

/// observer
- (void)addObserver:(id<DBObserverProtocol>)observer;
- (void)removeObserver:(id<DBObserverProtocol>)observer;

@end

NS_ASSUME_NONNULL_END
