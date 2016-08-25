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

@property (nonatomic,strong) NSMutableDictionary *extensionDic;

+(void)enableDebugMode;

+(void)disableDebugMode;

+(void)registKeyName:(NSString *)key withExtensionFunction:(void(^)(void))block;

+(void)removeExtensionFunction:(NSString *)key;

+(void)gotoMainModule;

+(void)gotoScriptModule;

+(void)gotoLogModule;

+(void)gotoNetworkModule;

+(void)gotoViewModule;

+(void)changeNetworktModuleFilter:(NSString *)filter;
@end
