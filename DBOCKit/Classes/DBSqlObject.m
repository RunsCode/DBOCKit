//
//  DBSqlObject.m
//  DBOCKit
//
//  Created by WangYajun on 2021/6/10.
//

#import "DBSqlObject.h"

@implementation DBSqlObject

+ (instancetype)objWithSql:(NSString *)sql values:(NSArray *)values {
    DBSqlObject *obj = [DBSqlObject new];
    obj.sql = sql;
    obj.values = values;
    return obj;
}

@end
