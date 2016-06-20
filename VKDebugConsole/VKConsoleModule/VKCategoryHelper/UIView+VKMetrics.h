//
//  UIView+VKMetrics.h
//
//  Created by awhisper on 15/1/19.
//  Copyright (c) 2015年 awhisper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (VKMetrics)


/*
 * @get&set frame.y
 */
@property (assign, nonatomic) CGFloat	top;

/*
 * @get&set frame.y + frame.height
 */
@property (assign, nonatomic) CGFloat	bottom;

/*
 * @get&set frame.x
 */
@property (assign, nonatomic) CGFloat	left;

/*
 * @get&set frame.x + frame.width
 */
@property (assign, nonatomic) CGFloat	right;

/*
 * @get&set 在uiwindow的(x,y)
 */
@property (assign, nonatomic) CGPoint	offset;
/*
 * @get&set 在superview的(x,y)
 */
@property (assign, nonatomic) CGPoint	position;

/*
 * @get&set frame.x
 */
@property (assign, nonatomic) CGFloat	x;
/*
 * @get&set frame.y
 */
@property (assign, nonatomic) CGFloat	y;
/*
 * @get&set frame.width
 */
@property (assign, nonatomic) CGFloat	w;
/*
 * @get&set frame.height
 */
@property (assign, nonatomic) CGFloat	h;

/*
 * @get&set frame.width
 */
@property (assign, nonatomic) CGFloat	width;
/*
 * @get&set frame.height
 */
@property (assign, nonatomic) CGFloat	height;
/*
 * @get&set (width,height)
 */
@property (assign, nonatomic) CGSize	size;

/*
 * @get&set centerX
 */
@property (assign, nonatomic) CGFloat	centerX;
/*
 * @get&set centerY
 */
@property (assign, nonatomic) CGFloat	centerY;
/*
 * @get&set 相对于superview的(x,y)
 */
@property (assign, nonatomic) CGPoint	origin;
/*
 * @return centerX
 */
@property (readonly, nonatomic) CGPoint	boundsCenter;



@end
