//
//  VKDevViewModule.m
//  VKDebugToolDemo
//
//  Created by Awhisper on 16/8/24.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "VKDevViewModule.h"
#import "VKDevToolDefine.h"
#import "VKDevMenu.h"
#import "VKDevTool.h"
#import "YYViewHierarchy3D.h"
@interface VKDevViewModule ()<VKDevMenuDelegate>

@property (nonatomic,strong) VKDevMenu *devMenu;

@end

@implementation VKDevViewModule
-(instancetype)init
{
    self = [super init];
    if (self) {
#ifdef VKDevMode
        _devMenu = [[VKDevMenu alloc]init];
        _devMenu.delegate = self;
#endif
    }
    return self;
}

-(UIView *)moduleView
{
    return nil;
}

-(void)showModuleView
{
#ifdef VKDevMode
    [YYViewHierarchy3D sharedInstance].hidden = YES;
    [[YYViewHierarchy3D sharedInstance] toggleShow];
#endif
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

#pragma mark VKDevMenuDelegate
-(NSString *)needDevMenuTitle
{
    return @"ViewHierarychy3D";
}

-(NSArray *)needDevMenuItemsArray
{
    return @[@"Exit"];
}

-(void)didClickMenuWithButtonIndex:(NSInteger)index
{
#ifdef VKDevMode
    switch (index) {
        case 0:
        {
            [[YYViewHierarchy3D sharedInstance] toggleShow];
            [VKDevTool gotoMainModule];
        }
            break;
        default:
            break;
    }
#endif
}


@end
