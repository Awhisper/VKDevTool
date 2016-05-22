//
//  VKConsoleButton.m
//  VKDebugConsoleDemo
//
//  Created by Awhisper on 16/5/22.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "VKConsoleButton.h"
#import "VKCommonFundation.h"
@implementation VKConsoleButton

-(instancetype)initWithDefault
{
    self = [super initWithFrame:CGRectMake(0, 0, 80, 30)];
    if (self) {
        [self setTitle:@"Debug" forState:UIControlStateNormal];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.layer.borderWidth = 1;
        self.layer.cornerRadius = 5;
        self.clipsToBounds = YES;
        self.top = VK_AppScreenHeight - 50;
        self.left = VK_AppScreenWidth - 100;
    }
    return self;
}

@end
