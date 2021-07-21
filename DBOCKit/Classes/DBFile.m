//
//  DBFile.m
//  DBOCKit
//
//  Created by WangYajun on 2021/5/8.
//

#import "DBFile.h"

@interface DBFile ()

@property (nonatomic, copy) NSString *path;

@end

@implementation DBFile

#ifdef DEBUG
- (void)dealloc {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}
#endif

+ (NSString *)pathWithName:(NSString *)fName directory:(NSString *)dir {
    if (fName.length <= 0) {
        fName = @"DBOC_DEFAULT.db";
    }
    NSString *directory = [self directoryWithName:dir];
    NSString *path = [directory stringByAppendingPathComponent:fName];
    return path;
}

+ (NSString *)directoryWithName:(NSString *)dirName {
    NSString *domains = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSFileManager *manager = [NSFileManager defaultManager];
    if (dirName.length <= 0) {
        domains = [domains stringByAppendingPathComponent:@"DBOC"];
    } else {
        domains = [domains stringByAppendingPathComponent:dirName];
    }
    BOOL isDir;
    BOOL exit = [manager fileExistsAtPath:domains isDirectory:&isDir];
    if (!exit || !isDir) {
        [manager createDirectoryAtPath:domains withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return domains;
}

//path.lastPathComponent
+ (NSArray *)queryIfHadDBFromDirectory:(NSString *)directory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *directoryEnumerator = [fileManager enumeratorAtPath:directory];
    NSMutableArray *filePathArray = [NSMutableArray array];
    NSString *file;
    while((file = [directoryEnumerator nextObject])) {
        if([@[@"db"] containsObject:[file pathExtension]]) {
            [filePathArray addObject:[directory stringByAppendingPathComponent:file]];
        }
    }
    return filePathArray;
}


@end
