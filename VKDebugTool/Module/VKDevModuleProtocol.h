//
//  VKDebugModuleProtocol.h
//  VKDebugToolDemo
//
//  Created by Awhisper on 16/8/17.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@protocol VKDevModuleProtocol <NSObject>

-(void)showModuleView;

-(UIView *)moduleView;

-(void)showModuleMenu;

-(void)hideModuleMenu;

@end
