//
//  VKDebugConsole.h
//  VKDebugConsole
//
//  Created by Awhisper on 16/5/20.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VKScriptConsoleDelegate <NSObject>

-(void)VKScriptConsoleExitAction;

-(void)VKScriptConsoleExchangeTargetAction;

@end

@interface VKScriptConsole : UIView

@property (nonatomic,weak) id target;

@property (nonatomic,weak) id<VKScriptConsoleDelegate> delegate;

-(void)showConsole;
-(void)hideConsole;

-(void)addScriptLogToOutput:(NSString *)log WithUIColor:(UIColor *)color;

-(void)setInputCode:(NSString *)code;

@end
