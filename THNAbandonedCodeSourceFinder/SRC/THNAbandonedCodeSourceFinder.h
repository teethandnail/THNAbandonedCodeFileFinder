//
//  THNAbandonedCodeSourceFinder.h
//  THNAbandonedCodeSourceFinder
//
//  Created by ZhangHonglin on 2017/8/9.
//  Copyright © 2017年 h. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface THNAbandonedCodeSourceFinder : NSObject

/**
 * 查找弃用的代码文件
 *
 * 原理：entrance.m import a,a import b、c, c import ... ,把这个被import的文件都存放在已用集合里handledSet
 *      找出工程目录 path 下的所有 .h .m 放入存在集合里exitSet
 *      exitSet 与 handledSet 的差集就是废弃的文件集合
 *
 * @param subPathArray 本地文件在工程中的路径
 * @param path 工程的路径
 * @param entranceNameArray 查找的源头文件
 * @return 废弃文件数组
 */
+ (NSArray *)findAbandonedFileWithSubPathArray:(NSArray *)subPathArray path:(NSString *)path entranceNameArray:(NSArray *)entranceNameArray;

@end
