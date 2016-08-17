//
//  VKDebugTool.h
//  VKDebugToolDemo
//
//  Created by Awhisper on 16/8/17.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VKCommonFundation.h"

@interface VKDevTool : NSObject
VK_AS_SINGLETON

+(void)enableDebugMode;

+(void)disableDebugMode;


@end
