//
//  NSArray+VKUtlities.m
//
//  Created by awhisper on 15/1/13.
//  Copyright (c) 2015年 awhisper. All rights reserved.
//

#import "VKJSONKit.h"

@implementation NSData (VKJSONKitDeserializing)

- (id)VK_objectFromJSONData{
    return([self VK_objectFromJSONDataWithParseOptions:NSJSONReadingMutableContainers error:NULL]);
}

- (id)VK_objectFromJSONDataWithParseOptions:(NSJSONReadingOptions)parseOptionFlags{
    return [NSJSONSerialization JSONObjectWithData:self options:parseOptionFlags error:nil];
}

- (id)VK_objectFromJSONDataWithParseOptions:(NSJSONReadingOptions)parseOptionFlags error:(NSError **)error{
    return [NSJSONSerialization JSONObjectWithData:self options:parseOptionFlags error:error];
}

@end

@implementation NSString (VKJSONKitDeserializing)

- (id)VK_objectFromJSONString {
    return [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding]
                                           options:NSJSONReadingMutableContainers error:nil];
}

- (id)VK_mutableObjectFromJSONString {
    return [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding]
                                           options:NSJSONReadingMutableContainers error:nil];
}

@end

@implementation NSString (JSONKitSerializing)

////////////
#pragma mark Methods for serializing a single NSString.
////////////SString returning methods...

- (NSString *)VK_JSONString{
    return([self VK_JSONStringWithOptions:NSJSONWritingPrettyPrinted includeQuotes:YES error:NULL]);
}

- (NSString *)VK_JSONStringWithOptions:(NSJSONWritingOptions)serializeOptions includeQuotes:(BOOL)includeQuotes error:(NSError **)error{
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:serializeOptions error:error];
    
    NSString *trimmedString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    trimmedString = [trimmedString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    trimmedString = [trimmedString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return trimmedString;
    
}
//
//- (id)VK_objectFromJSONStringWithParseOptions:(NSJSONReadingOptions)parseOptionFlags error:(NSError **)error{
//    return [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding] options:parseOptionFlags error:error];
//}

@end


@implementation NSDictionary (JSONKitSerializing)

- (NSString *)VK_JSONString {
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *trimmedString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    trimmedString = [trimmedString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    trimmedString = [trimmedString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return trimmedString;
}

- (NSString *)VK_JSONStringWithOptions:(NSJSONWritingOptions)serializeOptions error:(NSError **)error{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:serializeOptions error:error];
    
    NSString *trimmedString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    trimmedString = [trimmedString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    trimmedString = [trimmedString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return trimmedString;
}

@end


@implementation NSArray (JSONKitSerializingBlockAdditions)

- (NSString *)VK_JSONString {
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *trimmedString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    trimmedString = [trimmedString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    trimmedString = [trimmedString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return trimmedString;
}

- (NSString *)VK_JSONStringWithOptions:(NSJSONWritingOptions)serializeOptions error:(NSError **)error{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:serializeOptions error:error];
    
    NSString *trimmedString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    trimmedString = [trimmedString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    trimmedString = [trimmedString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return trimmedString;
}

@end
