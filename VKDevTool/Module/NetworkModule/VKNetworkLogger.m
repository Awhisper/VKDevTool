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
        self.logReqArray = [[NSMutableArray alloc]init];
        self.enableHook = YES;
#endif
    }
    return self;
}

+(void)VKNetworkRequestLog:(NSURLRequest *)req DataLog:(NSData *)data{
#ifdef VKDevMode
    @synchronized([VKNetworkLogger singleton]) {
        NSURLRequest *copyreq = [req copy];
        NSData *copydata = [data copy];
        if (copyreq && copydata) {
            NSArray *reqItem = @[copyreq,copydata];
            [[VKNetworkLogger singleton].logReqArray addObject:reqItem];
            
            if ([[VKNetworkLogger singleton].logReqArray count] > VKMAXSTEPRECORD) {
                NSInteger nowCount = [VKNetworkLogger singleton].logReqArray.count;
                [[VKNetworkLogger singleton].logReqArray removeObjectsInRange:NSMakeRange(0, nowCount - VKMAXSTEPRECORD)];
            }
            if ([NSThread isMainThread]) {
                [[NSNotificationCenter defaultCenter]postNotificationName:VKNetReqLogNotification object:reqItem];
            }else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter]postNotificationName:VKNetReqLogNotification object:reqItem];
                });
            }
            
        }
    }
    
#endif
}

@end
