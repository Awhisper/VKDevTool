//
//  VKDebugConsole.m
//  VKDebugConsole
//
//  Created by Awhisper on 16/5/20.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "VKScriptConsoleView.h"
#import "VKCommonFundation.h"
#import "VKJPEngine.h"
//#import "VKLogManager.h"
#import "NSMutableAttributedString+VKAttributedString.h"
static CGFloat maskAlpha = 0.6f;

@interface VKScriptConsoleView ()<UITextViewDelegate>


@property (nonatomic,strong) UIView *mask;

@end

@implementation VKScriptConsoleView


#pragma mark construct

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self startScriptEngine];
    }
    return self;
}


-(void)setTarget:(id)target
{
    _target = target;
    [VKJPEngine setScriptWeakTarget:_target];
}

-(void)startScriptEngine
{
    [VKJPEngine startEngine];
    [VKJPEngine setScriptWeakTarget:self.target];
    __weak typeof(self) weakSelf = self;
    [VKJPEngine handleException:^(NSString *msg) {
        [weakSelf addScriptLogToOutput:msg WithUIColor:[UIColor orangeColor]];
    }];
    
    [VKJPEngine handleLog:^(NSString *msg) {
        [weakSelf addScriptLogToOutput:msg WithUIColor:[UIColor whiteColor]];
    }];
    
    [VKJPEngine handleCommand:^(NSString *command) {
        if ([command isEqualToString:@"changeSelect"]) {
            [weakSelf.delegate VKScriptConsoleExchangeTargetAction];
        }
        
        if ([command isEqualToString:@"exit"]) {
            [weakSelf.delegate VKScriptConsoleExitAction];
        }
        
        if ([command isEqualToString:@"clearInput"]) {
            weakSelf.inputView.text = @"";
        }
        
        if ([command isEqualToString:@"clearOutput"]) {
            weakSelf.outputView.text = @"";
        }
    }];
}

-(UIView *)mask
{
    if (!_mask) {
        UIView *maskv = [[UIView alloc]initWithFrame:self.bounds];
        maskv.backgroundColor = [UIColor blackColor];
        maskv.alpha = maskAlpha;
        _mask = maskv;
        [self addSubview:maskv];
    }
    return _mask;
}

-(UITextView *)inputView
{
    if (!_inputView) {
        UITextView * input = [[UITextView alloc]initWithFrame:CGRectMake(0, 20, self.width, self.height/3)];
        _inputView = input;
        input.textColor = [UIColor whiteColor];
        input.layer.borderWidth = 1;
        input.layer.borderColor = [UIColor blackColor].CGColor;
        input.delegate = self;
        input.backgroundColor = [UIColor clearColor];
        input.font = [UIFont boldSystemFontOfSize:15];
        [self addSubview:input];
    }
    return _inputView;
}

-(UITextView *)outputView
{
    if (!_outputView) {
        UITextView * output = [[UITextView alloc]initWithFrame:CGRectMake(0, self.height/3 + 20, self.width, self.height*2/3 - 20)];
        _outputView = output;
        output.textColor = [UIColor yellowColor];
        [self addSubview:output];
        output.backgroundColor = [UIColor clearColor];
        [self addScriptLogToOutput:@"Output:" WithUIColor:[UIColor whiteColor]];
        output.editable = NO;
    }
    return _outputView;
}

-(void)showConsole
{
    [super showConsole];
    self.inputView.text = @"";
    self.outputView.text = @"output:";
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)hideConsole
{
    [super hideConsole];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



-(void)addScriptLogToOutput:(NSString *)log WithUIColor:(UIColor *)color{
    NSAttributedString *txt = self.outputView.attributedText;
    NSMutableAttributedString *mtxt = [[NSMutableAttributedString alloc]initWithAttributedString:txt];
    NSAttributedString *huanhang = [[NSAttributedString alloc]initWithString:@"\n"];
    [mtxt appendAttributedString:huanhang];
    
    NSMutableAttributedString *logattr = [[NSMutableAttributedString alloc]initWithString:log];
    [logattr vk_setTextColor:color];
    [logattr vk_setFont:[UIFont boldSystemFontOfSize:15]];
    [logattr vk_setLineSpacing:10];
    [mtxt appendAttributedString:logattr];
    self.outputView.attributedText = mtxt;
    
    if (self.outputView.contentSize.height > self.outputView.frame.size.height) {
        CGPoint point = CGPointMake(0.f,self.outputView.contentSize.height - self.outputView.frame.size.height);
        [self.outputView setContentOffset:point animated:YES];
    }
}
#pragma mark logic delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        //在这里做你响应return键的代码
//        self.outputView.text = @"output:";
        [VKJPEngine evaluateScript:textView.text];
        
        return YES;
    }
    
    return YES;
}

-(void)setInputCode:(NSString *)code
{
    self.inputView.text = code;
}


-(void)appBecomeActive
{
    NSString *pasteCode = [[UIPasteboard generalPasteboard] string];
    if (pasteCode.length > 0) {
        [self setInputCode:pasteCode];
    }
}

@end
