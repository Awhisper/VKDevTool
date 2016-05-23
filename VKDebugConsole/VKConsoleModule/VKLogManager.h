//
//  BDWKLogManager.h
//  Yuedu
//
//  Created by Awhisper on 15/12/28.
//  Copyright © 2015年 baidu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT void VKLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);

static NSString * VKLogNotification = @"VKLogNotification";

@interface VKLogManager : NSObject

@property(atomic,strong) NSMutableArray* logDataArray;

- (instancetype)sharedInstance;

+ (instancetype)singleton;

+(void)VKLogString:(NSString *)format withVarList:(va_list)arglist;

@end
