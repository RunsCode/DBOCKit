//
//  IMMessage.h
//  Object_C_Advance
//
//  Created by WangYajun on 2021/4/26.
//  Copyright © 2021 王亚军. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class IMUser;
@class IMSession;
@class IMObject;

@interface IMMessage : NSObject

@property (nonatomic, assign) CGFloat time;

@property (nonatomic, assign) float dateTime;

@property (nonatomic, assign) double date;

@property (nonatomic, assign) NSInteger tsObjInt;

@property (nonatomic, assign) NSUInteger ts;

@property (nonatomic, assign) NSUInteger ignoreInt;

@property (nonatomic, copy) NSString *ignoreString;

@property (nonatomic, copy) NSArray *immutableArray;
@property (nonatomic, copy) NSSet *immutableSet;
@property (nonatomic, copy) NSDictionary *immutableDictionary;

@property (nonatomic, copy) NSMutableArray *mutableArray;
@property (nonatomic, copy) NSMutableDictionary *mutableDictionary;

@property (nonatomic, assign) NSUInteger type;

@property (nonatomic, copy) NSString *msgId;

@property (nonatomic, strong) IMSession *session;

@property (nonatomic, strong) IMUser *fromUser;

@property (nonatomic, strong) IMUser *targetUser;

@property (nonatomic, copy) NSArray<IMObject *> *imObjs;

@end

NS_ASSUME_NONNULL_END
