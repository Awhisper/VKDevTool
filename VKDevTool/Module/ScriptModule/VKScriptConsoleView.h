//
//  VKDebugConsole.h
//  VKDebugConsole
//
//  Created by Awhisper on 16/5/20.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VKDevConsoleView.h"
@protocol VKScriptConsoleDelegate <NSObject>

-(void)VKScriptConsoleExitAction;

-(void)VKScriptConsoleExchangeTargetAction;

@end

@interface VKScriptConsoleView : VKDevConsoleView

@property (nonatomic,weak) id target;

@property (nonatomic,strong) UITextView *inputView;

@property (nonatomic,strong) UITextView *outputView;

@property (nonatomic,weak) id<VKScriptConsoleDelegate> delegate;

-(void)addScriptLogToOutput:(NSString *)log WithUIColor:(UIColor *)color;

-(void)setInputCode:(NSString *)code;

@end
