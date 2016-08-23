//
//  VKNetworkLogger.m
//  VKDebugToolDemo
//
//  Created by Awhisper on 16/8/18.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "VKNetworkLogger.h"
#import "VKDevToolDefine.h"
#define VKMAXSTEPRECORD 200

@implementation VKNetworkLogger
VK_DEF_SINGLETON

-(instancetype)init
{
    self = [super init];
    if (self) {
#ifdef VKDevMode
        self.logDataArray = [[NSMutableArray alloc]init];
        self.logReqArray = [[NSMutableArray alloc]init];
        self.enableHook = YES;
#endif
    }
    return self;
}



+(void)VKNetworkResponseLog:(NSURLResponse *)response{
#ifdef VKDevMode
    @synchronized([VKNetworkLogger singleton]) {
        NSURLResponse *copyresponse = [response copy];
        if (copyresponse) {
            [[VKNetworkLogger singleton].logReqArray addObject:copyresponse];
            
            if ([[VKNetworkLogger singleton].logReqArray count] > VKMAXSTEPRECORD) {
                NSInteger nowCount = [VKNetworkLogger singleton].logReqArray.count;
                [[VKNetworkLogger singleton].logReqArray removeObjectsInRange:NSMakeRange(0, nowCount - VKMAXSTEPRECORD)];
            }
            if ([NSThread isMainThread]) {
                [[NSNotificationCenter defaultCenter]postNotificationName:VKNetReqLogNotification object:copyresponse];
            }else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter]postNotificationName:VKNetReqLogNotification object:copyresponse];
                });
            }
            
        }
    }
    
#endif
}

+(void)VKNetworkResponseDataLog:(NSData *)data{
#ifdef VKDevMode
    @synchronized([VKNetworkLogger singleton]) {
        NSData *copyresponse = [data copy];
        if (copyresponse) {
            [[VKNetworkLogger singleton].logDataArray addObject:copyresponse];
            
            if ([[VKNetworkLogger singleton].logDataArray count] > VKMAXSTEPRECORD) {
                NSInteger nowCount = [VKNetworkLogger singleton].logDataArray.count;
                [[VKNetworkLogger singleton].logDataArray removeObjectsInRange:NSMakeRange(0, nowCount - VKMAXSTEPRECORD)];
            }
            if ([NSThread isMainThread]) {
                [[NSNotificationCenter defaultCenter]postNotificationName:VKNetDataLogNotification object:copyresponse];
            }else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter]postNotificationName:VKNetDataLogNotification object:copyresponse];
                });
            }
            
        }
    }
    
#endif
}
@end
