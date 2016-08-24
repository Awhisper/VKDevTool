//
//  UIWindow+VKShakeCommands.m
//  VKKeyCommandsDemo
//
//  Created by Awhisper on 16/8/12.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "UIWindow+VKShakeCommand.h"
#import "VKShakeCommand.h"
@implementation UIWindow (VKShakeCommand)


- (BOOL)vk_canBecomeFirstResponder {
    return YES;
}

- (void)vk_motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    [[VKShakeCommand sharedInstance]shakeShake];
}

@end
