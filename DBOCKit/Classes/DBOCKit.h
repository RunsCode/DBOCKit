//
//  DBOCKit.h
//  DBOCKit
//
//  Created by WangYajun on 2021/7/5.
//

#import <Foundation/Foundation.h>


#ifdef __OPTIMIZE__
# define NSLog(...) {}
#else
# define NSLog(...) NSLog(__VA_ARGS__)
#endif
