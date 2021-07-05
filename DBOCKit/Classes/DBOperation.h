//
//  DBOperation.h
//  Object_C_Advance
//
//  Created by WangYajun on 2021/4/26.
//  Copyright © 2021 王亚军. All rights reserved.
//

//  基本功能
//
//  链式操作 insert update fetch delete
//  二级子对象自动转换JSON insert update fetch delete

//  扩展功能
//  数据字段监听与观察 类似KVO 


#import <Foundation/Foundation.h>
#import "DBOperatorProtocol.h"


NS_ASSUME_NONNULL_BEGIN

@interface DBOperation : NSObject <DBOperatorProtocol>

- (instancetype)init __attribute__((unavailable("use protocol `DBOperatorProtocol` init method instead")));
+ (instancetype)new __attribute__((unavailable("use protocol `DBOperatorProtocol` init method instead")));

@end

NS_ASSUME_NONNULL_END
