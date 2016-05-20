//
//  VKDebugConsole.m
//  VKDebugConsole
//
//  Created by Awhisper on 16/5/20.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "VKDebugConsole.h"
#import "VKCommonFundation.h"

@interface VKDebugConsole ()<UITextViewDelegate>

@property (nonatomic,weak) id target;

@property (nonatomic,strong) UIView *mask;

@property (nonatomic,strong) UITextView *inputView;

@property (nonatomic,strong) UITextView *outputView;

@end

@implementation VKDebugConsole

#pragma mark construct

-(instancetype)initWithCurrentVC
{
    UIViewController *curVC = [self getCurrentVC];
    return [self initWithTarget:curVC];
}

-(instancetype)initWithTarget:(id)target
{
    self = [self initWithFrame:CGRectMake(0, 0, VK_AppScreenWidth, VK_AppScreenHeight)];
    if (self) {
        self.target = target;
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

-(UIView *)mask
{
    if (!_mask) {
        UIView *maskv = [[UIView alloc]initWithFrame:self.bounds];
        maskv.backgroundColor = [UIColor blackColor];
        maskv.alpha = 0.6;
        _mask = maskv;
        [self addSubview:maskv];
    }
    return _mask;
}

-(UITextView *)inputView
{
    if (!_inputView) {
        UITextView * input = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height/2)];
        _inputView = input;
        input.layer.borderWidth = 1;
        input.layer.borderColor = [UIColor blackColor].CGColor;
        input.delegate = self;
        [self addSubview:input];
    }
    return _inputView;
}

-(UITextView *)outputView
{
    if (!_outputView) {
        UITextView * output = [[UITextView alloc]initWithFrame:CGRectMake(0, self.height*2/3, self.width, self.height/3)];
        _outputView = output;
        [self addSubview:output];
        output.text = @"output:";
    }
    return _outputView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark helper

//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}

@end
