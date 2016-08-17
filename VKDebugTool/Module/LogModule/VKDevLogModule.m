//
//  VKDevLogModule.m
//  VKDebugToolDemo
//
//  Created by Awhisper on 16/8/17.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "VKDevLogModule.h"
#import "VKDevMenu.h"

@interface VKDevLogModule ()<VKDevMenuDelegate>

@property (nonatomic,strong) VKDevMenu *devMenu;

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

-(UIView *)moduleView
{
    return nil;
}

-(void)showModuleMenu
{
    [self.devMenu show];
}

-(void)hideModuleMenu{
    [self.devMenu hide];
}

#pragma mark VKDevMenuDelegate
-(NSString *)needDevMenuTitle
{
    return @"VKConsoleLog";
}

-(NSArray *)needDevMenuItemsArray
{
    return @[@"ChangeTarget",@"exit",@"clearInput",@"clearOutput"];
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
//            [self VKScriptConsoleExitAction];
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
