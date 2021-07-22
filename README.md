# DBOCKit

[![Version](https://img.shields.io/cocoapods/v/DBOCKit.svg?style=flat)](https://cocoapods.org/pods/DBOCKit)
[![License](https://img.shields.io/cocoapods/l/DBOCKit.svg?style=flat)](https://cocoapods.org/pods/DBOCKit)
[![Platform](https://img.shields.io/cocoapods/p/DBOCKit.svg?style=flat)](https://cocoapods.org/pods/DBOCKit)


To run the example project, clone the repo, and run `pod install` from the Example directory first.
Based on FMDB

**几个目的:**
> 使用链式语法生成sql，不用写硬编码的sql，一行代码建表
> 像操作JSON一样简单，直接增删改查模型，可直接字典转模型，二级字典转模型
> 数据库的增删改查可被监听观察，回调给需要的对象

**There are several main purposes for writing this code:**
> Use chain syntax to generate sql, no need to write hard-coded sql, one line of code to build a table.
> It is as simple as operating JSON, directly adding, deleting, modifying and querying models, direct dictionary-to-model, secondary dictionary-to-model
> Database additions, deletions, and changes can be monitored and observed, and callbacks can be made to the required objects

## Usage


#### Init db operator
---
```objectivec
- (DBOperation *)operator {
    if (_operator) return _operator;
    //
    NSString *path = [DBFile pathWithName:<#your db name#> directory:<#your db dir#>];
    NSURL *url = [NSURL fileURLWithPath:path isDirectory:NO];
    _operator = [[DBOperation alloc] initWithDBURL:url];
    // DBObserverProtocol
    [_operator addObserver:self];
    return _operator;
}

// Observer if you need
- (NSArray<Class> *)observeObjClassArray {
    return @[ IMMessage.class ];
}

/// When a row of data in the table is updated, it will notify the monitoring object of that class
- (void)updateClass:(Class)cls withObj:(id<DBObjectProtocol>)obj {
    NSString *tName = [cls dbocTableName];
    NSLog(@"OCDB:VC  updateClass table: %@, obj: %@", tName, obj);
}

/// When a row of data in the table is inserted or deleted, 
/// it will notify the monitoring object of this class
- (void)updateTable:(NSString *)tName withObj:(id<DBObjectProtocol>)obj newTableCount:(NSUInteger)count {
    NSLog(@"OCDB:VC  updateTable table: %@, count: %lu, obj: %@", tName, (unsigned long)count, obj);
}
```

#### Create DB
---
```objectivec
@implementation IMMessage

/// If you want to customize the name of the table, you must implement this method,
/// otherwise the name of the table is the class name by default
+ (NSString *)tableName {
   return @"t_im_message";
}

// Like MJExtension
+ (NSArray<NSString *> *)ignoreTheFields {
    return @[
        NSStringFromSelector(@selector(ignoreInt)),
        NSStringFromSelector(@selector(ignoreString))
    ];
}

// Like MJExtension
+ (NSDictionary<NSString *,Class> *)arrayElementtFiledMapping {
    return @{ NSStringFromSelector(@selector(imObjs)): IMObject.class };
}
@end
... ...
// Use Class to directly build a table
[self.operator createTableWithObjClass:IMMessage.class];
```

#### DB operation
---
##### Insert 
```swift
//0. Use class
IMMessage *message = ...;
[self.operator insertOrUpdateObj:message];

//1. Use sql
NSString *sql = [NSString stringWithFormat:@"INSERT INTO t_im_meessage (xxx, yyy) VALUES (aaa, bbb);"];
[self.operator executeWithSql:sql];

//2. Use array
NSArray *arr = @[message_0, message_1, message_2];
[self.operator insertOrUpdateObjs:arr];
```

##### Delete
```objectivec
// 0. Delete a single object
[self.operator deleteObj:obj];

// 1. Delete a group of objects
[self.operator deleteObjs:@[obj_0, obj_1]];

// 2. Use DBSQLChain sql
char *tName = [IMMessage.class dbocTableName];
NSString *sql = DBSQLChain.delete.from(tName).where("primaryKeyId='4'").sql;
[self.operator executeWithSql:sql];

```

##### Update
```swift
// 0. Update a single object
[self.operator insertOrUpdateObj:obj];

// 1. Update a group of objects
[self.operator insertOrUpdateObjs:arrayObj];

// 2. Use DBSQLChain sql
const char *tName = IMMessage.class.dbocTableName.UTF8String;
NSString *sql = DBSQLChain.update.table(tName).set("time=2222222, ts=7777777").where("primaryKeyId=1");
[self.operator updateSql:sql observable:m];
```

##### Select
```objectivec
// 0. Use DBSQLChain sql
NSString *sql = DBSQLChain.select.asterisk.from(IMMessage.dbocTableName.UTF8String).sql;
NSArray *res1 = [self.operator selectWithSql:sql];

// 1. Use class
NSArray *res = [self.operator selectObjClass:IMMessage.class];
```

##### Alter
```swift
// Use DBSQLChain sql
const char *tName = IMMessage.dbocTableName.UTF8String;
NSString *sql = DBSQLChain.alter.table(tName).add("desc text").sql;
NSString *sql = DBSQLChain.alter.table(tName).drop.column.field("dayDate").sql;
NSString *sql = DBSQLChain.alter.table(tName).alter.column.field("desc").type("varchar(128)").sql;
BOOL res = [self.operator executeWithSql:sql];
```

##### Drop
```swift
// Use DBSQLChain sql
NSString *sql = DBSQLChain.drop.table(IMSession.dbocTableName.UTF8String).sql;
BOOL res = [self.operator executeWithSql:sql];
```

##### Count
```swift
// 0.Use DBSQLChain sql, nil: default count(*)
NSString *sql = DBSQLChain.select.count(nil).from(IMMessage.dbocTableName.UTF8String).sql;
NSUInteger count = [self.operator countWithSql:sql];

// 1. Use class
BOOL res = [self.operator countOfTable:IMSession.dbocTableName];
```


#### The chain of grammar 链式语法
```objectivec
@interface DBSQLChain (MainAction)
@property (nonatomic, strong, class, readonly) DBSQLChain *create;
@property (nonatomic, strong, class, readonly) DBSQLChain *drop;
@property (nonatomic, strong, class, readonly) DBSQLChain *alter;
@property (nonatomic, strong, class, readonly) DBSQLChain *insert;
@property (nonatomic, strong, class, readonly) DBSQLChain *delete;
@property (nonatomic, strong, class, readonly) DBSQLChain *update;
@property (nonatomic, strong, class, readonly) DBSQLChain *select;
@end
```

##### Example
* Create sql
    ```objectivec
 DBSQLChain *chain = DBSQLChain.create.table("t_hello_im_message").space
	.append("( pk integer PRIMARY KEY AUTOINCREMENT NOT NULL DEFAULT(0), ")
	.append("userGuid varchar(64), nickName varchar(32), realName varchar(16) )");
const char *result = chain.sql.UTF8String;
    ```
    
* Select sql
    ```objectivec
DBSQLChain *chain = DBSQLChain.select.field("nickName").space
	.from("t_hello_im_message")
	.where("age = %ld", 18)
	.and("sex = %ld", 1)
	.and("(weight = %ld OR weight = %ld)", 180, 120)
	.orderBy("pk").desc.limit(10).offset(5);
const char *result = chain.sql.UTF8String;
    ```



## Requirements
```ruby
s.dependency 'FMDB'
s.dependency 'MJExtension'
```

## Installation

DBOCKit is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'DBOCKit'
```

## Author

runs.wang.dev@gmail.com

## License

DBOCKit is available under the MIT license. See the LICENSE file for more info.
