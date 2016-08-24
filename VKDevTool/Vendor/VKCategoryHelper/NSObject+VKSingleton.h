//
//  NSObject+VKSingleton.h
//
//  Created by awhisper on 15/1/13.
//  Copyright (c) 2015年 awhisper. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef	VK_AS_SINGLETON
#define VK_AS_SINGLETON \
- (instancetype)sharedInstance; \
+ (instancetype)singleton;

#endif

#ifndef	VK_DEF_SINGLETON
#define VK_DEF_SINGLETON \
- (instancetype)sharedInstance \
{ \
return [[self class] singleton]; \
} \
static id __singleton__; \
+ (instancetype)singleton \
{ \
static dispatch_once_t once; \
dispatch_once( &once, ^{ __singleton__ = [[self alloc] init]; } ); \
return __singleton__; \
}
#endif


