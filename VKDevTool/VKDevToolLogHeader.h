//
//  VKDevToolLogHeader.h
//  VKDevToolDemo
//
//  Created by Awhisper on 16/9/1.
//  Copyright © 2016年 baidu. All rights reserved.
//

#ifndef VKDevToolLogHeader_h
#define VKDevToolLogHeader_h
#import "VKDevToolDefine.h"

#ifdef VKDevMode
#import "VKLogManager.h"
#define NSLog(...) NSLog(__VA_ARGS__);\
VKLog(__VA_ARGS__)

//#else
//#define NSLog(...) {}

#endif

#endif /* VKDevToolLogHeader_h */
