//
//  NSMutableAttributedString+WKCAttributedString.m
//  WKCommonX
//
//  Created by Andy__M on 15/1/20.
//  Copyright (c) 2015年 awhisper. All rights reserved.
//

#import "NSMutableAttributedString+VKAttributedString.h"

@implementation NSMutableAttributedString (VKAttributedString)

+ (NSLineBreakMode)lineBreakModeFromCTLineBreakMode:(CTLineBreakMode)mode {
    switch (mode) {
        case kCTLineBreakByWordWrapping: return NSLineBreakByWordWrapping;
        case kCTLineBreakByCharWrapping: return NSLineBreakByCharWrapping;
        case kCTLineBreakByClipping: return NSLineBreakByClipping;
        case kCTLineBreakByTruncatingHead: return NSLineBreakByTruncatingHead;
        case kCTLineBreakByTruncatingTail: return NSLineBreakByTruncatingTail;
        case kCTLineBreakByTruncatingMiddle: return NSLineBreakByTruncatingMiddle;
    }
}

-(CGRect)vk_getStringRectWithSize:(CGSize)size
{
    CGRect frame = [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    return frame;
}


- (void)vk_setTextAlignment:(CTTextAlignment)textAlignment
           lineBreakMode:(CTLineBreakMode)lineBreakMode
              lineHeight:(CGFloat)lineHeight
                   range:(NSRange)range {
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentFromCTTextAlignment(textAlignment);
    paragraphStyle.lineBreakMode = [[self class] lineBreakModeFromCTLineBreakMode:lineBreakMode];
    paragraphStyle.minimumLineHeight = lineHeight;
    paragraphStyle.maximumLineHeight = lineHeight;
    [self addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
}

- (void)vk_setTextAlignment:(CTTextAlignment)textAlignment
           lineBreakMode:(CTLineBreakMode)lineBreakMode
              lineHeight:(CGFloat)lineHeight {
    [self vk_setTextAlignment:textAlignment
             lineBreakMode:lineBreakMode
                lineHeight:lineHeight
                     range:NSMakeRange(0, self.length)];
}

- (void)vk_setLineSpacing:(CGFloat)linespace
{
    [self vk_setLineSpacing:linespace range:NSMakeRange(0, self.length)];
}

-(void)vk_setLineSpacing:(CGFloat)linespace range:(NSRange)range
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineSpacing = linespace;
    [self addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
}

- (void)vk_setTextColor:(UIColor *)color range:(NSRange)range {
    [self removeAttribute:NSForegroundColorAttributeName range:range];
    
    if (nil != color) {
        [self addAttribute:NSForegroundColorAttributeName value:color range:range];
    }
}

- (void)vk_setTextColor:(UIColor *)color {
    [self vk_setTextColor:color range:NSMakeRange(0, self.length)];
}

- (void)vk_setTextBackgroundColor:(UIColor *)color range:(NSRange)range {
    [self removeAttribute:NSBackgroundColorAttributeName range:range];
    
    if (nil != color) {
        [self addAttribute:NSBackgroundColorAttributeName value:color range:range];
    }
}

- (void)vk_setTextBackgroundColor:(UIColor *)color {
    [self vk_setTextBackgroundColor:color range:NSMakeRange(0, self.length)];
}

- (void)vk_setFont:(UIFont *)font range:(NSRange)range {
    [self removeAttribute:NSFontAttributeName range:range];
    
    if (nil != font) {
        [self addAttribute:NSFontAttributeName value:font range:range];
    }
}

- (void)vk_setFont:(UIFont*)font {
    [self vk_setFont:font range:NSMakeRange(0, self.length)];
}

- (void)vk_setFontName:(NSString*)fontName size:(CGFloat)size {
    [self vk_setFontName:fontName size:size range:NSMakeRange(0,[self length])];
}

- (void)vk_setFontName:(NSString*)fontName size:(CGFloat)size range:(NSRange)range {
    // kCTFontAttributeName
    CTFontRef aFont = CTFontCreateWithName((__bridge CFStringRef)fontName, size, NULL);
    if (aFont) {
        [self removeAttribute:(__bridge NSString*)kCTFontAttributeName range:range]; // Work around for Apple leak
        [self addAttribute:(__bridge NSString*)kCTFontAttributeName value:(__bridge id)aFont range:range];
        CFRelease(aFont);
    }
}

- (void)vk_setFontFamily:(NSString*)fontFamily size:(CGFloat)size bold:(BOOL)isBold italic:(BOOL)isItalic range:(NSRange)range {
    // kCTFontFamilyNameAttribute + kCTFontTraitsAttribute
    CTFontSymbolicTraits symTrait = (isBold?kCTFontBoldTrait:0) | (isItalic?kCTFontItalicTrait:0);
    NSDictionary* trait = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedLong:symTrait]
                                                      forKey:(__bridge NSString*)kCTFontSymbolicTrait];
    NSDictionary* attr = [NSDictionary dictionaryWithObjectsAndKeys:
                          fontFamily,kCTFontFamilyNameAttribute,
                          trait,kCTFontTraitsAttribute,nil];
    
    CTFontDescriptorRef desc = CTFontDescriptorCreateWithAttributes((__bridge CFDictionaryRef)attr);
    if (!desc) return;
    CTFontRef aFont = CTFontCreateWithFontDescriptor(desc, size, NULL);
    CFRelease(desc);
    if (!aFont) return;
    
    [self removeAttribute:(__bridge NSString*)kCTFontAttributeName range:range]; // Work around for Apple leak
    [self addAttribute:(__bridge NSString*)kCTFontAttributeName value:(__bridge id)aFont range:range];
    CFRelease(aFont);
}

- (void)vk_setUnderlineStyle:(CTUnderlineStyle)style
                 modifier:(CTUnderlineStyleModifiers)modifier
                    range:(NSRange)range {
    [self removeAttribute:NSUnderlineStyleAttributeName range:range];
    [self addAttribute:NSUnderlineStyleAttributeName value:@(style|modifier) range:range];
}

- (void)vk_setUnderlineStyle:(CTUnderlineStyle)style
                 modifier:(CTUnderlineStyleModifiers)modifier {
    [self vk_setUnderlineStyle:style modifier:modifier range:NSMakeRange(0, self.length)];
}

- (void)vk_setStrokeWidth:(CGFloat)width range:(NSRange)range {
    [self removeAttribute:NSStrokeWidthAttributeName range:range];
    [self addAttribute:NSStrokeWidthAttributeName value:@(width) range:range];
}

- (void)vk_setStrokeWidth:(CGFloat)width {
    [self vk_setStrokeWidth:width range:NSMakeRange(0, self.length)];
}

- (void)vk_setStrokeColor:(UIColor *)color range:(NSRange)range {
    [self removeAttribute:NSStrokeColorAttributeName range:range];
    if (nil != color.CGColor) {
        [self addAttribute:NSStrokeColorAttributeName value:color range:range];
    }
}

- (void)vk_setStrokeColor:(UIColor *)color {
    [self vk_setStrokeColor:color range:NSMakeRange(0, self.length)];
}

- (void)vk_setKern:(CGFloat)kern range:(NSRange)range {
    [self removeAttribute:NSKernAttributeName range:range];
    [self addAttribute:NSKernAttributeName value:@(kern) range:range];
}

- (void)vk_setKern:(CGFloat)kern {
    [self vk_setKern:kern range:NSMakeRange(0, self.length)];
}


@end
