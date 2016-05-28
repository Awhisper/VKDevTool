//
//  VKDebugConsole.m
//  VKDebugConsoleDemo
//
//  Created by Awhisper on 16/5/22.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "VKDebugConsole.h"
#import "VKConsoleButton.h"
#import "VKScriptConsole.h"
@interface VKDebugConsole ()

@property (nonatomic,strong) VKConsoleButton *debugBt;

@property (nonatomic,strong) VKScriptConsole *scriptView;

@property (nonatomic,strong) UITapGestureRecognizer *tapGesture;

@end

@implementation VKDebugConsole
VK_DEF_SINGLETON

-(instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appBecomeActive)
                                                     name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(VKConsoleButton *)debugBt
{
    if (!_debugBt) {
        VKConsoleButton *debugbt = [[VKConsoleButton alloc]initWithDefault];
        _debugBt = debugbt;
        [debugbt addTarget:self action:@selector(debugClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _debugBt;
}

-(void)showButton
{
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    [window addSubview:self.debugBt];
}

-(void)hideButton
{
    [self.debugBt removeFromSuperview];
}

-(void)debugClick
{
    if (self.scriptView.superview) {
        [self.scriptView hideConsole];
        [self.debugBt setTitle:@"Debug" forState:UIControlStateNormal];
        
    }else{
        self.tapGesture.enabled = YES;
        [self.debugBt setTitle:@"Select" forState:UIControlStateNormal];
    }
}

+(void)showBt
{
    [[self singleton] showButton];
}

+(void)hideBt
{
    [[self singleton] hideButton];
}

#pragma mark script
-(VKScriptConsole *)scriptView
{
    if (!_scriptView) {
        VKScriptConsole *scriptv = [[VKScriptConsole alloc]initWithFrame:CGRectMake(0, 0, VK_AppScreenWidth, VK_AppScreenHeight)];
        _scriptView = scriptv;
    }
    return _scriptView;
}


#pragma mark touch gesture
-(UITapGestureRecognizer *)tapGesture
{
    if (!_tapGesture) {
        UIWindow * window = [[UIApplication sharedApplication] keyWindow];
        // View selection
        UITapGestureRecognizer *selectionTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouchTap:)];
        [window addGestureRecognizer:selectionTapGR];
        selectionTapGR.enabled = NO;
        _tapGesture = selectionTapGR;
        
    }
    return _tapGesture;
}


-(void)handleTouchTap:(UITapGestureRecognizer *)tapGR
{
    UIView *gesturetarget = tapGR.view;
    CGPoint tapPointInView = [tapGR locationOfTouch:0 inView:gesturetarget];
    UIView *touchview = [self viewForSelectionAtPoint:tapPointInView];
    
    [gesturetarget insertSubview:self.scriptView belowSubview:self.debugBt];
    self.scriptView.target = touchview;
    [self.scriptView showConsole];
    [self.debugBt setTitle:@"Hide" forState:UIControlStateNormal];

}


- (UIView *)viewForSelectionAtPoint:(CGPoint)tapPointInWindow
{
    // Select in the window that would handle the touch, but don't just use the result of hitTest:withEvent: so we can still select views with interaction disabled.
    // Default to the the application's key window if none of the windows want the touch.
    UIWindow *windowForSelection = [[UIApplication sharedApplication] keyWindow];
    
    // Select the deepest visible view at the tap point. This generally corresponds to what the user wants to select.
    return [[self recursiveSubviewsAtPoint:tapPointInWindow inView:windowForSelection skipHiddenViews:YES] lastObject];
}


- (NSArray *)recursiveSubviewsAtPoint:(CGPoint)pointInView inView:(UIView *)view skipHiddenViews:(BOOL)skipHidden
{
    NSMutableArray *subviewsAtPoint = [NSMutableArray array];
    for (UIView *subview in view.subviews) {
        BOOL isHidden = subview.hidden || subview.alpha < 0.01;
        if (skipHidden && isHidden) {
            continue;
        }
        
        BOOL subviewContainsPoint = CGRectContainsPoint(subview.frame, pointInView);
        if (subviewContainsPoint) {
            [subviewsAtPoint addObject:subview];
        }
        
        // If this view doesn't clip to its bounds, we need to check its subviews even if it doesn't contain the selection point.
        // They may be visible and contain the selection point.
        if (subviewContainsPoint || !subview.clipsToBounds) {
            CGPoint pointInSubview = [view convertPoint:pointInView toView:subview];
            [subviewsAtPoint addObjectsFromArray:[self recursiveSubviewsAtPoint:pointInSubview inView:subview skipHiddenViews:skipHidden]];
        }
    }
    return subviewsAtPoint;
}

-(void)appBecomeActive
{
    if (self.scriptView.superview) {//调试状态
        NSString *pasteCode = [[UIPasteboard generalPasteboard] string];
        if (pasteCode.length > 0) {
            [self.scriptView setInputCode:pasteCode];
        }
    }
}


@end
