//
//  NSString+Tool.m
//  DBOCKit
//
//  Created by WangYajun on 2021/6/9.
//

#import "NSString+Tool.h"

@implementation NSString (Tool)

@end

BOOL isAbnormalString(NSString *string) {
    return !string
    || [string isEqual:NSNull.null]
    || (([string isKindOfClass:NSString.class] && [@"" isEqualToString:[string stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet]]) || [@"\"null\"" isEqualToString:string]);
}
