//
//  NSMutableAttributedString+VKAttributedString.h
//
//  Created by Andy__M on 15/1/20.
//  Copyright (c) 2015年 awhisper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>


@interface NSMutableAttributedString (VKAttributedString)


/**
 * get AttributedString with current attribute
 * @param size 计算富文本文字排版区域的限制区域
 * @return 富文本排版区域
 */
-(CGRect)vk_getStringRectWithSize:(CGSize)size;

/**
 * Sets the text alignment and line break mode for a given range.
 * 设置富文本文字 区段的对其样式，断行策略，行高
 * @param textAlignment 文本对其模式
 * @param lineBreakMode 断行模式
 * @param lineHeight 行高
 * @param range 文字区段
 * @return
 */
- (void)vk_setTextAlignment:(CTTextAlignment)textAlignment
           lineBreakMode:(CTLineBreakMode)lineBreakMode
              lineHeight:(CGFloat)lineHeight
                   range:(NSRange)range;

/**
 * Sets the text alignment and the line break mode for the entire string.
 * 设置富文本文字 全部区域的对其样式，断行策略，行高
 * @param textAlignment 文本对其模式
 * @param lineBreakMode 断行模式
 * @param lineHeight 行高
 * @return
 */
- (void)vk_setTextAlignment:(CTTextAlignment)textAlignment
           lineBreakMode:(CTLineBreakMode)lineBreakMode
              lineHeight:(CGFloat)lineHeight;

/**
 * Sets the text LineSpacing for a given range.
 * @param linespace 行间距
 * @param range 指定区段
 * @return
 */
- (void)vk_setLineSpacing:(CGFloat)linespace range:(NSRange)range;

/**
 * Sets the text LineSpacing for the entire string.
 * @param linespace 行间距
 * @return
 */
- (void)vk_setLineSpacing:(CGFloat)linespace;

/**
 * Sets the text color for a given range. 设置区域的文字颜色
 * @param color
 * @param range 颜色区域
 * @return
 */
- (void)vk_setTextColor:(UIColor *)color range:(NSRange)range;

/**
 * Sets the text color for the entire string.设置整体的文字颜色
 * @param color
 * @return
 */
- (void)vk_setTextColor:(UIColor *)color;

/**
 * Sets the font for a given range.
 * 设置区域的文字字体
 * @param font 字体
 * @param range 区域
 * @retern
 */
- (void)vk_setFont:(UIFont *)font range:(NSRange)range;

/**
 * Sets the font for the entire string.
 * 设置整体的文字字体
 * @param font 字体
 * @retern
 */
- (void)vk_setFont:(UIFont *)font;

/**
 * Sets the font for the entire string.
 * 设置整体的文字字体和大小
 * @param font 字体名称 string
 * @param size 字体大小
 * @retern
 */
- (void)vk_setFontName:(NSString*)fontName size:(CGFloat)size;

/**
 * Sets the font for the entire string.
 * 设置区域的文字字体和大小
 * @param font 字体名称 string
 * @param size 字体大小
 * @param range 区域
 * @retern
 */
- (void)vk_setFontName:(NSString*)fontName size:(CGFloat)size range:(NSRange)range;

/**
 * Sets the font for the part string.
 * 设置区域的文字字体和大小和样式
 * @param font 字体名称 string
 * @param size 字体大小
 * @param isBold 是否加粗
 * @param isItalic 是否斜体
 * @param range 区域
 * @retern
 */
- (void)vk_setFontFamily:(NSString*)fontFamily size:(CGFloat)size bold:(BOOL)isBold italic:(BOOL)isItalic range:(NSRange)range;

/**
 * Sets the underline style and modifier for a given range.
 * 设置区域文字的下划线样子
 * @param style 下划线种类
 * @param modifier 下划线样式
 * @param range 区域
 * @return
 */
- (void)vk_setUnderlineStyle:(CTUnderlineStyle)style
                 modifier:(CTUnderlineStyleModifiers)modifier
                    range:(NSRange)range;
/**
 * Sets the underline style and modifier for the entire string.
 * 设置整体文字的下划线样子
 * @param style 下划线种类
 * @param modifier 下划线样式
 * @return
 */
- (void)vk_setUnderlineStyle:(CTUnderlineStyle)style
                 modifier:(CTUnderlineStyleModifiers)modifier;

/**
 * Sets the stroke width for a given range.
 * 设置加粗字
 * @param width 加粗的宽度
 * @param range 区域
 * @return
 */
- (void)vk_setStrokeWidth:(CGFloat)width range:(NSRange)range;

/**
 * Sets the stroke width for the entire string.
 * 设置加粗字
 * @param width 加粗的宽度
 * @return
 */
- (void)vk_setStrokeWidth:(CGFloat)width;

/**
 * Sets the stroke color for a given range.
 * 设置加粗字
 * @param color 加粗颜色
 * @param range 区域
 * @return
 */
- (void)vk_setStrokeColor:(UIColor *)color range:(NSRange)range;

/**
 * Sets the stroke color for the entire string.
 * 设置加粗字
 * @param color 加粗颜色
 * @return
 */
- (void)vk_setStrokeColor:(UIColor *)color;

/**
 * Sets the text kern for a given range.
 * 设置英文kerning
 * @param kern 
 * @range 区域
 * @return
 */
- (void)vk_setKern:(CGFloat)kern range:(NSRange)range;

/**
 * Sets the text kern for the entire string.
 * 设置英文kerning
 * @param kern
 * @return
 */
- (void)vk_setKern:(CGFloat)kern;

- (void)vk_setTextBackgroundColor:(UIColor *)color range:(NSRange)range;

- (void)vk_setTextBackgroundColor:(UIColor *)color;

@end
