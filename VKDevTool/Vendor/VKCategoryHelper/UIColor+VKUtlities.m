//
//  UIColor+WKCUtlities.m
//  WKCommonX
//
//  Created by super on 15-1-26.
//  Copyright (c) 2015年 awhisper. All rights reserved.
//

#import "UIColor+VKUtlities.h"

@implementation UIColor (VKUtlities)
+ (UIColor *) vk_colorWithHex:(int)hex{
    return [UIColor vk_colorWithHex:hex alpha:1.0];
}

+ (UIColor *) vk_colorWithHex:(int)hex alpha:(CGFloat)alpha{
    return [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0
                           green:((float)((hex & 0xFF00) >> 8))/255.0
                            blue:((float)(hex & 0xFF))/255.0 alpha:alpha];
}
+ (UIColor *) vk_colorWithHexString:(NSString *)hexStr{
    return [UIColor vk_colorWithHexString:hexStr alpha:1.0];
}

+ (UIColor *) vk_colorWithHexString:(NSString *)hexStr alpha:(CGFloat)alpha{
    {
        NSString *cString = [[hexStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];//字符串处理
        //例子，stringToConvert #ffffff
        if ([cString length] < 6)
            return [UIColor whiteColor];//如果非十六进制，返回白色
        if ([cString hasPrefix:@"#"])
            cString = [cString substringFromIndex:1];//去掉头
        if ([cString length] != 6)//去头非十六进制，返回白色
            return [UIColor whiteColor];
        //分别取RGB的值
        NSRange range;
        range.location = 0;
        range.length = 2;
        NSString *rString = [cString substringWithRange:range];
        
        range.location = 2;
        NSString *gString = [cString substringWithRange:range];
        
        range.location = 4;
        NSString *bString = [cString substringWithRange:range];
        
        unsigned int r, g, b;
        //NSScanner把扫描出的制定的字符串转换成Int类型
        [[NSScanner scannerWithString:rString] scanHexInt:&r];
        [[NSScanner scannerWithString:gString] scanHexInt:&g];
        [[NSScanner scannerWithString:bString] scanHexInt:&b];
        //转换为UIColor
        return [UIColor colorWithRed:((float) r / 255.0f)
                               green:((float) g / 255.0f)
                                blue:((float) b / 255.0f)
                               alpha:alpha];
    }
}
@end
