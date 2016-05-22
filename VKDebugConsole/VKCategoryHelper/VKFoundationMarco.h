//
//  WMCFoundationMarco.h
//  WKCommonX
//
//  Created by awhisper on 15/1/13.
//  Copyright (c) 2015年 awhisper. All rights reserved.
//

#ifndef VKFoundationMarco_h
#define VKFoundationMarco_h

#define VK_WeakSelf(weakSelf)  __weak __typeof(&*self)weakSelf = self;

#ifndef __OPTIMIZE__
#define NSLog(...) NSLog(__VA_ARGS__)
#else
#define NSLog(...) {}
#endif

#endif
