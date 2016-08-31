//
//  UIColor+WKCUtlities.h
//  WKCommonX
//
//  Created by super on 15-1-26.
//  Copyright (c) 2015年 awhisper. All rights reserved.
//

#import <UIKit/UIKit.h>

#define VK_RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define VK_RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#define VK_HEXRGBCOLOR(h) [UIColor vk_colorWithHex:h]
#define VK_HEXRGBACOLOR(h,a) [UIColor vk_colorWithHex:h alpha:a]

#define VK_HEXRGBCOLOR_STR(h) [UIColor vk_colorWithHexString:h]
#define VK_HEXRGBACOLOR_STR(h,a) [UIColor vk_colorWithHexString:h alpha:a]

@interface UIColor (VKUtlities)
/*
 * 生成颜色代码对应的UIColor
 * @param hex 颜色代码
 * @return UIColor
 */
+ (UIColor *) vk_colorWithHex:(int)hex;
/*
 * 生成颜色代码对应的UIColor
 * @param hex 颜色代码
 * @param alpha 透明度
 * @return UIColor
 */
+ (UIColor *) vk_colorWithHex:(int)hex alpha:(CGFloat)alpha;

/*
 * 生成颜色代码对应的UIColor
 * @param hex 颜色代码 string
 * @return UIColor
 */
+ (UIColor *) vk_colorWithHexString:(NSString *)hexStr;

/*
 * 生成颜色代码对应的UIColor
 * @param hex 颜色代码 string
 * @param alpha 透明度
 * @return UIColor
 */
+ (UIColor *) vk_colorWithHexString:(NSString *)hexStr alpha:(CGFloat)alpha;
@end
