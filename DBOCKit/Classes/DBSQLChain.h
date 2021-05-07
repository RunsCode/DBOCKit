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
@property (nonatomic, strong, readonly) DBSQLChain *distinct; /// 去重

@property (nonatomic, strong, readonly) DBSQLChain *(^add)(const char *propertyAndType);
@property (nonatomic, strong, readonly) DBSQLChain *(^where)(const char *expression, ...);
@property (nonatomic, strong, readonly) DBSQLChain *(^set)(const char *expression, ...);
@property (nonatomic, strong, readonly) DBSQLChain *(^and)(const char *expression, ...);
@property (nonatomic, strong, readonly) DBSQLChain *(^or)(const char *expression, ...);

@end


@interface DBSQLChain (PropertyValues)

@property (nonatomic, strong, readonly) DBSQLChain *(^limit)(NSUInteger limit);
@property (nonatomic, strong, readonly) DBSQLChain *(^offset)(NSInteger offset);
@property (nonatomic, strong, readonly) DBSQLChain *(^table)(const char *tName);
@property (nonatomic, strong, readonly) DBSQLChain *(^from)(const char *tName);
@property (nonatomic, strong, readonly) DBSQLChain *(^field)(const char *fieldName);
@property (nonatomic, strong, readonly) DBSQLChain *(^count)(const char *fieldName);
@property (nonatomic, strong, readonly) DBSQLChain *(^orderBy)(const char *fieldName);

@end


@interface DBSQLChain (Assist)

/// 逗号
@property (nonatomic, strong, readonly) DBSQLChain *comma;
/// 分号
@property (nonatomic, strong, readonly) DBSQLChain *semicolon;
/// 空格
@property (nonatomic, strong, readonly) DBSQLChain *space;
/// example: append('xxx LIKE yyy')
@property (nonatomic, strong, readonly) DBSQLChain *(^append)(const char *sql, ...);

@end


@interface DBSQLChain (DotSyntaxAdditions)

///// (field1, field2, field3, nil)
//@property (nonatomic, strong, readonly) DBSQLChain *(^fields)(NSString *fields, ...);
//
//@property (nonatomic, strong, readonly) DBSQLChain *(^value)(id value);
///// (value1, value2, value3, nil)
//@property (nonatomic, strong, readonly) DBSQLChain *(^values)(id values, ...);

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
