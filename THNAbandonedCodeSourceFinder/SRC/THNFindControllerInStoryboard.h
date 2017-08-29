//
//  THNFindControllerInStoryboard.h
//  THNAbandonedCodeSourceFinder
//
//  Created by ZhangHonglin on 2017/8/26.
//  Copyright © 2017年 h. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface THNFindControllerInStoryboard : NSObject

+ (NSArray *)findStoryboardControllerWithPath:(NSString *)path;

@end
