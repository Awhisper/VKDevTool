//
//  VKDebugMainModule.m
//  VKDebugToolDemo
//
//  Created by Awhisper on 16/8/17.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "VKDevMainModule.h"
#import "VKDevMenu.h"
@interface VKDevMainModule ()<VKDevMenuDelegate>

@property (nonatomic,strong) VKDevMenu *devMenu;

@end

@implementation VKDevMainModule

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
    return @"VKDevTool";
}

-(NSArray *)needDevMenuItemsArray
{
    return @[@"DebugConsole",@"LogConsole",@"NetworkConsole"];
}

-(void)didClickMenuWithButtonIndex:(NSInteger)index
{
    NSLog(@"11");
}
@end
