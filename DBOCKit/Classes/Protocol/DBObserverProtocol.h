//
//  DBOperationDelegate.h
//  Object_C_Advance
//
//  Created by WangYajun on 2021/4/26.
//  Copyright © 2021 王亚军. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DBOperatorProtocol;

NS_ASSUME_NONNULL_BEGIN

@protocol DBObserverProtocol <NSObject>

@required
- (NSArray<Class> *)observeObjClassArray;

- (void)updateClass:(Class)cls withObj:(id)obj;

@end

NS_ASSUME_NONNULL_END
