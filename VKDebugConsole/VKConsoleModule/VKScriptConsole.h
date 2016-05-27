//
//  VKDebugConsole.h
//  VKDebugConsole
//
//  Created by Awhisper on 16/5/20.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VKScriptConsole : UIView

@property (nonatomic,weak) id target;

-(void)showConsole;
-(void)hideConsole;

-(void)addScriptLogToOutput:(NSString *)log WithUIColor:(UIColor *)color;

@end
