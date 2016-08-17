//
//  JPPlaygroundMenu.h
//  JSPatchPlaygroundDemo
//
//  Created by Awhisper on 16/8/7.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol VKDevMenuDelegate <NSObject>

-(void)didClickMenuWithButtonIndex:(NSInteger)index;

-(NSString *)needDevMenuTitle;

-(NSArray *)needDevMenuItemsArray;

@end

@interface VKDevMenu : NSObject

@property (nonatomic,weak) id<VKDevMenuDelegate> delegate;

- (void)show;

- (void)hide;

@end
