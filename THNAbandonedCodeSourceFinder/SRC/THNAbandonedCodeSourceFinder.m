//
//  THNAbandonedCodeSourceFinder.m
//  THNAbandonedCodeSourceFinder
//
//  Created by ZhangHonglin on 2017/8/9.
//  Copyright © 2017年 h. All rights reserved.
//

#import "THNAbandonedCodeSourceFinder.h"

@implementation THNAbandonedCodeSourceFinder

+ (NSArray *)findAbandonedFileWithSubPathArray:(NSArray *)subPathArray path:(NSString *)path entranceNameArray:(NSArray *)entranceNameArray {
    
    // 获取路径信息
    NSArray *pathInfoArray = [self getPathInfoWithSubPathArray:subPathArray path:path];
    
    // key:文件名 value:文件完整路径
    NSMutableDictionary *nameToFullPathDic = pathInfoArray[0];
    // key:文件名 value:短路径
    NSMutableDictionary *nameToSubPathDic = pathInfoArray[1];
    // 文件名数组
    NSArray *localShortNameArray = pathInfoArray[2];
    
    // 待处理的文件
    NSMutableArray *handlingNameArray = [NSMutableArray arrayWithArray:entranceNameArray];
    // 已处理过的文件
    NSMutableSet *handledNameSet = [NSMutableSet set];
    
    while (handlingNameArray.count > 0) {
        
        NSString *fileName = handlingNameArray.firstObject;
        [handlingNameArray removeObject:fileName];
        [handledNameSet addObject:fileName];
        
        NSString *filePath = nameToFullPathDic[fileName];
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
            NSString *fileName_h = [self getImportFileFromLineString:lineString];
            if (fileName_h && [fileName_h containsString:@".h"]) {
                NSString *fileName_m = [fileName_h stringByReplacingOccurrencesOfString:@".h" withString:@".m"];
                
                if (![handledNameSet containsObject:fileName_h]) {
                    [handlingNameArray addObject:fileName_h];
                }
                
                if (![handledNameSet containsObject:fileName_m]) {
                    [handlingNameArray addObject:fileName_m];
                }
            }
        }
    }
    
    NSMutableSet *localSet = [NSMutableSet setWithArray:localShortNameArray];
    NSMutableSet *codeImportSet = [NSMutableSet setWithSet:handledNameSet];
    
    // 本地文件跟被引用文件的差集就是被废弃的文件
    [localSet minusSet:codeImportSet];
    
    // 显示fileName.h fileName.m路径
    NSArray *localPathArray = [self getLocalSubPathArrayWithNameSet:localSet nameToSubPathDic:nameToSubPathDic];
    
    return localPathArray;
}

//! 获取该行#import的文件
+ (NSString *)getImportFileFromLineString:(NSString *)lineStr {
    
    NSString *import = @"#import";
    if ([lineStr containsString:import]) {
        
        // 行首去空格
        lineStr = [lineStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *startPart = [lineStr substringToIndex:import.length];
        if (![startPart isEqualToString:import]) {
            return nil;
        }
        
        // 获取"model/file.h"和<model/file.h>
        NSArray *components = [lineStr componentsSeparatedByString:@" "];
        for (NSString *item in components) {
            if ([item isEqualToString:import] || [item isEqualToString:@""]) {
                continue;
            } else {
                lineStr = item;
                break;
            }
        }
        
        // 获取 model/file.h 和 model/file.h
        if ([lineStr containsString:@"\""]) {
            lineStr = [lineStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        } else if ([lineStr containsString:@"<"]) {
            lineStr = [lineStr stringByReplacingOccurrencesOfString:@"<" withString:@""];
            lineStr = [lineStr stringByReplacingOccurrencesOfString:@">" withString:@""];
        } else {
            return nil;
        }
        
        // 获取 file.h
        components = [lineStr componentsSeparatedByString:@"/"];
        lineStr = components.lastObject;
        return lineStr;
    }
    
    return nil;
}

//! 获取文件路径等信息
+ (NSArray *)getPathInfoWithSubPathArray:(NSArray *)subPathArray path:(NSString *)path{
    // 完整路径
    NSMutableDictionary *fullPathDic = [NSMutableDictionary dictionary];
    // 局部路径
    NSMutableDictionary *subPathDic = [NSMutableDictionary dictionary];
    // 文件名称
    NSMutableArray *fileNameArray = [NSMutableArray array];
    
    for (NSString *subPath in subPathArray) {
        NSString *fileName = [subPath componentsSeparatedByString:@"/"].lastObject;
        NSString *fullPath = [NSString stringWithFormat:@"%@/%@", path, subPath];
        [fullPathDic setObject:fullPath forKey:fileName];
        [subPathDic setObject:subPath forKey:fileName];
        [fileNameArray addObject:fileName];
    }
    
    return @[fullPathDic, subPathDic, fileNameArray];
}

//! 把文件名数组转换成路径数组
+ (NSArray *)getLocalSubPathArrayWithNameSet:(NSSet *)nameSet nameToSubPathDic:(NSDictionary *)nameToSubPathDic {
    
    NSMutableArray *pathArray = [NSMutableArray array];
    for (NSString *shortName in nameSet) {
        NSString *subPath = nameToSubPathDic[shortName];
        if (subPath) {
            [pathArray addObject:subPath];
            continue;
        }
    }
    
    return pathArray;
}

@end
