//
//  NSObject+DBObj.h
//  DBOCKit
//
//  Created by WangYajun on 2021/6/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (DBObj)

@property (nonatomic, copy, readonly, class) NSString *dboc_tableName;

@property (nonatomic, copy, readonly, class) NSDictionary<NSString *, NSString *> *dboc_propertyMap;

@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *dboc_customObjClassMap;

+ (NSString *)dboc_defaultCreateTableSql;

+ (NSArray<NSString *> *)dboc_alterTableSqlArrayWithFields:(NSArray<NSString *> *)fields;

@end

NS_ASSUME_NONNULL_END
