//
//  VKDebugConsole.m
//  VKDebugConsoleDemo
//
//  Created by Awhisper on 16/5/22.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "VKDebugConsole.h"
#import "VKConsoleButton.h"
#import "VKScriptConsole.h"
@interface VKDebugConsole ()

@property (nonatomic,strong) VKConsoleButton *debugBt;

@property (nonatomic,strong) VKScriptConsole *scriptView;

@end

@implementation VKDebugConsole
VK_DEF_SINGLETON

-(instancetype)init
{
    self = [super init];
    if (self) {
        VKConsoleButton *debugbt = [[VKConsoleButton alloc]initWithDefault];
        self.debugBt = debugbt;
        [debugbt addTarget:self action:@selector(debugClick) forControlEvents:UIControlEventTouchUpInside];
        
        VKScriptConsole *scriptv = [[VKScriptConsole alloc]initWithFrame:CGRectMake(0, 0, VK_AppScreenWidth, VK_AppScreenHeight)];
        self.scriptView = scriptv;
    }
    return self;
}

-(void)showButton
{
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    [window addSubview:self.debugBt];
}

-(void)hideButton
{
    [self.debugBt removeFromSuperview];
}

-(void)debugClick
{
    if (self.scriptView.superview) {
        [self.scriptView hideConsole];
        [self.debugBt setTitle:@"Debug" forState:UIControlStateNormal];
    }else{
        UIWindow * window = [[UIApplication sharedApplication] keyWindow];
        [window insertSubview:self.scriptView belowSubview:self.debugBt];
        self.scriptView.target = [self getCurrentVC];
        [self.scriptView showConsole];
        [self.debugBt setTitle:@"Hide" forState:UIControlStateNormal];
    }
}

+(void)showBt
{
    [[self singleton] showButton];
}

+(void)hideBt
{
    [[self singleton] hideButton];
}



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
    
    if ([result isKindOfClass:[UINavigationController class]]) {
        UINavigationController * navi = (UINavigationController *)result;
        result = navi.visibleViewController;
    }
    
    return result;
}
@end
