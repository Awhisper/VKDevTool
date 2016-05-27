//
//  VKDebugJPExtension.m
//  VKDebugConsoleDemo
//
//  Created by Awhisper on 16/5/27.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "VKDebugJPExtension.h"
#import <UIKit/UIKit.h>
@implementation VKDebugJPExtension

+ (void)main:(JSContext *)context
{
    context[@"getSuperView"] = ^(JSValue *viewJS) {
        UIView *viewOC = [VKJPExtension formatJSToOC:viewJS];
        UIView *superViewOC = [VKDebugJPExtension getViewSuperView:viewOC];
        return [self formatOCToJS:superViewOC];
    };
    
    context[@"getParentVC"] = ^(JSValue *viewJS) {
        UIView *viewOC = [VKJPExtension formatJSToOC:viewJS];
        UIViewController *parentVCOC = [VKDebugJPExtension getViewParentViewController:viewOC];
        return [self formatOCToJS:parentVCOC];
    };
}

+(UIView *)getViewSuperView:(UIView *)view;
{
    return view.superview;
}

+(UIViewController *)getViewParentViewController:(UIView *)view;
{
    for (UIView* next = [view superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}
@end
