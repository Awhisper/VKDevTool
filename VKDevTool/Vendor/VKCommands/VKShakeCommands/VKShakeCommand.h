//
//  VKShakeCommands.h
//  VKKeyCommandsDemo
//
//  Created by Awhisper on 16/8/12.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VKShakeCommand : NSObject

+ (instancetype)sharedInstance;

- (void)registerShakeCommandWithAction:(void (^)(void))block;

- (void)unregisterKeyShakeCommand;

- (void)shakeShake;

@end
