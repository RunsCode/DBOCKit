//
//  IMMessage.m
//  Object_C_Advance
//
//  Created by WangYajun on 2021/4/26.
//  Copyright © 2021 王亚军. All rights reserved.
//

#import "IMUser.h"
#import "IMObject.h"
#import "IMMessage.h"
#import "IMSession.h"
#import "DBObjectProtocol.h"
#import <objc/runtime.h>
/** SQLite五种数据类型 */
#define SQLTEXT     @"TEXT"
#define SQLDOUBLE   @"DOUBLE"
#define SQLINTEGER  @"INTEGER"
#define SQLREAL     @"REAL"
#define SQLBLOB     @"BLOB"
#define SQLNULL     @"NULL"
#define PrimaryKey  @"primary key"

#define primaryId   @"pk"
@interface IMMessage () <DBObjectProtocol>

@end

@implementation IMMessage

#ifdef DEBUG
- (void)dealloc {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}
#endif


+ (NSString *)tableName {
    return @"t_im_meessage";
}

+ (NSArray<NSString *> *)ignoreTheFields {
    return @[
        NSStringFromSelector(@selector(ignoreInt)),
        NSStringFromSelector(@selector(ignoreString))
    ];
}

+ (NSDictionary<NSString *,Class> *)arrayElementtFiledMapping {
    return @{
        NSStringFromSelector(@selector(imObjs)): IMObject.class,
    };
}

- (void)didFinishConvertToObjByOperation:(id<DBOperatorProtocol>)operater {

}

- (void)didFinishConvertToJSONStringByOperation:(id<DBOperatorProtocol>)operater {
    
}

@end
