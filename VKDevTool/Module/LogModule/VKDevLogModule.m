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
@interface VKDevLogModule ()<VKDevMenuDelegate,UIAlertViewDelegate>

@property (nonatomic,strong) VKDevMenu *devMenu;

@property (nonatomic,strong) VKLogConsoleView *logView;

@property (nonatomic,assign) BOOL isSearching;

@end

@implementation VKDevLogModule

-(instancetype)init
{
    self = [super init];
    if (self) {
#ifdef VKDevMode
        _devMenu = [[VKDevMenu alloc]init];
        _devMenu.delegate = self;
        _isSearching = NO;
#endif
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
    self.isSearching = NO;
    [self.logView showConsole];
#endif
}

#pragma mark VKDevMenuDelegate
-(NSString *)needDevMenuTitle
{
    return @"VKConsoleLog";
}


-(NSArray *)needDevMenuItemsArray
{
    NSString *enableHookStr;
    if ([VKLogManager singleton].enableHook) {
        enableHookStr = @"Disable NSError Hook";
    }else{
        enableHookStr = @"Enable NSError Hook";
    }
    NSString *enableSearchingStr;
    if (self.isSearching) {
        enableSearchingStr = @"Cancel Searching";
    }else{
        enableSearchingStr = @"Seach Key Word";
    }
    
    return @[enableHookStr,@"Copy to Pasteboard",enableSearchingStr,@"Exit"];
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
            [self copyLogToPasteBoard];
        }
            break;
        case 2:
        {
            [self searchHandler];
            
        }
            break;
        case 3:
        {
            [VKDevTool gotoMainModule];

        }
            break;
            
        default:
            break;
    }
#endif
}

-(void)searchHandler
{
    if (self.isSearching) {
        [self.logView cancelSearching];
        self.isSearching = NO;
    }else{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UIAlertView *inputbox = [[UIAlertView alloc] initWithTitle:@"搜索关键字" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        
        [inputbox setAlertViewStyle:UIAlertViewStylePlainTextInput];
        
        UITextField *nameField = [inputbox textFieldAtIndex:0];
        nameField.placeholder = @"请输入搜索词";
        [inputbox show];
#pragma clang diagnostic pop
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
#ifdef VKDevMode
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        UITextField *nameField = [alertView textFieldAtIndex:0];
        [self.logView searchKeyword:nameField.text];
        self.isSearching = YES;
    }
#endif
}
#pragma clang diagnostic pop

-(void)changeNetworkHook
{
    [VKLogManager singleton].enableHook = ![VKLogManager singleton].enableHook;
}

-(void)copyLogToPasteBoard
{
#ifdef VKDevMode
    NSMutableString *resultstr = [[NSMutableString alloc]initWithString:@""];
    NSArray *resultarr = [[VKLogManager singleton].logDataArray copy];
    for (NSString* item in resultarr) {
        [resultstr appendString:item];
        [resultstr appendString:@"\n"];
    }
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [resultstr copy];
#endif
}


@end
