//
//  VKUIKitMarco.h
//  VKommonX
//
//  Created by awhisper on 15/1/13.
//  Copyright (c) 2015年 awhisper. All rights reserved.
//

#import "UIDevice+VKutlities.h"

#ifndef VKUIKitMarco_h
#define VKUIKitMarco_h

//屏幕区域
#define VK_MainScreenFrame     [[UIScreen mainScreen] bounds]
//屏幕宽度
#define VK_MainScreenWidth     VK_MainScreenFrame.size.width
//屏幕高度
#define VK_MainScreenHeight    VK_MainScreenFrame.size.height

//app 的可显示宽度
#define VK_AppScreenWidth      (VK_IOS8_OR_LATER?(VK_MainScreenWidth):(VK_IsPortrait? VK_MainScreenWidth : VK_MainScreenHeight))
//app 的可显示高度
#define VK_AppScreenHeight     (VK_IOS8_OR_LATER?(VK_MainScreenHeight):(VK_IsPortrait? VK_MainScreenHeight : VK_MainScreenWidth))

#define VK_KNavigationBarHeight        (44+(VK_IOS7_OR_LATER ? 20 : 0))

#define VK_KTabBarHeight      49

#define VK_FontWithSize(S)		[UIFont systemFontOfSize:S]
#define VK_BOLDFontWithSize(S)   [UIFont boldSystemFontOfSize:S]



#endif
