//
//  DBViewController.m
//  DBOCKit
//
//  Created by wyf705064 on 04/26/2021.
//  Copyright (c) 2021 wyf705064. All rights reserved.
//

#import "DBViewController.h"
#import "IMSession.h"
#import "IMUser.h"
#import "IMObject.h"
#import "IMMessage.h"
#import <DBOCKit/DBOCCString.h>
#import <DBOCKit/DBSQLChain.h>
#import <DBOCKit/DBFile.h>
#import <DBOCKit/NSObject+DBObj.h>
#import <DBOCKit/DBOperatorProtocol.h>
#import <DBOCKit/DBObjectProtocol.h>
#import <DBOCKit/DBOperation.h>
#import <DBOCKit/DBObserverProtocol.h>

@interface DBViewController ()<DBObserverProtocol>

@property (nonatomic, strong) NSURL *databaseURL;

@property (nonatomic, strong) DBOperation *operator;

@end

@implementation DBViewController

- (void)viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}


- (NSArray<Class> *)observeObjClassArray {
    return @[
        IMMessage.class,
        IMSession.class,
        IMObject.class,
        IMUser.class,
    ];
}
- (void)updateClass:(Class)cls withObj:(id<DBObjectProtocol>)obj {
    NSString *tName = [cls dbocTableName];
    NSLog(@"OCDB:VC  updateClass table: %@, obj: %@", tName, obj);
}

- (void)updateTable:(NSString *)tName withObj:(id<DBObjectProtocol>)obj newTableCount:(NSUInteger)count {
    NSLog(@"OCDB:VC  updateTable table: %@, count: %lu, obj: %@", tName, (unsigned long)count, obj);
}

- (IBAction)onTouchShareDB:(id)sender {
    [self shareWithURL:self.databaseURL];
}

- (IBAction)onCreate:(id)sender {
    [self.operator createTableWithObjClass:IMMessage.class];
    [self.operator createTableWithObjClass:IMUser.class];
    [self.operator createTableWithObjClass:IMSession.class];
//    [self.operator createTableWithObjClass:IMObject.class];
}
/***
 INSERT INTO t_im_meessage (time, ts, mutableDictionary, imObjs, addType1, immutableSet, dateTime, type, immutableDictionary, immutableArray, date, mutableArray, session, originData, addType2, fromUser, msgId, targetUser, tsObjInt, addType0) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);*/
- (IBAction)onInsert:(id)sender {
    [self.operator insertOrUpdateObj:[self fetchMessage]];

    NSString *sql = [NSString stringWithFormat:@"INSERT INTO t_im_meessage (time, ts) VALUES (3.141692654, 9876543210);"];
    [self.operator executeWithSql:sql];

    NSArray *arr = @[self.fetchMessage, self.fetchMessage, self.fetchMessage];
    [self.operator insertOrUpdateObjs:arr];
}

- (IBAction)onDelete:(id)sender {
    NSArray *res = [self.operator fecthWithClass:IMMessage.class];
    NSMutableArray *array = [NSMutableArray arrayWithArray:res];
    NSArray *arr = [array subarrayWithRange:(NSRange){0, 5}];
    [self.operator deleteObjs:arr];
//    [self.operator deleteObj:res.lastObject];

    NSString *tName = [IMMessage.class dbocTableName];
//    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE primaryKeyId='4'", tName];
//    [self.operator executeWithSql:sql];

    NSString *sql = DBSQLChain.delete.from(tName.UTF8String).where("primaryKeyId='4'").sql;
    [self.operator executeWithSql:sql];

}

- (IBAction)onUpdate:(id)sender {
    NSArray<IMMessage *> *res = [self.operator fecthWithClass:IMMessage.class];
    [self.operator insertOrUpdateObjs:res];

//    m.ts = 100086;
//    m.addType0 = 10010;
//    m.msgId = @"?????????????????????";
//    [self.operator insertOrUpdateObj:m];
//    NSString *sql = @"UPDATE t_im_meessage SET time=2222222, ts=7777777, addType0=88888888 WHERE primaryKeyId=1;";
//    [self.operator updateSql:sql observable:m];
    const char *tName = IMMessage.class.dbocTableName.UTF8String;
    DBSQLChain.update.table(tName).set("time=2222222, ts=7777777").where("primaryKeyId=1");
}

