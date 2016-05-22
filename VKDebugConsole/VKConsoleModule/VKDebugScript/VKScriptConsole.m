//
//  VKDebugConsole.m
//  VKDebugConsole
//
//  Created by Awhisper on 16/5/20.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "VKScriptConsole.h"
#import "VKCommonFundation.h"
#import "VKJPEngine.h"

static CGFloat maskAlpha = 0.6f;

@interface VKScriptConsole ()<UITextViewDelegate>


@property (nonatomic,strong) UIView *mask;

@property (nonatomic,strong) UITextView *inputView;

@property (nonatomic,strong) UITextView *outputView;

@end

@implementation VKScriptConsole

//+(void)show{
//    VKScriptConsole * debug = [[VKScriptConsole alloc]initWithCurrentVC];
//    [debug showConsole];
//}

#pragma mark construct

//-(instancetype)initWithCurrentVC
//{
//    UIViewController *curVC = [self getCurrentVC];
//    return [self initWithTarget:curVC];
//}
//
//-(instancetype)initWithTarget:(id)target
//{
//    self = [self initWithFrame:CGRectMake(0, 0, VK_AppScreenWidth, VK_AppScreenHeight)];
//    if (self) {
//        self.target = target;
//        [self startScriptEngine];
//    }
//    return self;
//}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.mask.alpha = 0;
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
        [weakSelf addScriptLogToOutput:msg];
    }];
    
    [VKJPEngine handleLog:^(NSString *msg) {
        [weakSelf addScriptLogToOutput:msg];
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
        UITextView * input = [[UITextView alloc]initWithFrame:CGRectMake(0, 20, self.width, self.height/2)];
        _inputView = input;
        input.textColor = [UIColor yellowColor];
        input.layer.borderWidth = 1;
        input.layer.borderColor = [UIColor blackColor].CGColor;
        input.delegate = self;
        input.backgroundColor = [UIColor clearColor];
        [self addSubview:input];
    }
    return _inputView;
}

-(UITextView *)outputView
{
    if (!_outputView) {
        UITextView * output = [[UITextView alloc]initWithFrame:CGRectMake(0, self.height/2 + 20, self.width, self.height/2)];
        _outputView = output;
        output.textColor = [UIColor yellowColor];
        [self addSubview:output];
        output.backgroundColor = [UIColor clearColor];
        output.text = @"output:";
    }
    return _outputView;
}

-(void)showConsole
{
    self.alpha = 0;
    self.inputView.text = @"";
    self.outputView.text = @"output:";
    [UIView animateWithDuration:0.5f animations:^{
        self.alpha = 1;
        self.mask.alpha = maskAlpha;
        self.inputView.alpha = 1;
        self.outputView.alpha = 1;
    } completion:^(BOOL finished) {
    
    }];
}

-(void)hideConsole
{
    [UIView animateWithDuration:1.0f animations:^{
        self.alpha = 0;
        self.mask.alpha = 0;
        self.inputView.alpha = 0;
        self.outputView.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


#pragma mark logic delegate
-(void)addScriptLogToOutput:(NSString *)log{
    NSString *txt = self.outputView.text;
    txt = [txt stringByAppendingString:@"\n"];
    txt = [txt stringByAppendingString:log];
    self.outputView.text = txt;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        //在这里做你响应return键的代码
        self.outputView.text = @"output:";
        [VKJPEngine evaluateScript:textView.text];
        
        return YES;
    }
    
    return YES;
}


@end
