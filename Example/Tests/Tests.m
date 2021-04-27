//
//  DBOCKitTests.m
//  DBOCKitTests
//
//  Created by wyf705064 on 04/26/2021.
//  Copyright (c) 2021 wyf705064. All rights reserved.
//
#include <stdio.h>
#include <stdarg.h>
@import XCTest;
#import <DBOCKit/DBSQLChain.h>
#import <DBOCKit/string_common.h>
// const char * __restrict, ...
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

@implementation Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testFormat {

    //    char *buffer = (char *)malloc(256);
    char buffer[128];
    stringFormatTest(buffer, "%s, %d, %4.4f, %c \n", "str_begin", 465, 454651233.1415789465, 'a');
    printf("=====> %s", buffer);

}

int stringFormatTest(char *dest, const char *fmt, ...) {
    int res;
    va_list ap;
    va_start(ap, fmt);
    res = stringVSNPrintf(dest, fmt, ap);
    va_end(ap);
    return res;
}

- (void)testMutableCopyCat {
    char *res = mutableCopyCat("123", "abc", "iop", NULL);
    XCTAssertTrue(strcmp("123abciop", res) == 0, @"7777777 failed");

}

- (void)testExample {

    char *res = immutableCopyCat(" `data` %@%@%@%@ == ", "hello");
    XCTAssertTrue(strcmp(" `data` %@%@%@%@ == hello", res) == 0, @"11111 failed");
    //
    res = immutableCopyCat(res, "world");
    XCTAssertTrue(strcmp(" `data` %@%@%@%@ == helloworld", res) == 0, @"2222222 failed");
}

- (void)testOCString {
    NSString *ocs = @"%@%d%f 123ert `//\\#*%%%%`";
    const char *cstr = ocs.UTF8String;
    char *res = immutableCopyCat(cstr, "hello");
    XCTAssertTrue(strcmp("%@%d%f 123ert `//\\#*%%%%`hello", res) == 0, @"6666666 failed");
}

- (void)testBeforeNULL {
    char *before = NULL;
    char *res = immutableCopyCat(before, "hello");
    printf("----> %s \n", res);
    XCTAssertTrue(strcmp("", res) == 0, @"3333333 failed");
}

- (void)testAfterNULL {
    char *after = NULL;
    char *res = immutableCopyCat("before", after);
    printf("----> %s \n", res);
    XCTAssertTrue(strcmp("before", res) == 0, @"444444 failed");
}

- (void)testAfterLengthZero {
    char *after = "";
    char *res = immutableCopyCat("before", after);
    printf("----> %s \n", res);
    XCTAssertTrue(strcmp("before", res) == 0, @"555555 failed");
}

@end

