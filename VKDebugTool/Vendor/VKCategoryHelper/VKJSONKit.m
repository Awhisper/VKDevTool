//
//  NSArray+VKUtlities.m
//
//  Created by awhisper on 15/1/13.
//  Copyright (c) 2015年 awhisper. All rights reserved.
//

#import "VKJSONKit.h"

@implementation NSData (VKJSONKitDeserializing)

- (id)vk_objectFromJSONData{
    return([self vk_objectFromJSONDataWithParseOptions:NSJSONReadingMutableContainers error:NULL]);
}

- (id)vk_objectFromJSONDataWithParseOptions:(NSJSONReadingOptions)parseOptionFlags{
    return [NSJSONSerialization JSONObjectWithData:self options:parseOptionFlags error:nil];
}

- (id)vk_objectFromJSONDataWithParseOptions:(NSJSONReadingOptions)parseOptionFlags error:(NSError **)error{
    return [NSJSONSerialization JSONObjectWithData:self options:parseOptionFlags error:error];
}

@end

@implementation NSString (VKJSONKitDeserializing)

- (id)vk_objectFromJSONString {
    return [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding]
                                           options:NSJSONReadingMutableContainers error:nil];
}

- (id)vk_mutableObjectFromJSONString {
    return [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding]
                                           options:NSJSONReadingMutableContainers error:nil];
}

@end

@implementation NSString (JSONKitSerializing)

////////////
#pragma mark Methods for serializing a single NSString.
////////////SString returning methods...

- (NSString *)vk_JSONString{
    return([self vk_JSONStringWithOptions:NSJSONWritingPrettyPrinted includeQuotes:YES error:NULL]);
}

- (NSString *)vk_JSONStringWithOptions:(NSJSONWritingOptions)serializeOptions includeQuotes:(BOOL)includeQuotes error:(NSError **)error{
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:serializeOptions error:error];
    
    NSString *trimmedString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    trimmedString = [trimmedString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    trimmedString = [trimmedString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return trimmedString;
    
}
//
//- (id)vk_objectFromJSONStringWithParseOptions:(NSJSONReadingOptions)parseOptionFlags error:(NSError **)error{
//    return [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding] options:parseOptionFlags error:error];
//}

@end


@implementation NSDictionary (JSONKitSerializing)

- (NSString *)vk_JSONString {
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *trimmedString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    trimmedString = [trimmedString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    trimmedString = [trimmedString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return trimmedString;
}

- (NSString *)vk_JSONStringWithOptions:(NSJSONWritingOptions)serializeOptions error:(NSError **)error{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:serializeOptions error:error];
    
    NSString *trimmedString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    trimmedString = [trimmedString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    trimmedString = [trimmedString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return trimmedString;
}

@end


@implementation NSArray (JSONKitSerializingBlockAdditions)

- (NSString *)vk_JSONString {
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *trimmedString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    trimmedString = [trimmedString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    trimmedString = [trimmedString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return trimmedString;
}

- (NSString *)vk_JSONStringWithOptions:(NSJSONWritingOptions)serializeOptions error:(NSError **)error{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:serializeOptions error:error];
    
    NSString *trimmedString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    trimmedString = [trimmedString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    trimmedString = [trimmedString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return trimmedString;
}

@end
