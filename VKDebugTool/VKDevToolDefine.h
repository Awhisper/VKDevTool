//
//  VKDebugToolDefine.h
//  VKDebugToolDemo
//
//  Created by Awhisper on 16/8/17.
//  Copyright © 2016年 baidu. All rights reserved.
//

#ifndef VKDebugToolDefine_h
#define VKDebugToolDefine_h


#ifdef DEBUG

#define VKDevMode

#endif

#ifdef VKDevMode
#import "VKLogManager.h"
#define NSLog(...) NSLog(__VA_ARGS__);\
VKLog(__VA_ARGS__)

#else
#define NSLog(...) {}

#endif

#endif /* VKDebugToolDefine_h */