- (IBAction)onSelect:(id)sender {
    NSString *sql = DBSQLChain.select.asterisk.from(IMMessage.dbocTableName.UTF8String).sql;
    NSArray *res1 = [self.operator selectWithSql:sql];
    NSArray *res = [self.operator fecthWithClass:IMMessage.class];
    NSLog(@"onSelect Over");
}

/// ALTER TABLE tName ADD column_name datatype
/// ALTER TABLE tName DROP COLUMN column_name ?????????
/// ALTER TABLE tName ALTER COLUMN column_name datatype ?????????
- (IBAction)onAlter:(id)sender {
    const char *tName = IMMessage.dbocTableName.UTF8String;
    NSString *sql = DBSQLChain.alter.table(tName).add("desc text").sql;
//    NSString *sql = DBSQLChain.alter.table(tName).drop.column.field("dayDate").sql;
//    NSString *sql =  DBSQLChain.alter.table(tName).alter.column.field("desc").type("varchar(128)").sql;
    BOOL res = [self.operator executeWithSql:sql];
    NSLog(@"ALTER succed %@", res ? @"YES"  : @"NO");
}

- (IBAction)onDrop:(id)sender {
    NSString *sql = DBSQLChain.drop.table(IMSession.dbocTableName.UTF8String).sql;
    BOOL res = [self.operator executeWithSql:sql];
    NSLog(@"DROP succed %@", res ? @"YES"  : @"NO");
}

- (IBAction)onCount:(id)sender {
    NSString *sql = DBSQLChain.select.count(nil).from(IMMessage.dbocTableName.UTF8String).sql;
    NSUInteger count = [self.operator countWithSql:sql];
    NSLog(@"????????? %lu?????????", (unsigned long)count);
}

- (void)shareWithURL:(NSURL *)url {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:url.path]) {
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
        [self presentViewController:activityViewController animated:YES completion:NULL];
    }
}

- (NSURL *)databaseURL {
    if (_databaseURL) return _databaseURL;
    NSString *path = [DBFile pathWithName:nil directory:nil];
    _databaseURL = [NSURL fileURLWithPath:path isDirectory:NO];
    return _databaseURL;
}

- (DBOperation *)operator {
    if (_operator) return _operator;
    //
    _operator = [[DBOperation alloc] initWithDBURL:self.databaseURL];
    [_operator addObserver:self];
    return _operator;
}

- (IMMessage *)fetchMessage {
    IMMessage *m = [IMMessage new];
    m.time = 214654564.1234;
    m.dateTime = NSDate.date.timeIntervalSince1970;
    m.date = 369.321;
    m.tsObjInt = -23465;
    m.ts = (NSUInteger)NSDate.date.timeIntervalSince1970;
    m.ignoreInt = 88888;
    m.ignoreString = @"ignoreString";
    m.session = [IMSession new];
    m.session.sessionId = @"data????????????";
    m.immutableArray = @[@1, @"2"];
    m.immutableSet = [NSSet setWithArray:@[@3, @"4"]];
    m.immutableDictionary = @{ @"q" : @"hjuikol", @"sss": @"456798"};
    m.mutableArray = @[@1, @"2", @3].mutableCopy;
    m.mutableDictionary = @{ @"q" : @"hjuikol", @"sss": @"456798", @"mutable" : @"mutable"}.mutableCopy;
    m.type = 45;
    m.msgId = @"qwertyuiop4569632178";
    m.fromUser = [IMUser new];
    m.fromUser.nickName = @"??????01";
    m.fromUser.age = 25;
    m.fromUser.role = 0;
    m.fromUser.sex = 0;
    m.fromUser.avatar = @"asdasdasd";
    m.targetUser = [IMUser new];
    m.targetUser.nickName = @"??????02";
    m.targetUser.age = 48;
    m.targetUser.role = 1;
    m.targetUser.sex = 0;
    m.targetUser.avatar = @"database";
    m.originData = [NSData dataWithContentsOfURL:self.databaseURL];

    IMObject *obj0 = [IMObject new];
    obj0.text = @"IMObject";
    IMObject *obj1 = [IMObject new];
    obj1.text = @"IMObject 1";
    IMObject *obj2 = [IMObject new];
    obj2.text = @"IMObject 2";
    m.imObjs = @[obj0, obj1, obj2];
//    m.primaryKeyId = 10086;
    return m;
}

@end
