//
//  DBOCKitTests.m
//  DBOCKitTests
//
//  Created by wyf705064 on 04/26/2021.
//  Copyright (c) 2021 wyf705064. All rights reserved.
//
#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#import <DBOCKit/string_common.h>
#import <DBOCKit/DBSQLChain.h>
#import <DBOCKit/IMMessage.h>
#import <DBOCKit/IMSession.h>
#import <DBOCKit/NSObject+DBObj.h>
#import <DBOCKit/IMObject.h>
#import <DBOCKit/DBObjectProtocol.h>

@import XCTest;



void char_format(char *source, const char *fmt, ...) {
    va_list ap;
    va_start(ap,fmt);
    vsprintf(source, fmt, ap);
    va_end(ap);
    printf("==> %s \n", source);
}

char *char_format1(const char *fmt, ...) {
    va_list ap;
    va_start(ap,fmt);
    size_t size = strlen(fmt) + sizeof(ap) + 1;
    char *source = (char *)malloc(size);
    vsprintf(source, fmt, ap);
    va_end(ap);
    printf("==> %s \n", source);
    return source;
}

@interface Tests : XCTestCase

@end

const size_t MAX_BUFFER_SIZE = 128;


@implementation Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.

}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDiffArray {
    NSArray *arr1 = @[@1, @"2", @3, @4, @"5"];
    NSArray *arr2 = @[@4, @"5"];
    NSOrderedCollectionDifference *coll = [arr1 differenceFromArray:arr2];
    NSArray *res = [NSArray.new arrayByApplyingDifference:coll];
    NSLog(@"");
}

- (void)testInsertSql {
    IMMessage *m = [IMMessage new];
    m.time = 214654564.1234;
    m.dateTime = 4546.236;
    m.date = 369.321;
    m.tsObjInt = -23465;
    m.ts = 23465;
    m.ignoreInt = 88888;
    m.session = [IMSession new];
    m.session.sessionId = @"qwetyyyyy1111";
    m.immutableArray = @[@1, @"2"];
    m.immutableSet = @[@3, @"4"];

    NSString *res = [m dbocInsertSql];
    NSLog(@"%@", res);
}

- (void)testStrcmp {
    char buffer[9] = "NSString";
    int res = strcmp(buffer, "NSString");
    NSLog(@"%d", res);
}

- (void)testCStringSplit {
    char dest[11] = {0};
    char *testStr = "T@\"IMUser\",C,N,V_msgId";
    StringSplit(testStr, dest, "\"", 1);
    printf("des = %s \n", dest);
}

- (void)testCustomObjClassMap {
    NSDictionary *map = [IMMessage.new dbocCustomObjClassMap];
    NSLog(@"%@", map);
}

- (void)testDefaultCreateTableSql{
    NSString *sql = [IMMessage dbocDefaultCreateTableSql];
    NSLog(@"%@", sql);
}

- (void)testCategoryExt {
    IMObject *obj = [IMObject new];
    NSString *hello = [(id<DBObjectProtocol>)obj dbocInsertSql];
    NSString *word = [(id<DBObjectProtocol>)obj dbocUpdateSql];
    NSLog(@"%@, %@", hello, word);
}


- (void)testFormat {

    //    char *buffer = (char *)malloc(256);
//    char buffer[128];
//    stringFormatTest(buffer, "%s, %d, %4.4f, %c \n", "str_begin", 465, 454651233.1415789465, 'a');
//    printf("=====> %s", buffer);

}

int stringFormatTest(char *dest, const char *fmt, ...) {
    int res;
    va_list ap;
    va_start(ap, fmt);
    res = StringVSNPrintf(dest, fmt, ap);
    va_end(ap);
    return res;
}

- (void)testSNPrintf {
    char *fieldName = "very_long_long_long_field";
    char *fmt = "COUNT( `%s` ) ";
    size_t s = strlen(fmt) + strlen(fieldName) - 1;
    char buffer[512];
    int res = snprintf(buffer, s, fmt, fieldName);
    printf("------> buffer = %s, res = %d \n", buffer, res);
}

- (void)testMutableCopyCat {
    char *res = MutableMemoryCopy("123", "abc", "iop", NULL);
    XCTAssertTrue(strcmp("123abciop", res) == 0, @"7777777 failed");
}

- (void)testCopyCatDest {
    char *hw = "Hello World";

//    for (int i = 0; i < 100; i++) {
        char buffer[1024] = { 0 };
        memcpy(buffer, hw, strlen(hw));
        printf("====> buffer ==>%s\n", buffer);
        XCTAssertTrue(strcmp("Hello World", buffer) == 0, @"Hello World failed");

        MutableMemoryCopyDest(buffer, " `123`", "   "," iop", " %@￥#%￥&……（*::::\"""“《》？！~", NULL);
        printf("====> buffer ==>%s\n", buffer);
        XCTAssertTrue(strcmp("Hello World `123`    iop %@￥#%￥&……（*::::\"""“《》？！~", buffer) == 0, @"Hello World 123 iop failed");

        char *res = MutableMemoryCopy("Hello `World`", "   ", " 123", " iop %@￥#%￥&……（*：“《》？！~", NULL);
        printf("====> res    ==>%s\n", res);
        XCTAssertTrue(strcmp("Hello `World`    123 iop %@￥#%￥&……（*：“《》？！~", res) == 0, @"Hello World 123 iop failed");
        free(res);
//    }
}

- (void)testMemcpy {

    char a[] = "aa";
    char b[] = "bb";
    char c[] = "cc";
    char temp[128];// = {0};

    memcpy(temp, a, strlen(a));
    printf("temp = %s len = %lu \n", temp, strlen(temp));

    memcpy(temp + strlen(a), b, strlen(b));
    printf("temp = %s len = %lu \n", temp, strlen(temp));
    
    memcpy(temp + strlen(a) + strlen(c), c, strlen(c));
    printf("temp = %s len = %lu \n", temp, strlen(temp));

}

- (void)testMemmove {
    char c[128] = "aabbcc";
    const char* a = "aa";
    const char* b = "bb";
    size_t sza = strlen(a);
    size_t szb = strlen(b);
    memmove(c, a, sza);
    memmove(c + sza, b, szb);
    c[sza + szb] = 0;
    printf("a = %s, b = %s, c = %s \n", a, b , c);
}

@end

