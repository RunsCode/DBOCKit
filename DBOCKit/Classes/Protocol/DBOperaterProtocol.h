//
//  DBOperaterProtocol.h
//  Object_C_Advance
//
//  Created by WangYajun on 2021/4/26.
//  Copyright © 2021 王亚军. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DBObjectProtocol;
@protocol DBObserverProtocol;

NS_ASSUME_NONNULL_BEGIN

@protocol DBOperaterProtocol <NSObject>

- (BOOL)existsTableWithName:(NSString *)name;

- (BOOL)createTableWithObjClass:(Class<DBObjectProtocol>)cls;

///alter drop
- (BOOL)executeWithSql:(NSString *)sql objClass:(Class<DBObjectProtocol> _Nullable)cls;

/// isnert delete update
///
/// @param sql sql description
/// @param obj an observed object model
- (BOOL)updateSql:(NSString *)sql observable:(id<DBObserverProtocol>)obj;

/// select
- (NSArray *)selectWithSql:(NSString *)sql objClass:(Class<DBObjectProtocol> _Nullable)cls;

/// count
- (NSInteger)countWithSql:(NSString *)sql;

- (void)addObserver:(id<DBObserverProtocol>)observer;

- (void)removeObserver:(id<DBObserverProtocol>)observer;

@end

NS_ASSUME_NONNULL_END
