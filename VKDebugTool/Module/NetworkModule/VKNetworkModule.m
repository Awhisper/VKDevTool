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
#import "VKURLProtocol.h"
@interface VKNetworkModule ()<VKDevMenuDelegate,UIAlertViewDelegate>

@property (nonatomic,strong) VKDevMenu *devMenu;

@property (nonatomic,strong) VKNetworkConsoleView *logView;

@end

@implementation VKNetworkModule


-(instancetype)init
{
    self = [super init];
    if (self) {
#ifdef VKDevMode
        _devMenu = [[VKDevMenu alloc]init];
        _devMenu.delegate = self;
        [NSURLProtocol registerClass:[VKURLProtocol class]];
#endif
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
#ifdef VKDevMode
    [self.devMenu show];
#endif
}

-(void)hideModuleMenu
{
#ifdef VKDevMode
    [self.devMenu hide];
#endif
}

-(void)showModuleView
{
#ifdef VKDevMode
    UIView *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.logView];
    [self.logView showConsole];
#endif
}

#pragma mark VKDevMenuDelegate
-(NSString *)needDevMenuTitle
{
    return @"NetworkLog";
}

-(NSArray *)needDevMenuItemsArray
{
    if ([VKNetworkLogger singleton].enableHook) {
        return @[@"Disable NetWork Hook",@"Change HostFilter",@"Exit"];
    }else{
        return @[@"Enable NetWork Hook",@"Change HostFilter",@"Exit"];
    }
    
}

-(void)didClickMenuWithButtonIndex:(NSInteger)index
{
#ifdef VKDevMode
    switch (index) {
        case 0:
        {
            [self changeNetworkHook];
        }
            break;
        case 1:
        {
            [self changeHostFilter];
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
#endif
}

-(void)changeNetworkHook
{
    [VKNetworkLogger singleton].enableHook = ![VKNetworkLogger singleton].enableHook;
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
-(void)changeHostFilter
{
#ifdef VKDevMode
    UIAlertView *inputbox = [[UIAlertView alloc] initWithTitle:@"自定义域名过滤" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];

    [inputbox setAlertViewStyle:UIAlertViewStylePlainTextInput];

    UITextField *nameField = [inputbox textFieldAtIndex:0];
    nameField.placeholder = @"请输入过滤字符";
    [inputbox show];
#endif
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
#ifdef VKDevMode
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        UITextField *nameField = [alertView textFieldAtIndex:0];
        
        if (nameField.text.length > 0) {
            [VKNetworkLogger singleton].hostFilter = nil;
        }else{
            [VKNetworkLogger singleton].hostFilter = nameField.text;
        }
    }
#endif 
}
#pragma clang diagnostic pop
@end
