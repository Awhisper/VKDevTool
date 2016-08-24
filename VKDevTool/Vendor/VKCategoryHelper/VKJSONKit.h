//
//  NSArray+VKUtlities.h
//
//  Created by awhisper on 15/1/13.
//  Copyright (c) 2015年 awhisper. All rights reserved.
//

@import Foundation;

@interface NSData (VKJSONKitDeserializing)
// The NSData MUST be UTF8 encoded JSON.

/**
 * @return mutable字典对象 或者 数组对象
 */
- (id)vk_objectFromJSONData;
/**
 * @param parseOptionFlags  为系统NSJSONReadingOptions参数
 * @return 字典对象 或者 数组对象
 */
- (id)vk_objectFromJSONDataWithParseOptions:(NSJSONReadingOptions)parseOptionFlags;
/**
 * @param parseOptionFlags  系统NSJSONReadingOptions参数
 * @param error 报错指针
 * @return 字典对象 或者 数组对象
 */
- (id)vk_objectFromJSONDataWithParseOptions:(NSJSONReadingOptions)parseOptionFlags error:(NSError **)error;

@end

@interface NSString (VKJSONKitDeserializing)

/**
 * @return 字典对象 或者 数组对象
 */
- (id)vk_objectFromJSONString;
/**
 * @return 字典对象 或者 数组对象
 */
- (id)vk_mutableObjectFromJSONString;

@end


@interface NSString (JSONKitSerializing)

/**
 * @return 将一行string 转成jsonstring
 */
- (NSString *)vk_JSONString;

@end

@interface NSDictionary (JSONKitSerializing)

/**
 * @return 将字典 转成jsonstring
 */
- (NSString *)vk_JSONString;

/**
 * @param serializeOptions 系统NSJSONWritingOptions参数
 * @param error 报错指针
 * @return 将字典 转成jsonstring
 */
- (NSString *)vk_JSONStringWithOptions:(NSJSONWritingOptions)serializeOptions error:(NSError **)error;

@end


@interface NSArray (JSONKitSerializingBlockAdditions)

/**
 * @return 将字典 转成jsonstring
 */
- (NSString *)vk_JSONString;
/**
 * @param serializeOptions 系统NSJSONWritingOptions参数
 * @param error 报错指针
 * @return 将数组 转成jsonstring
 */
- (NSString *)vk_JSONStringWithOptions:(NSJSONWritingOptions)serializeOptions error:(NSError **)error;

@end

