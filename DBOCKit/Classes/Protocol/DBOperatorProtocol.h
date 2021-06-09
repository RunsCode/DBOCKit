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

///alter drop
- (BOOL)executeWithSql:(NSString *)sql objClass:(Class<DBObjectProtocol> _Nullable)cls;

/// isnert delete update
///
/// @param sql sql description
/// @param obj an object model
- (BOOL)updateSql:(NSString *)sql observable:(id<DBObjectProtocol>)obj;

/// select
- (NSArray<NSDictionary<NSString *, id> *> *)selectWithSql:(NSString *)sql;
- (NSArray<DBObjectProtocol> *)selectWithSql:(NSString *)sql objClass:(Class<DBObjectProtocol> _Nullable)cls;

/// count
- (NSUInteger)countWithSql:(NSString *)sql;

/// convenience methods
- (BOOL)isnertOrUpdateObj:(id<DBObjectProtocol>)obj;
- (NSArray<DBObjectProtocol> *)fecthWithClass:(Class<DBObjectProtocol>)cls;

/// observer
- (void)addObserver:(id<DBObserverProtocol>)observer;
- (void)removeObserver:(id<DBObserverProtocol>)observer;

@end

NS_ASSUME_NONNULL_END
