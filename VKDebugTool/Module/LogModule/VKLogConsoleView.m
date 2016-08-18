//
//  VKLogConsole.m
//  VKDebugToolDemo
//
//  Created by Awhisper on 16/8/17.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "VKLogConsoleView.h"
#import "VKLogManager.h"
#import "NSMutableAttributedString+VKAttributedString.h"

@interface VKLogConsoleView ()<UITextViewDelegate>

@property (nonatomic,strong) UITextView *LogLabel;

@end

@implementation VKLogConsoleView

-(UITextView *)LogLabel
{
    if (!_LogLabel) {
        _LogLabel = [[UITextView alloc]initWithFrame:self.bounds];
        _LogLabel.delegate = self;
        _LogLabel.textColor = [UIColor yellowColor];
        _LogLabel.layer.borderWidth = 1;
        _LogLabel.layer.borderColor = [UIColor blackColor].CGColor;
        _LogLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_LogLabel];
    }
    return _LogLabel;
}


-(void)showConsole{
    [super showConsole];
    [self addLogNotificationObserver];
    [self showLogManagerOldLog];
}

-(void)hideConsole
{
    [super hideConsole];
    [self removeLogNotificationObserver];
}

-(void)showLogManagerOldLog
{
    for (NSString * log in [VKLogManager singleton].logDataArray) {
        if ([log rangeOfString:@"NSLog: "].location != NSNotFound) {
            [self addScriptLogToOutput:log WithUIColor:[UIColor whiteColor]];
        }else if ([log rangeOfString:@"NSError: "].location != NSNotFound){
            [self addScriptLogToOutput:log WithUIColor:[UIColor redColor]];
        }
    }
}

-(void)addLogNotificationObserver
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(logNotificationGet:) name:VKLogNotification object:nil];
}

-(void)removeLogNotificationObserver
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)logNotificationGet:(NSNotification *)noti
{
    NSString * log = noti.object;
    if ([log rangeOfString:@"NSLog: "].location != NSNotFound) {
        [self addScriptLogToOutput:log WithUIColor:[UIColor whiteColor]];
    }else if ([log rangeOfString:@"NSError: "].location != NSNotFound){
        [self addScriptLogToOutput:log WithUIColor:[UIColor redColor]];
    }
    
}


-(void)addScriptLogToOutput:(NSString *)log WithUIColor:(UIColor *)color{
    NSAttributedString *txt = self.LogLabel.attributedText;
    NSMutableAttributedString *mtxt = [[NSMutableAttributedString alloc]initWithAttributedString:txt];
    NSAttributedString *huanhang = [[NSAttributedString alloc]initWithString:@"\n"];
    [mtxt appendAttributedString:huanhang];
    
    NSMutableAttributedString *logattr = [[NSMutableAttributedString alloc]initWithString:log];
    [logattr vk_setTextColor:color];
    [mtxt appendAttributedString:logattr];
    self.LogLabel.attributedText = mtxt;
    
    if (self.LogLabel.contentSize.height > self.LogLabel.frame.size.height) {
        [self.LogLabel setContentOffset:CGPointMake(0.f,self.LogLabel.contentSize.height-self.LogLabel.frame.size.height)];
    }
}


@end
