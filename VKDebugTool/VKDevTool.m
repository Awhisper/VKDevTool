//
//  VKDebugTool.m
//  VKDebugToolDemo
//
//  Created by Awhisper on 16/8/17.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "VKDevTool.h"
#import "VKShakeCommand.h"
#import "VKKeyCommands.h"
#import "VKDevToolDefine.h"
#import "VKDevMainModule.h"

@interface VKDevTool ()

@property (nonatomic,strong) id<VKDevModuleProtocol> currentModule;

@property (nonatomic,strong) VKDevMainModule *mainModule;

@end

@implementation VKDevTool
VK_DEF_SINGLETON



-(instancetype)init
{
    self = [super init];
    if (self) {
//#ifdef VKDevMode
        
        _mainModule = [[VKDevMainModule alloc]init];
//#endif
    }
    return self;
}

+(void)enableDebugMode
{
    [[VKDevTool singleton]enableDebugMode];
}

-(void)enableDebugMode
{
    [self disableDebugMode];
//#ifdef VKDevMode
    
    self.currentModule = self.mainModule;
    [[VKKeyCommands sharedInstance]registerKeyCommandWithInput:@"x" modifierFlags:UIKeyModifierCommand action:^(UIKeyCommand * key) {
        [self showModuleMenu];
    }];
    
    [[VKShakeCommand sharedInstance]registerShakeCommandWithAction:^{
        [self showModuleMenu];
    }];
//#endif
}

+(void)disableDebugMode{
    [[VKDevTool singleton]disableDebugMode];
}

-(void)disableDebugMode
{
//#ifdef VKDevMode
    if (self.currentModule) {
        [[self.currentModule moduleView] removeFromSuperview];
        [self.currentModule hideModuleMenu];
        self.currentModule = nil;
    }
    
    
    [[VKKeyCommands sharedInstance]unregisterKeyCommandWithInput:@"x" modifierFlags:UIKeyModifierCommand];
    [[VKShakeCommand sharedInstance]unregisterKeyShakeCommand];
//#endif
}

-(void)showModuleMenu{
    [self.mainModule showModuleMenu];
}


@end
