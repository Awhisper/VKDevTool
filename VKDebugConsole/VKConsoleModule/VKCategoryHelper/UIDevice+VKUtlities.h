//
//  UIDevice+VKUtlities.h
//
//  Created by awhisper on 15/1/13.
//  Copyright (c) 2015年 awhisper. All rights reserved.
//

#import <UIKit/UIKit.h>

#define VK_IOS8_OR_LATER               [UIDevice VK_ios8_or_later]
#define VK_IOS7_OR_LATER               [UIDevice VK_ios7_or_later]
#define VK_IOS6_OR_LATER               [UIDevice VK_ios6_or_later]
#define VK_IS_IPAD                     [UIDevice VK_isIpad]
#define VK_IS_IPHONE4                  [UIDevice VK_is_iPhone4]
#define VK_IS_IPHONE5                  [UIDevice VK_is_iPhone5]
#define VK_IS_IPHONE6                  [UIDevice VK_is_iPhone6]
#define VK_IS_IPHONE6PLUS              [UIDevice VK_is_iPhone6Plus]


#define VK_IsPortrait         ((UIInterfaceOrientationPortrait == [[UIApplication sharedApplication] statusBarOrientation]) ||(UIInterfaceOrientationPortraitUpsideDown == [[UIApplication sharedApplication] statusBarOrientation]))

@interface UIDevice (VKUtlities)

+ (void)load;//在load中进行一次版本判断，以后不再判断

/*
 * 判断ios系统版本
 * @return 是否是ios8以上
 */
+ (BOOL)VK_ios8_or_later;

/*
 * 判断ios系统版本
 * @return 是否是ios7以上
 */
+ (BOOL)VK_ios7_or_later;

/*
 * 判断ios系统版本
 * @return 是否是ios6以上
 */
+ (BOOL)VK_ios6_or_later;

/*
 * 判断设备型号
 * @return 是否是ip4
 */
+ (BOOL)VK_is_iPhone4;

/*
 * 判断设备型号
 * @return 是否是ip5
 */
+ (BOOL)VK_is_iPhone5;

/*
 * 判断设备型号
 * @return 是否是ip6
 */
+ (BOOL)VK_is_iPhone6;

/*
 * 判断设备型号
 * @return 是否是ip6+
 */
+ (BOOL)VK_is_iPhone6Plus;


/*
 * 判断设备型号码 iPhone6,1 这种 实际上是 iPhone5S
 * @return 设备型号码
 */
- (NSString *) VK_platform;

/*
 * 返回设备名字 例如iPhone5S
 * @return 设备名字
 */
- (NSString *) VK_platformString;

/*
 * 返回是否双核
 * @return 是否
 */
 + (BOOL) VK_isDualCore;
/*
 * 返回是否ipad
 * @return 是否
 */
 + (BOOL) VK_isIpad;

@end
