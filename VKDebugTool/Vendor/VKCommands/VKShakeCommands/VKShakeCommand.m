//
//  VKShakeCommands.m
//  VKKeyCommandsDemo
//
//  Created by Awhisper on 16/8/12.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "VKShakeCommand.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
void VKSwizzleInstanceMethods(Class cls, SEL original, SEL replacement)
{
    Method originalMethod = class_getInstanceMethod(cls, original);
    IMP originalImplementation = method_getImplementation(originalMethod);
    const char *originalArgTypes = method_getTypeEncoding(originalMethod);
    
    Method replacementMethod = class_getInstanceMethod(cls, replacement);
    IMP replacementImplementation = method_getImplementation(replacementMethod);
    const char *replacementArgTypes = method_getTypeEncoding(replacementMethod);
    
    if (class_addMethod(cls, original, replacementImplementation, replacementArgTypes)) {
        class_replaceMethod(cls, replacement, originalImplementation, originalArgTypes);
    } else {
        method_exchangeImplementations(originalMethod, replacementMethod);
    }
}

static void (^_vkShakeCommandHandle)(void);

static BOOL _vkShakeCommandEnable = NO;


@implementation VKShakeCommand;

+ (instancetype)sharedInstance
{
    static VKShakeCommand *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    
    return sharedInstance;
}

-(void)shakeShake
{
    if (_vkShakeCommandHandle) {
        _vkShakeCommandHandle();
    }
}

-(void)registerShakeCommandWithAction:(void (^)(void))block
{
    _vkShakeCommandHandle = [block copy];
    
    if (!_vkShakeCommandEnable) {
        VKSwizzleInstanceMethods([UIWindow class], @selector(canBecomeFirstResponder), @selector(vk_canBecomeFirstResponder));
        VKSwizzleInstanceMethods([UIWindow class], @selector(motionEnded:withEvent:), @selector(vk_motionEnded:withEvent:));
    }
    
}

-(void)unregisterKeyShakeCommand
{
    _vkShakeCommandHandle = nil;
    
    if (_vkShakeCommandEnable) {
        VKSwizzleInstanceMethods([UIWindow class], @selector(canBecomeFirstResponder), @selector(vk_canBecomeFirstResponder));
        VKSwizzleInstanceMethods([UIWindow class], @selector(motionEnded:withEvent:), @selector(vk_motionEnded:withEvent:));
    }
}
@end
