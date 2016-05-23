//
//  VKDebugLogHelper.h
//  VKDebugConsoleDemo
//
//  Created by Awhisper on 16/5/23.
//  Copyright © 2016年 baidu. All rights reserved.
//

#ifndef VKDebugLogHelper_h
#define VKDebugLogHelper_h


#ifndef __OPTIMIZE__

#import "VKLogManager.h"

#define NSLog(...) NSLog(__VA_ARGS__);\
                   VKLog(__VA_ARGS__)\

#else
#define NSLog(...) {}

#endif

#endif /* VKDebugLogHelper_h */
