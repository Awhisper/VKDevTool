//
//  VKTipView.h
//
//  Created by Awhisper on 16/8/7.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VKDevTipView : UIView

+(void)showVKDevTip:(NSString *)msg;

+(void)hideVKDevTip;

+(void)showVKDevTip:(NSString *)msg autoHide:(BOOL)hide;

-(instancetype)initWithMsg:(NSString*)msg;

@end
