//
//  VKNetworkModule.m
//  VKDebugToolDemo
//
//  Created by Awhisper on 16/8/18.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "VKNetworkModule.h"
#import "VKDevMenu.h"
#import "VKNetworkConsoleView.h"
#import "VKDevTool.h"
#import "VKDevToolDefine.h"
#import "VKNetworkLogger.h"
@interface VKNetworkModule ()<VKDevMenuDelegate>

@property (nonatomic,strong) VKDevMenu *devMenu;

@property (nonatomic,strong) VKNetworkConsoleView *logView;

@end

@implementation VKNetworkModule


-(instancetype)init
{
    self = [super init];
    if (self) {
        
        _devMenu = [[VKDevMenu alloc]init];
        _devMenu.delegate = self;
        
    }
    return self;
}


-(VKNetworkConsoleView *)logView
{
    if (!_logView) {
#ifdef VKDevMode
        VKNetworkConsoleView *logv = [[VKNetworkConsoleView alloc]initWithFrame:CGRectMake(0, 0, VK_AppScreenWidth, VK_AppScreenHeight)];
        _logView = logv;
#endif
    }
    return _logView;
}

-(UIView *)moduleView
{
    return self.logView;
}

-(void)showModuleMenu
{
    [self.devMenu show];
}

-(void)hideModuleMenu
{
    [self.devMenu hide];
}

-(void)showModuleView
{
    UIView *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.logView];
    [self.logView showConsole];
}

#pragma mark VKDevMenuDelegate
-(NSString *)needDevMenuTitle
{
    return @"NetworkLog";
}

-(NSArray *)needDevMenuItemsArray
{
    if ([VKNetworkLogger singleton].enableHook) {
        return @[@"Disable NetWork Hook",@"Exit"];
    }else{
        return @[@"Enable NetWork Hook",@"Exit"];
    }
    
}

-(void)didClickMenuWithButtonIndex:(NSInteger)index
{
    switch (index) {
        case 0:
        {
            [self changeNetworkHook];
        }
            break;
        case 1:
        {
            [VKDevTool gotoMainModule];
        }
            break;
        default:
            break;
    }
}

-(void)changeNetworkHook
{
    [VKNetworkLogger singleton].enableHook = ![VKNetworkLogger singleton].enableHook;
}


@end
