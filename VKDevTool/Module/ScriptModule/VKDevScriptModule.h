//
//  VKDevScriptModule.h
//  VKDebugToolDemo
//
//  Created by Awhisper on 16/8/17.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VKDevModuleProtocol.h"

@interface VKDevScriptModule : NSObject<VKDevModuleProtocol>

-(void)startScriptDebug;

@end
