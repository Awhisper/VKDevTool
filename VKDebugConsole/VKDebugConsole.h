//
//  VKDebugConsole.h
//  VKDebugConsoleDemo
//
//  Created by Awhisper on 16/5/22.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VKCommonFundation.h"

@interface VKDebugConsole : NSObject
VK_AS_SINGLETON

+(void)showBt;
+(void)hideBt;

+(void)enableDebugMode;
+(void)disableDebugMode;

@end
