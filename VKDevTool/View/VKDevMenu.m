//
//  JPPlaygroundMenu.m
//  JSPatchPlaygroundDemo
//
//  Created by Awhisper on 16/8/7.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "VKDevMenu.h"
#import <UIKit/UIKit.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface VKDevMenu ()<UIActionSheetDelegate>

@property (nonatomic,strong) UIActionSheet * actionSheet;

@end

@implementation VKDevMenu

-(instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)show
{
    if (_actionSheet) {
        [_actionSheet dismissWithClickedButtonIndex:_actionSheet.cancelButtonIndex animated:YES];
        _actionSheet = nil;
    } else {
        [self showActionSheet];
    }
    
}

- (void)hide
{
    if (_actionSheet) {
        [_actionSheet dismissWithClickedButtonIndex:_actionSheet.cancelButtonIndex animated:YES];
        _actionSheet = nil;
    }
}

-(void)showActionSheet
{
    UIActionSheet *actionSheet = [UIActionSheet new];
    actionSheet.title = @"VKDevMenu";
    if (self.delegate && [self.delegate respondsToSelector:@selector(needDevMenuTitle)]) {
        actionSheet.title = [self.delegate needDevMenuTitle];
    }
    
    actionSheet.delegate = self;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(needDevMenuItemsArray)]) {
        NSArray<NSString *> *items = [self.delegate needDevMenuItemsArray];
        for (NSString *item in items) {
            [actionSheet addButtonWithTitle:item];
        }
        [actionSheet addButtonWithTitle:@"Cancel"];
        actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
        
        [actionSheet showInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
        _actionSheet = actionSheet;
    }
    
}


-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (!_actionSheet) {
        return;
    }
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didClickMenuWithButtonIndex:)]) {
            [self.delegate didClickMenuWithButtonIndex:-1];
        }
    }else
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didClickMenuWithButtonIndex:)]) {
            [self.delegate didClickMenuWithButtonIndex:buttonIndex];
        }
    }
    _actionSheet = nil;
}

#pragma clang diagnostic pop

@end
