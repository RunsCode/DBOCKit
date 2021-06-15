//
//  DBViewController.m
//  DBOCKit
//
//  Created by wyf705064 on 04/26/2021.
//  Copyright (c) 2021 wyf705064. All rights reserved.
//

#import "DBViewController.h"
#import <DBOCKit/string_common.h>
#import <DBOCKit/DBSQLChain.h>
#import <DBOCKit/DBFile.h>
#import <DBOCKit/IMMessage.h>
#import <DBOCKit/NSObject+DBObj.h>
#import <DBOCKit/DBOperatorProtocol.h>
#import <DBOCKit/DBObjectProtocol.h>
#import <DBOCKit/DBOperation.h>
#import <DBOCKit/IMSession.h>
#import <DBOCKit/IMUser.h>
#import <DBOCKit/IMObject.h>

@interface DBViewController ()

@property (nonatomic, strong) NSURL *databaseURL;

@property (nonatomic, strong) DBOperation *operator;

@end

@implementation DBViewController

- (void)viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

//    NSString *sql = [IMMessage dbocDefaultCreateTableSql];
//    NSLog(@"%@", sql);
//    //
//    IMMessage *message = [IMMessage new];
//    @try {
//        [message dbocNonBasicValueTypeClassMap];
//    } @catch (NSException *exception) {
//        NSLog(@"%@", exception);
//    } @finally {
//
////    }
//    NSDictionary *map = [message dbocNonBasicValueTypeClassMap];
//    NSLog(@"%@", map);
}

- (IBAction)onTouchShareDB:(id)sender {
    [self shareWithURL:self.databaseURL];
}

- (IBAction)onCreate:(id)sender {
    [self.operator createTableWithObjClass:IMMessage.class];
}

- (IBAction)onInsert:(id)sender {
    [self.operator insertOrUpdateObj:[self fetchMessage]];
}

- (IBAction)onDelete:(id)sender {

}

- (IBAction)onUpdate:(id)sender {

}

- (IBAction)onSelect:(id)sender {
    NSString *sql = DBSQLChain.select.asterisk.from(IMMessage.dbocTableName.UTF8String).sql;
    NSArray *res1 = [self.operator selectWithSql:sql];
    NSArray *res = [self.operator fecthWithClass:IMMessage.class];
    NSLog(@"");
//    [self.operator selectWithObjClass:IMMessage.class];
}

/// ALTER TABLE tName ADD column_name datatype
/// ALTER TABLE tName DROP COLUMN column_name
/// ALTER TABLE tName ALTER COLUMN column_name datatype
- (IBAction)onAlter:(id)sender {
    const char *tName = IMMessage.dbocTableName.UTF8String;
    NSString *sql = DBSQLChain.alter.table(tName).add("desc text").sql;
//    NSString *sql = DBSQLChain.alter.table(tName).drop.column.field("dayDate").sql;
//    NSString *sql =  DBSQLChain.alter.table(tName).alter.column.field("desc").type("varchar(128)").sql;
    BOOL res = [self.operator executeWithSql:sql];
    NSLog(@"ALTER succed %@", res ? @"YES"  : @"NO");
}

- (IBAction)onDrop:(id)sender {

}

- (IBAction)onCount:(id)sender {
    NSString *sql = DBSQLChain.select.asterisk.from(IMMessage.dbocTableName.UTF8String).sql;
    NSUInteger count = [self.operator countWithSql:sql];
    NSLog(@"查询到 %ld条数据", count);
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
    return _operator;
}

- (IMMessage *)fetchMessage {
    IMMessage *m = [IMMessage new];
    m.time = 214654564.1234;
    m.dateTime = 4546.236;
    m.date = 369.321;
    m.tsObjInt = -23465;
    m.ts = 23465;
    m.ignoreInt = 88888;
    m.ignoreString = @"ignoreString";
    m.session = [IMSession new];
    m.session.sessionId = @"data数据更新";
    m.immutableArray = @[@1, @"2"];
    m.immutableSet = [NSSet setWithArray:@[@3, @"4"]];
    m.immutableDictionary = @{ @"q" : @"hjuikol", @"sss": @"456798"};
    m.mutableArray = @[@1, @"2", @3].mutableCopy;
    m.mutableDictionary = @{ @"q" : @"hjuikol", @"sss": @"456798", @"mutable" : @"mutable"}.mutableCopy;
    m.type = 45;
    m.msgId = @"qwertyuiop4569632178";
    m.fromUser = [IMUser new];
    m.fromUser.nickName = @"大侠01";
    m.fromUser.age = 25;
    m.fromUser.role = 0;
    m.fromUser.sex = 0;
    m.fromUser.avatar = @"asdasdasd";
    m.targetUser = [IMUser new];
    m.targetUser.nickName = @"大侠02";
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
