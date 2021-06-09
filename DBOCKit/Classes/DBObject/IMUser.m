//
//  IMUser.m
//  DBOCKit
//
//  Created by WangYajun on 2021/6/3.
//

#import "IMUser.h"
#import "DBObjectProtocol.h"

@interface IMUser ()<DBObjectProtocol>

@end

@implementation IMUser

+ (NSString *)tableName {
    return @"t_hello_user";
}

- (void)didFinishConvertToObjByOperation:(id<DBOperatorProtocol>)operater {

}

- (void)didFinishConvertToJSONStringByOperation:(id<DBOperatorProtocol>)operater {

}


@end
