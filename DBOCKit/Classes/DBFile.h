//
//  DBFile.h
//  DBOCKit
//
//  Created by WangYajun on 2021/5/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBFile : NSObject

+ (NSString *)pathWithName:(NSString *_Nullable)fName directory:(NSString *_Nullable)dir;

@end

NS_ASSUME_NONNULL_END
