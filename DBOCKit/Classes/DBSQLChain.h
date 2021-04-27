//
//  DBSQLChain.h
//  Object_C_Advance
//
//  Created by WangYajun on 2021/4/26.
//  Copyright © 2021 王亚军. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DBOperaterProtocol;

typedef NS_ENUM(NSUInteger, DBSQLChainActionEnum) {
    DBSQLChainActionCreate = 0,
    DBSQLChainActionDrop   = 1,
    DBSQLChainActionAlter  = 2,
    DBSQLChainActionInsert = 3,
    DBSQLChainActionDelete = 4,
    DBSQLChainActionUpdate = 5,
    DBSQLChainActionSelect = 6,
};


NS_ASSUME_NONNULL_BEGIN

@interface DBSQLChain : NSObject

@property (nonatomic, copy, readonly) NSString *sql;
@property (nonatomic, assign, readonly) DBSQLChainActionEnum actionType;

@end

@interface DBSQLChain (MainAction)

@property (nonatomic, strong, class, readonly) DBSQLChain *create;
@property (nonatomic, strong, class, readonly) DBSQLChain *drop;
@property (nonatomic, strong, class, readonly) DBSQLChain *alter;
@property (nonatomic, strong, class, readonly) DBSQLChain *insert;
@property (nonatomic, strong, class, readonly) DBSQLChain *delete;
@property (nonatomic, strong, class, readonly) DBSQLChain *update;
@property (nonatomic, strong, class, readonly) DBSQLChain *select;

@end


@interface DBSQLChain (SubAction)

@property (nonatomic, strong, readonly) DBSQLChain *desc;
@property (nonatomic, strong, readonly) DBSQLChain *column;
@property (nonatomic, strong, readonly) DBSQLChain *distinct;
@property (nonatomic, strong, readonly) DBSQLChain *(^orderBy)(NSString *fieldName);
@property (nonatomic, strong, readonly) DBSQLChain *(^count)(NSString *fieldName);

@property (nonatomic, strong, readonly) DBSQLChain *(^limit)(NSInteger limit);
@property (nonatomic, strong, readonly) DBSQLChain *(^offset)(NSInteger offset);
@property (nonatomic, strong, readonly) DBSQLChain *(^add)(NSString *property);
@property (nonatomic, strong, readonly) DBSQLChain *(^where)(NSString *expression, ...);
@property (nonatomic, strong, readonly) DBSQLChain *(^set)(NSString *expression, ...);
@property (nonatomic, strong, readonly) DBSQLChain *(^and)(NSString *expression, ...);
@property (nonatomic, strong, readonly) DBSQLChain *(^or)(NSString *expression, ...);
/// Flexible insert SQL expression in any position
/// example: append('xxx LIKE yyy')
@property (nonatomic, strong, readonly) DBSQLChain *(^append)(NSString *sql, ...);

@end


@interface DBSQLChain (PropertyValues)

@property (nonatomic, strong, readonly) DBSQLChain *(^table)(NSString *tName);
@property (nonatomic, strong, readonly) DBSQLChain *(^from)(NSString *tName);
/// (xxx text, yyy other_type)
@property (nonatomic, strong, readonly) DBSQLChain *(^property)(NSString *property);

@property (nonatomic, strong, readonly) DBSQLChain *(^field)(NSString *fieldName);
/// (field1, field2, field3, nil)
@property (nonatomic, strong, readonly) DBSQLChain *(^fields)(NSString *fields, ...);

@property (nonatomic, strong, readonly) DBSQLChain *(^value)(id value);
/// (value1, value2, value3, nil)
@property (nonatomic, strong, readonly) DBSQLChain *(^values)(id values, ...);

@end


@interface DBSQLChain (CStringExpression)

@property (nonatomic, strong, readonly) DBSQLChain *(^c_orderBy)(const char *fieldName);
@property (nonatomic, strong, readonly) DBSQLChain *(^c_count)(const char *fieldName);
@property (nonatomic, strong, readonly) DBSQLChain *(^c_field)(const char *fieldName);
@property (nonatomic, strong, readonly) DBSQLChain *(^c_add)(const char *property);
@property (nonatomic, strong, readonly) DBSQLChain *(^c_table)(const char *tName);
@property (nonatomic, strong, readonly) DBSQLChain *(^c_from)(const char *tName);
@property (nonatomic, strong, readonly) DBSQLChain *(^c_where)(const char *expression, ...);
@property (nonatomic, strong, readonly) DBSQLChain *(^c_set)(const char *expression, ...);
@property (nonatomic, strong, readonly) DBSQLChain *(^c_and)(const char *expression, ...);
@property (nonatomic, strong, readonly) DBSQLChain *(^c_or)(const char *expression, ...);
@property (nonatomic, strong, readonly) DBSQLChain *(^c_append)(const char *sql, ...);

@end


NS_ASSUME_NONNULL_END


/// create table tName (id integer primary key autoincrement, x text);
/// create table tName(column1 datatype PRIMARY KEY, column2 datatype, ……);

/// select column1,column2…… from tName where condition;
/// insert into tName (x) values ('XXX');
/// insert into tName (x, y, z) values (?, ?, ?)"
/// update tName set column1 = value1, column2 = value2…… where condition;
/// delete from student where number = 10102;
/// ALTER TABLE tName ADD column_name datatype
/// ALTER TABLE tName DROP COLUMN column_name
/// ALTER TABLE tName ALTER COLUMN column_name datatype
