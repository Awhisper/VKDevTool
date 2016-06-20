//
//  UIDevice+VKUtlities.m
//
//  Created by awhisper on 15/1/13.
//  Copyright (c) 2015年 awhisper. All rights reserved.
//

#import "UIDevice+VKUtlities.h"
#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <sys/utsname.h>

static int coreNum = -1;

@implementation UIDevice (VKUtlities)

static BOOL __cached_ios8_or_later;
static BOOL __cached_ios7_or_later;
static BOOL __cached_ios6_or_later;
static BOOL __is_dure_core;
static BOOL __is_ipad;
static BOOL __is_iphone4;
static BOOL __is_iphone5;
static BOOL __is_iphone6;
static BOOL __is_iphone6plus;

+(void)load{
    NSString *currentVersion = [[UIDevice currentDevice] systemVersion];
    
    __cached_ios8_or_later = ([currentVersion compare:@"8.0" options:NSNumericSearch] != NSOrderedAscending);
    __cached_ios7_or_later = ([currentVersion compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending);
    __cached_ios6_or_later = ([currentVersion compare:@"6.0" options:NSNumericSearch] != NSOrderedAscending);
    __is_dure_core = [UIDevice VK_isDualCoreInterLine];
    __is_ipad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    if(__is_ipad){
        __is_iphone4 = NO;
        __is_iphone5 = NO;
        __is_iphone6 = NO;
        __is_iphone6plus = NO;
    }else{
        CGRect bounds = [UIScreen mainScreen].bounds;
        __is_iphone4 = (CGSizeEqualToSize(bounds.size, CGSizeMake(320, 480))||CGSizeEqualToSize(bounds.size, CGSizeMake(480, 320)));
        if(__is_iphone4){
            __is_iphone5 = NO;
            __is_iphone6 = NO;
            __is_iphone6plus = NO;
        }else{
            __is_iphone5 = (CGSizeEqualToSize(bounds.size, CGSizeMake(320, 568))||CGSizeEqualToSize(bounds.size, CGSizeMake(560, 320)));
            if(__is_iphone5){
                __is_iphone6 = NO;
                __is_iphone6plus = NO;
            }else{
                __is_iphone6 = (CGSizeEqualToSize(bounds.size, CGSizeMake(375, 667))||CGSizeEqualToSize(bounds.size, CGSizeMake(667, 375)));
                if(__is_iphone6){
                    __is_iphone6plus = NO;
                }else{
                    __is_iphone6plus = (CGSizeEqualToSize(bounds.size, CGSizeMake(414, 736))||CGSizeEqualToSize(bounds.size, CGSizeMake(736, 414)));
                }
            }
        }
    }
}

+(BOOL)VK_ios8_or_later{
    return __cached_ios8_or_later;
}

+(BOOL)VK_ios7_or_later{
    return __cached_ios7_or_later;
}

+(BOOL)VK_ios6_or_later{
    return __cached_ios6_or_later;
}

+(BOOL)VK_is_iPhone4{
    return __is_iphone4;
}

+(BOOL)VK_is_iPhone5{
    return __is_iphone5;
}

+(BOOL)VK_is_iPhone6{
    return __is_iphone6;
}

+(BOOL)VK_is_iPhone6Plus{
    return __is_iphone6plus;
}

#pragma mark -
#pragma mark Private Methods
////////////////////////////////////////////////////////////////////////////////

- (NSString *)VK_platform{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

- (NSString *)VK_platformString{
    NSString *platform = [self VK_platform];
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G (A1203)";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G (A1241/A1324)";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS (A1303/A1325)";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4 (A1349)";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S (A1387/A1431)";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5 (A1428)";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5 (A1429/A1442)";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c (A1456/A1532)";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c (A1507/A1516/A1526/A1529)";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s (A1453/A1533)";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s (A1457/A1518/A1528/A1530)";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus (A1522/A1524)";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6 (A1549/A1586)";
    
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G (A1213)";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G (A1288)";
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G (A1318)";
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G (A1367)";
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G (A1421/A1509)";
    
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1G (A1219/A1337)";
    
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2 (A1395)";
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2 (A1396)";
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2 (A1397)";
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2 (A1395+New Chip)";
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G (A1432)";
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G (A1454)";
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G (A1455)";
    
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3 (A1416)";
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3 (A1403)";
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3 (A1430)";
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4 (A1458)";
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4 (A1459)";
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4 (A1460)";
    
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air (A1474)";
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air (A1475)";
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air (A1476)";
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G (A1489)";
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G (A1490)";
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G (A1491)";
    
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    return platform;
}

static struct utsname systemInfo;

+(BOOL) VK_isDualCoreInterLine{
    if (-1==coreNum) {
        BOOL result = NO;
        NSString *device = [self VK_machineName];
        
        if ([device rangeOfString:@"iPod"].location != NSNotFound) {
            //iPod 4以上
            result = [device compare:@"iPod4,1" options:NSNumericSearch] == NSOrderedDescending;
        }else if ([device rangeOfString:@"iPhone"].location != NSNotFound){
            //iPhone 4以上， iPhone4有两个版，最高是iPhone3,3
            
            result = [device compare:@"iPhone3,3" options:NSNumericSearch] == NSOrderedDescending;
        }else if ([device rangeOfString:@"iPad"].location != NSNotFound)
        {
            //iPad 3开始
            result = [device compare:@"iPad2,7" options:NSNumericSearch] == NSOrderedDescending;
        }
        else{
            result = YES;
        }
        if (result) {
            coreNum = 2;
        }else{
            coreNum = 1;
        }
        return result;
    }else
        if (coreNum==1) {
            return NO;
        }else
            if (coreNum==2) {
                return YES;
            }
    
    return YES;
}

+(BOOL) VK_isDualCore{
    return __is_dure_core;
}

+(BOOL) VK_isIpad{
    return __is_ipad;
}


+(NSString*) VK_machineName
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        uname(&systemInfo);
    });
    
    NSString *deviceName =  [NSString stringWithCString:systemInfo.machine
                                               encoding:NSUTF8StringEncoding];
    
    return deviceName;
}


@end
