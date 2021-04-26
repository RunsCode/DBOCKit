//
//  IMMessage.m
//  Object_C_Advance
//
//  Created by WangYajun on 2021/4/26.
//  Copyright © 2021 王亚军. All rights reserved.
//

#import "IMMessage.h"
#import "DBOperationDelegate.h"

@interface IMMessage () <DBOperationDelegate>

@end

@implementation IMMessage

- (NSString *)tableNameWithOperater:(nonnull id<DBOperaterProtocol>)operater {
    return @"t_im_meessage_001";
}

@end
