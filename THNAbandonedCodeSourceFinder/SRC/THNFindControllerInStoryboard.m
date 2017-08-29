//
//  THNFindControllerInStoryboard.m
//  THNAbandonedCodeSourceFinder
//
//  Created by ZhangHonglin on 2017/8/26.
//  Copyright © 2017年 h. All rights reserved.
//

#import "THNFindControllerInStoryboard.h"

@implementation THNFindControllerInStoryboard

+ (NSArray *)findStoryboardControllerWithPath:(NSString *)path {
    // 找出本地的.h .m 文件
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF ENDSWITH[c] '.storyboard'"];
    NSArray *filterArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:path error:nil];
    NSArray *subPathArray = [filterArray filteredArrayUsingPredicate:predicate];
    
    
    NSMutableSet *controllerSet = [NSMutableSet set];
    
    for (NSString *subPath in subPathArray) {
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", path, subPath];
        
        if (!filePath || ![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            continue;
        }
        
        NSError *error = nil;
        NSString *fileData = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
        
        if (error) {
            NSLog(@"error : %@", error);
            NSAssert(!error, @"读文件失败");
            continue;
        }
        
        NSArray *lineArray = [fileData componentsSeparatedByString:@"\n"];
        for (NSString *lineString in lineArray) {
            NSString *controller = [self getSubStringFromTarget:lineString start:@" customClass=\"" end:@"\""];
            if (controller) {
                [controllerSet addObject:[controller stringByAppendingString:@".m"]];
            }
        }
    }
    
    return controllerSet.allObjects;
}

// -><viewController id="8Sq-5h-Jhg" customClass="XLLoginOneViewController" sceneMemberID="viewController">

+ (NSString *)getSubStringFromTarget:(NSString *)target start:(NSString *)start end:(NSString *)end {
    
    NSRange startRange = [target rangeOfString:start];
    if (startRange.location == NSNotFound) {
        return nil;
    }
    
    NSUInteger start_end = startRange.location+startRange.length;
    NSRange endRange = [target rangeOfString:end
                                     options:NSLiteralSearch
                                       range:NSMakeRange(start_end, target.length - start_end)];
    
    if (endRange.location == NSNotFound) {
        return nil;
    }
    
    NSRange subRange = NSMakeRange(start_end, endRange.location-start_end);
    NSString *subStr = [target substringWithRange:subRange];
    
    return subStr;
}
@end
