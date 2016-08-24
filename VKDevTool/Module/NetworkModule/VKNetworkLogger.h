//
//  VKNetworkLogger.h
//  VKDebugToolDemo
//
//  Created by Awhisper on 16/8/18.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VKCommonFundation.h"

static NSString * VKNetReqLogNotification = @"VKNetReqLogNotification";
static NSString * VKNetDataLogNotification = @"VKNetDataLogNotification";
@interface VKNetworkLogger : NSObject

@property(atomic,strong) NSMutableArray* logReqArray;

@property(atomic,strong) NSMutableArray* logDataArray;

@property (nonatomic,assign) BOOL enableHook;

@property(nonatomic,strong) NSString* hostFilter;

VK_AS_SINGLETON

+(void)VKNetworkResponseLog:(NSURLResponse *)response;

+(void)VKNetworkResponseDataLog:(NSData *)data;

@end
