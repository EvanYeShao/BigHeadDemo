//
//  BGDSelectedView.h
//  BigHeadDemo
//
//  Created by zangqilong on 14-9-22.
//  Copyright (c) 2014年 zangqilong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectedViewDelegate <NSObject>

@optional
- (void)longPressGestureDidMove:(CGPoint)moveCenter withCurrentWidth:(CGFloat)currentWidth ForView:(UIView *)view;

- (void)pinGestureDidScale:(CGFloat)currentWidth ForView:(UIView *)view;

@end

@interface BGDSelectedView : UIView<UIGestureRecognizerDelegate>
{
    CGFloat beginGestureScale;
    CGFloat effectiveScale;
    
    CGFloat currentWidth;
}

@property (nonatomic, weak) id<SelectedViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame isCircle:(BOOL)circle;

@end
