//
//  BDWKLogManager.h
//  Yuedu
//
//  Created by Awhisper on 15/12/28.
//  Copyright © 2015年 baidu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VKCommonFundation.h"
FOUNDATION_EXPORT void VKLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);

static NSString * VKLogNotification = @"VKLogNotification";

@interface VKLogManager : NSObject

@property(atomic,strong) NSMutableArray* logDataArray;

VK_AS_SINGLETON

+(void)VKLogString:(NSString *)format withVarList:(va_list)arglist;

+(void)VKLogError:(NSError *)error;

@end
