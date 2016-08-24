//
//  VKDevConsole.m
//  VKDebugToolDemo
//
//  Created by Awhisper on 16/8/17.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "VKDevConsoleView.h"

static CGFloat maskAlpha = 0.6f;

@interface VKDevConsoleView ()

@property (nonatomic,strong) UIView *mask;

@end

@implementation VKDevConsoleView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.mask.alpha = 0;
    }
    return self;
}

-(UIView *)mask
{
    if (!_mask) {
        UIView *maskv = [[UIView alloc]initWithFrame:self.bounds];
        maskv.backgroundColor = [UIColor blackColor];
        maskv.alpha = maskAlpha;
        _mask = maskv;
        [self addSubview:maskv];
    }
    return _mask;
}


-(void)showConsole
{
    self.alpha = 0;
    [UIView animateWithDuration:0.5f animations:^{
        self.alpha = 1;
        self.mask.alpha = maskAlpha;
    } completion:^(BOOL finished) {
        
    }];
    
}

-(void)hideConsole
{
    [UIView animateWithDuration:1.0f animations:^{
        self.alpha = 0;
        self.mask.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
