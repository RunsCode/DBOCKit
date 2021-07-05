//
//  NSString+DBOCCTool.m
//  DBOCKit
//
//  Created by WangYajun on 2021/6/9.
//

#import "NSString+DBOCCTool.h"

@implementation NSString (DBOCCTool)

@end

BOOL isAbnormalString(NSString *string) {
    return !string
    || [string isEqual:NSNull.null]
    || (([string isKindOfClass:NSString.class] && [@"" isEqualToString:[string stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet]]) || [@"\"null\"" isEqualToString:string]);
}
