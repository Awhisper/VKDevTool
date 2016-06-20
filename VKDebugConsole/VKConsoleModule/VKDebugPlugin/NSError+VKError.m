//
//  NSError+VKError.m
//  VKDebugConsoleDemo
//
//  Created by Awhisper on 16/6/20.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "NSError+VKError.h"
#import <objc/runtime.h>
#import "VKLogManager.h"
@implementation NSError (VKError)

+(void)load
{
#ifndef __OPTIMIZE__
    SEL origSelector1 = @selector(initWithDomain:code:userInfo:);
    SEL newSelector1 = @selector(vkInitWithDomain:code:userInfo:);
    
    Method origMethod1 = class_getInstanceMethod([self class], origSelector1);
    Method newMehthod1 = class_getInstanceMethod([self class], newSelector1);
    if (origMethod1 && newMehthod1) {
        method_exchangeImplementations(origMethod1, newMehthod1);
    }
    
    
    SEL origSelector2 = @selector(errorWithDomain:code:userInfo:);
    SEL newSelector2 = @selector(vkErrorWithDomain:code:userInfo:);
    
    Method origMethod2 = class_getInstanceMethod([self class], origSelector2);
    Method newMehthod2 = class_getInstanceMethod([self class], newSelector2);
    if (origMethod2 && newMehthod2) {
        method_exchangeImplementations(origMethod2, newMehthod2);
    }
    
#endif
}

-(instancetype)vkInitWithDomain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)dict
{
    NSError *result = [self vkInitWithDomain:domain code:code userInfo:dict];
    [VKLogManager VKLogError:result];
    return result;
}


+(instancetype)vkErrorWithDomain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)dict
{
    NSError *result = [self vkErrorWithDomain:domain code:code userInfo:dict];
    [VKLogManager VKLogError:result];
    return result;
}
@end
