//
//  ViewController.m
//  THNAbandonedCodeSourceFinder
//
//  Created by ZhangHonglin on 2017/8/8.
//  Copyright © 2017年 h. All rights reserved.
//

#import "ViewController.h"
#import "THNAbandonedCodeSourceFinder.h"
#import "THNFindControllerInStoryboard.h"

@interface ViewController ()

@property (nonatomic, weak) IBOutlet NSTextField *pathTextField;
@property (nonatomic, weak) IBOutlet NSTextField *fileTextField;
@property (nonatomic, weak) IBOutlet NSTextView *resultTextView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *entranceArray = @[// 主入口
                               @"CHDAppDelegate.m",
                               // .pch 工程未使用，不需加入
                               // iPad .plist 动态调用的支付方式
                               @"XKSPaymentCashView.m",
                               @"XKSPaymentAlibabaWeixinPayView.m",
                               @"XKSPaymentAlibabaWeixinPayView.m",
                               @"XKSPaymentBankCardPayView.m",
                               @"XKSPaymentBankCardPayView.m",
                               @"XKSPaymentBankCardPayView.m",
                               @"XKSPaymentCashView.m",
                               @"XKSPaymentPrepaidCardView.m",
                               @"XKSPaymentLightningPayView.m",
                               @"XKSPaymentVoucherView.m",
                               @"XKSPaymentOtherPayView.m",
                               @"XKSPaymentBankCardPayView.m",
                               @"XKSPaymentRechargeCardView.m",
                               // iPhone .plist 动态调用的支付方式
                               @"XKSPaymentAlibabaWXPayViewController_iPhone.m",
                               @"XKSPaymentAlibabaWXPayViewController_iPhone.m",
                               @"XKSPaymentBankCardViewController_iPhone.m",
                               @"XKSPaymentBankCardViewController_iPhone.m",
                               @"XKSPaymentBankCardViewController_iPhone.m",
                               @"XKSPaymentPrepaidCardViewController_iPhone.m",
                               @"XKSPaymentVoucherViewController_iPhone.m",
                               @"XKSPaymentOtherViewController_iPhone.m",
                               @"XKSPaymentBankCardViewController_iPhone.m"
                               ];
    
    [self.pathTextField setStringValue:@"/Users/HongLin/Desktop/codeTmp/LanSynergism"];
    [self.fileTextField setStringValue:[entranceArray componentsJoinedByString:@";"]];
    self.resultTextView.string = @"";
    self.resultTextView.editable = NO;
}

- (IBAction)clickButton:(NSButton*)sender {
    
    NSDate *beginDate = [NSDate date];
    self.resultTextView.string = @"";
    
    NSString *path = self.pathTextField.stringValue;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        self.resultTextView.string = @"路径不存在";
        return;
    }
    
    // 找出本地的.h .m 文件
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF ENDSWITH[c] '.h') OR (SELF ENDSWITH[c] '.m')"];
    NSArray *filterArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:path error:nil];
    NSArray *subPathArray = [filterArray filteredArrayUsingPredicate:predicate];
    
    // 本地有重名文件会影响结果，所以查询前最好先运行此检测函数，看看有哪些重名文件
    //[self checkLocalDuplicateNameFileWithSubPathArray:subPathArray];
    //return;
    
    // 主入口+动态配置的入口
    NSArray *entranceNameArray = [self.fileTextField.stringValue componentsSeparatedByString:@";"];
    // storyboard中的入口
    NSArray *storyboardVCArray = [THNFindControllerInStoryboard findStoryboardControllerWithPath:path];
    NSMutableArray *unionEntranceArray = [NSMutableArray arrayWithArray:entranceNameArray];
    [unionEntranceArray addObjectsFromArray:storyboardVCArray];
    
    NSArray *localPathArray = [THNAbandonedCodeSourceFinder findAbandonedFileWithSubPathArray:subPathArray path:path entranceNameArray:unionEntranceArray];
    
    CGFloat runTime = [NSDate date].timeIntervalSince1970 - beginDate.timeIntervalSince1970;
    NSString *resultTestStr = [NSString stringWithFormat:@"本地文件数[%zi],运算耗时[%.3lf秒]",  subPathArray.count, runTime];
    self.resultTextView.string = [NSString stringWithFormat:@"废弃文件个数 [%zi], %@:\n%@", localPathArray.count, resultTestStr, localPathArray];
}


#pragma mark - 检测是否有重名文件

//! 检测重名文件，工程用到了该重名的文件，则手动删除重复文件，未用到该重名文件，可以不处理
- (NSDictionary *)checkLocalDuplicateNameFileWithSubPathArray:(NSArray *)subPathArray {
    
    NSMutableDictionary *mutDic = [NSMutableDictionary dictionary];
    for (NSString *subPath in subPathArray) {
        NSString *name = [subPath componentsSeparatedByString:@"/"].lastObject;
        NSMutableArray *nameArray = mutDic[name];
        
        if (!nameArray) {
            nameArray = [NSMutableArray array];
            [mutDic setObject:nameArray forKey:name];
        }
        
        [nameArray addObject:subPath];
    }
    
    NSArray *allkeys = mutDic.allKeys;
    for (NSString *key in allkeys) {
        NSArray *nameArray = mutDic[key];
        if (nameArray.count <= 1) {
            [mutDic removeObjectForKey:key];
        }
    }
    
    return mutDic;
}

@end
