//
//  DBChainUnitTest.m
//  DBOCKit_Tests
//
//  Created by WangYajun on 2021/4/29.
//  Copyright © 2021 wyf705064. All rights reserved.
//

#import <XCTest/XCTest.h>
//#import <DBOCKit/string_common.h>
#import <DBOCKit/DBSQLChain.h>

@interface DBChainUnitTest : XCTestCase

@end

@implementation DBChainUnitTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testCreate {
    printf("--------------------------------\n");
    DBSQLChain *chain = DBSQLChain.create.tableC("t_hello_im_message").space
    .appendC("( pk integer PRIMARY KEY AUTOINCREMENT NOT NULL DEFAULT(0), ")
    .appendC("userGuid varchar(64), nickName varchar(32), realName varchar(16) )");
    const char *result = chain.sql.UTF8String;
    printf("CHAIN CREATE sql : \n\n%s \n\n", result);
    printf("--------------------------------\n");
}

- (void)testSelect {
    printf("--------------------------------\n");
    DBSQLChain *chain = DBSQLChain.select.fieldC("nickName").space
    .fromC("t_hello_im_message")
    .whereC("age = %ld", 18)
    .andC("sex = %ld", 1)
    .andC("(weight = %ld OR weight = %ld)", 180, 120)
    .orderByC("pk").desc.limit(10).offset(5);
    const char *result = chain.sql.UTF8String;
    printf("CHAIN UPDATE sql : \n\n%s \n\n", result);
    printf("--------------------------------\n");

}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
