//
//  IMUser.h
//  DBOCKit
//
//  Created by WangYajun on 2021/6/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IMUser : NSObject

@property (nonatomic, assign) NSUInteger age;

@property (nonatomic, assign) NSUInteger sex;

@property (nonatomic, assign) NSUInteger role;

@property (nonatomic, copy) NSString *nickName;

@property (nonatomic, copy) NSString *avatar;

@end

NS_ASSUME_NONNULL_END
