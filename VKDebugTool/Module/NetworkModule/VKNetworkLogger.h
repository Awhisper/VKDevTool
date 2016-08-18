//
//  VKNetworkLogger.h
//  VKDebugToolDemo
//
//  Created by Awhisper on 16/8/18.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VKCommonFundation.h"

static NSString * VKNetLogNotification = @"VKNetLogNotification";

@interface VKNetworkLogger : NSObject

@property(atomic,strong) NSMutableArray* logDataArray;

VK_AS_SINGLETON

+(void)VKNetworkResponseLog:(NSURLResponse *)response;

@end
