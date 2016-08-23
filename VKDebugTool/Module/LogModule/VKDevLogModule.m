//
//  VKDevLogModule.m
//  VKDebugToolDemo
//
//  Created by Awhisper on 16/8/17.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "VKDevLogModule.h"
#import "VKDevMenu.h"
#import "VKLogConsoleView.h"
#import "VKUIKitMarco.h"
#import "VKDevTool.h"
#import "VKDevToolDefine.h"
@interface VKDevLogModule ()<VKDevMenuDelegate>

@property (nonatomic,strong) VKDevMenu *devMenu;

@property (nonatomic,strong) VKLogConsoleView *logView;

@end

@implementation VKDevLogModule

-(instancetype)init
{
    self = [super init];
    if (self) {
        
        _devMenu = [[VKDevMenu alloc]init];
        _devMenu.delegate = self;
        
    }
    return self;
}


-(VKLogConsoleView *)logView
{
    if (!_logView) {
#ifdef VKDevMode
        VKLogConsoleView *logv = [[VKLogConsoleView alloc]initWithFrame:CGRectMake(0, 0, VK_AppScreenWidth, VK_AppScreenHeight)];
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

-(void)hideModuleMenu{
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
    return @"VKConsoleLog";
}

-(NSArray *)needDevMenuItemsArray
{
    return @[@"Enable ErrorLog",@"Copy to Pasteboard",@"Exit"];
}

-(void)didClickMenuWithButtonIndex:(NSInteger)index
{
    switch (index) {
        case 0:
        {
//            [self VKScriptConsoleExchangeTargetAction];
        }
            break;
        case 1:
        {
            [VKDevTool gotoMainModule];
        }
            break;
        case 2:
        {
//            self.devConsole.inputView.text = @"";
        }
            break;
        case 3:
        {
//            self.devConsole.inputView.text = @"";
            
        }
            break;
            
        default:
            break;
    }
}


@end
