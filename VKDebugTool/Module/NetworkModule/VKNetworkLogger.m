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
        self.logDataArray = [[NSMutableArray alloc]init];
    }
    return self;
}



+(void)VKNetworkResponseLog:(NSURLResponse *)response{
#ifdef VKDevMode
    @synchronized([VKNetworkLogger singleton]) {
        NSURLResponse *copyresponse = [response copy];
        if (copyresponse) {
            [[VKNetworkLogger singleton].logDataArray addObject:copyresponse];
            
            if ([[VKNetworkLogger singleton].logDataArray count] > VKMAXSTEPRECORD) {
                NSInteger nowCount = [VKNetworkLogger singleton].logDataArray.count;
                [[VKNetworkLogger singleton].logDataArray removeObjectsInRange:NSMakeRange(0, nowCount - VKMAXSTEPRECORD)];
            }
            if ([NSThread isMainThread]) {
                [[NSNotificationCenter defaultCenter]postNotificationName:VKNetLogNotification object:copyresponse];
            }else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter]postNotificationName:VKNetLogNotification object:copyresponse];
                });
            }
            
        }
    }
    
#endif
}
@end
