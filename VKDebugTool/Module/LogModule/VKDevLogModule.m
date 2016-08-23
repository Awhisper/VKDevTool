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
#import "VKLogManager.h"
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
    return @"VKConsoleLog";
}


-(NSArray *)needDevMenuItemsArray
{
    if ([VKLogManager singleton].enableHook) {
        return @[@"Disable NSError Hook",@"Copy to Pasteboard",@"Exit"];
    }else{
        return @[@"Enable NSError Hook",@"Copy to Pasteboard",@"Exit"];
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
            [self copyLogToPasteBoard];
        }
            break;
        case 2:
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
    [VKLogManager singleton].enableHook = ![VKLogManager singleton].enableHook;
}

-(void)copyLogToPasteBoard
{
    NSMutableString *resultstr = [[NSMutableString alloc]initWithString:@""];
    NSArray *resultarr = [[VKLogManager singleton].logDataArray copy];
    for (NSString* item in resultarr) {
        [resultstr appendString:item];
        [resultstr appendString:@"\n"];
    }
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [resultstr copy];
    
}


@end
