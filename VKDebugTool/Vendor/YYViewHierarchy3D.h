//
//  YYViewHierarchy3D.h
//  TestTe
//
//  Created by ibireme on 13-3-8.
//  2013 ibireme.
//

#import <UIKit/UIKit.h>

@interface  YYViewHierarchy3DTop : UIWindow
+ (YYViewHierarchy3DTop *)sharedInstance;
@end

/// just add [YYViewHierarchy3D show]; at App startup
@interface YYViewHierarchy3D : UIWindow
+ (YYViewHierarchy3D *)sharedInstance;
- (void)toggleShow;
+ (void)show;
+ (void)hide;
@end
