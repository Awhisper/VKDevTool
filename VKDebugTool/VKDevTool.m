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
#import "VKDevScriptModule.h"
#import "VKDevLogModule.h"
#import "VKNetworkModule.h"
@interface VKDevTool ()

@property (nonatomic,strong) id<VKDevModuleProtocol> currentModule;

@property (nonatomic,strong) VKDevMainModule *mainModule;

@property (nonatomic,strong) VKDevScriptModule *scriptModule;

@property (nonatomic,strong) VKDevLogModule *logModule;

@property (nonatomic,strong) VKNetworkModule *netModule;

@end

@implementation VKDevTool
VK_DEF_SINGLETON



-(instancetype)init
{
    self = [super init];
    if (self) {
#ifdef VKDevMode
        _mainModule = [[VKDevMainModule alloc]init];
        _scriptModule = [[VKDevScriptModule alloc]init];
        _logModule = [[VKDevLogModule alloc]init];
        _netModule = [[VKNetworkModule alloc]init];
        
        _extensionDic = [[NSMutableDictionary alloc]init];
#endif
    }
    return self;
}

+(void)enableDebugMode
{
    [[VKDevTool singleton]enableDebugMode];
}

-(void)enableDebugMode
{
#ifdef VKDevMode
    [self goMainModule];
    [[VKKeyCommands sharedInstance]registerKeyCommandWithInput:@"x" modifierFlags:UIKeyModifierCommand action:^(UIKeyCommand * key) {
        [self showModuleMenu];
    }];
    
    [[VKShakeCommand sharedInstance]registerShakeCommandWithAction:^{
        [self showModuleMenu];
    }];
#endif
}

+(void)disableDebugMode{
    [[VKDevTool singleton]disableDebugMode];
}

-(void)disableDebugMode
{
#ifdef VKDevMode
    [self leaveCurrentModule];
    
    [[VKKeyCommands sharedInstance]unregisterKeyCommandWithInput:@"x" modifierFlags:UIKeyModifierCommand];
    [[VKShakeCommand sharedInstance]unregisterKeyShakeCommand];
#endif
}

-(void)showModuleMenu{
    [self.currentModule showModuleMenu];
}

-(void)leaveCurrentModule
{
#ifdef VKDevMode
    if (self.currentModule) {
        [[self.currentModule moduleView] removeFromSuperview];
        [self.currentModule hideModuleMenu];
        self.currentModule = nil;
    }
#endif
}

+(void)gotoMainModule
{
    [[self singleton]goMainModule];
}

-(void)goMainModule{
#ifdef VKDevMode
    [self leaveCurrentModule];
    self.currentModule = self.mainModule;
#endif
}

+(void)gotoScriptModule
{
    [[self singleton]goScriptModule];
}
-(void)goScriptModule{
#ifdef VKDevMode
    [self leaveCurrentModule];
    self.currentModule = self.scriptModule;
    [self.scriptModule startScriptDebug];
#endif
}

+(void)gotoLogModule
{
    [[self singleton]goLogModule];
}

-(void)goLogModule
{
#ifdef VKDevMode
    [self leaveCurrentModule];
    self.currentModule = self.logModule;
    [self.logModule showModuleView];
#endif
}

+(void)gotoNetworkModule
{
    [[self singleton]goNetworkModule];
}

-(void)goNetworkModule
{
#ifdef VKDevMode
    [self leaveCurrentModule];
    self.currentModule = self.netModule;
    [self.netModule showModuleView];
#endif
}

+(void)registKeyName:(NSString *)key withExtensionFunction:(void (^)(void))block{
    [[VKDevTool singleton].extensionDic setObject:[block copy] forKey:key];
}

+(void)removeExtensionFunction:(NSString *)key{
    [[VKDevTool singleton].extensionDic removeObjectForKey:key];
}

@end
