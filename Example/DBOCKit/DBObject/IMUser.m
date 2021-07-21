//
//  IMUser.m
//  DBOCKit
//
//  Created by WangYajun on 2021/6/3.
//

#import "IMUser.h"
#import "DBObjectProtocol.h"
#import "NSObject+DBObj.h"
#import <MJExtension/MJExtension.h>
@interface IMUser ()<DBObjectProtocol>

@end

@implementation IMUser

+ (NSString *)tableName {
    return @"t_hello_user";
}

+ (NSArray *)mj_ignoredPropertyNames {
    return [self.dbocIgnoreFields allObjects];
}

@end
