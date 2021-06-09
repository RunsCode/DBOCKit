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
#import <DBOCKit/IMMessage.h>
#import <DBOCKit/NSObject+DBObj.h>
#import <DBOCKit/DBOperatorProtocol.h>
#import <DBOCKit/DBObjectProtocol.h>

@interface DBViewController ()

@end

@implementation DBViewController

- (void)viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    NSString *sql = [IMMessage dbocDefaultCreateTableSql];
    NSLog(@"%@", sql);
    //
    IMMessage *message = [IMMessage new];
    @try {
        [message dbocCustomObjClassMap];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception);
    } @finally {

    }
    NSDictionary *map = [message dbocCustomObjClassMap];
    NSLog(@"%@", map);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
