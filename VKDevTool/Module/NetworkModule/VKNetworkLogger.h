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
@interface VKNetworkLogger : NSObject

@property(atomic,strong) NSMutableArray* logReqArray;

@property (nonatomic,assign) BOOL enableHook;

@property(nonatomic,strong) NSString* hostFilter;

VK_AS_SINGLETON

+(void)VKNetworkRequestLog:(NSURLRequest *)req DataLog:(NSData *)data;

@end
