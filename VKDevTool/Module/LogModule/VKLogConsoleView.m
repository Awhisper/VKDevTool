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
#import "VKDevToolDefine.h"
@interface VKLogConsoleView ()<UITextViewDelegate>

@property (nonatomic,strong) UITextView *LogLabel;

@end

@implementation VKLogConsoleView

-(UITextView *)LogLabel
{
    if (!_LogLabel) {
#ifdef VKDevMode
        _LogLabel = [[UITextView alloc]initWithFrame:self.bounds];
        _LogLabel.delegate = self;
        _LogLabel.textColor = [UIColor yellowColor];
        _LogLabel.layer.borderWidth = 1;
        _LogLabel.layer.borderColor = [UIColor blackColor].CGColor;
        _LogLabel.backgroundColor = [UIColor clearColor];
        _LogLabel.editable = NO;
        [self addSubview:_LogLabel];
#endif
    }
    return _LogLabel;
}


-(void)showConsole{
#ifdef VKDevMode
    [super showConsole];
    [self addLogNotificationObserver];
    [self showLogManagerOldLog];
#endif
}

-(void)hideConsole
{
#ifdef VKDevMode
    [super hideConsole];
    [self removeLogNotificationObserver];
#endif
}

-(void)showLogManagerOldLog
{
#ifdef VKDevMode
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:@""];
        for (NSString * log in [VKLogManager singleton].logDataArray) {
            if ([log rangeOfString:@"NSLog: "].location != NSNotFound) {
//                [self addScriptLogToOutput:log WithUIColor:[UIColor whiteColor]];
                [self addScriptLogToAttriString:str withLog:log WithUIColor:[UIColor whiteColor]];
            }else if ([log rangeOfString:@"NSError: "].location != NSNotFound){
//                [self addScriptLogToOutput:log WithUIColor:[UIColor orangeColor]];
                [self addScriptLogToAttriString:str withLog:log WithUIColor:[UIColor orangeColor]];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.LogLabel.attributedText = str;
            
            if (self.LogLabel.contentSize.height > self.LogLabel.frame.size.height) {
                CGPoint point = CGPointMake(0.f,self.LogLabel.contentSize.height - self.LogLabel.frame.size.height);
                [self.LogLabel setContentOffset:point animated:YES];
            }
            
        });
    });
    
    
#endif
}

-(void)addLogNotificationObserver
{
#ifdef VKDevMode
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(logNotificationGet:) name:VKLogNotification object:nil];
#endif
}

-(void)removeLogNotificationObserver
{
#ifdef VKDevMode
    [[NSNotificationCenter defaultCenter]removeObserver:self];
#endif
}

-(void)logNotificationGet:(NSNotification *)noti
{
#ifdef VKDevMode
    NSString * log = noti.object;
    if ([log rangeOfString:@"NSLog: "].location != NSNotFound) {
        [self addScriptLogToOutput:log WithUIColor:[UIColor whiteColor]];
    }else if ([log rangeOfString:@"NSError: "].location != NSNotFound){
        [self addScriptLogToOutput:log WithUIColor:[UIColor orangeColor]];
    }
#endif
}


-(void)addScriptLogToAttriString:(NSMutableAttributedString *)str withLog:(NSString *)log WithUIColor:(UIColor *)color{
    
    [str appendAttributedString:[[NSAttributedString alloc]initWithString:@"\n"]];
    
    NSMutableAttributedString *logattr = [[NSMutableAttributedString alloc]initWithString:log];
    [logattr vk_setTextColor:color];
    [logattr vk_setFont:[UIFont boldSystemFontOfSize:15]];
    [logattr vk_setLineSpacing:10];
    [str appendAttributedString:logattr];
}

-(void)addScriptLogToOutput:(NSString *)log WithUIColor:(UIColor *)color{
#ifdef VKDevMode
    NSAttributedString *txt = self.LogLabel.attributedText;
    NSMutableAttributedString *mtxt = [[NSMutableAttributedString alloc]initWithAttributedString:txt];
    NSAttributedString *huanhang = [[NSAttributedString alloc]initWithString:@"\n"];
    [mtxt appendAttributedString:huanhang];
    
    NSMutableAttributedString *logattr = [[NSMutableAttributedString alloc]initWithString:log];
    [logattr vk_setTextColor:color];
    [logattr vk_setFont:[UIFont boldSystemFontOfSize:15]];
    [logattr vk_setLineSpacing:10];
    [mtxt appendAttributedString:logattr];
    self.LogLabel.attributedText = mtxt;
    
    if (self.LogLabel.contentSize.height > self.LogLabel.frame.size.height) {
        CGPoint point = CGPointMake(0.f,self.LogLabel.contentSize.height - self.LogLabel.frame.size.height);
        [self.LogLabel setContentOffset:point animated:YES];
    }
#endif
}


@end
