//
//  DBSqlObject.h
//  DBOCKit
//
//  Created by WangYajun on 2021/6/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBSqlObject : NSObject

@property (nonatomic, copy) NSString *sql;

@property (nonatomic, copy) NSArray *values;

+ (instancetype)objWithSql:(NSString *)sql values:(NSArray *)values;

@end

NS_ASSUME_NONNULL_END
