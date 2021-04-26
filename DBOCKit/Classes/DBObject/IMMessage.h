//
//  IMMessage.h
//  Object_C_Advance
//
//  Created by WangYajun on 2021/4/26.
//  Copyright © 2021 王亚军. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class IMSession;

@interface IMMessage : NSObject

@property (nonatomic, assign) NSUInteger ts;

@property (nonatomic, assign) NSUInteger type;

@property (nonatomic, copy) NSString *msgId;

@property (nonatomic, strong) IMSession *session;

@end

NS_ASSUME_NONNULL_END
