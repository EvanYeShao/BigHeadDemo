//
//  BGDSelectedView.m
//  BigHeadDemo
//
//  Created by zangqilong on 14-9-22.
//  Copyright (c) 2014年 zangqilong. All rights reserved.
//

#import "BGDSelectedView.h"
#import "UIView+Positioning.h"

@implementation BGDSelectedView

- (instancetype)initWithFrame:(CGRect)frame isCircle:(BOOL)circle
{
    self = [super initWithFrame:frame];
    if (self) {
        if (circle) {
          self.layer.cornerRadius = CGRectGetHeight(self.frame)/2;

        }
        currentWidth = self.width;
        
        beginGestureScale = effectiveScale = 1.0;
        
        self.layer.masksToBounds = YES;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 2;
        
        UIPinchGestureRecognizer *pinGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
        pinGesture.delegate = self;
        [self addGestureRecognizer:pinGesture];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
        [self addGestureRecognizer:longPress];
    }
    return self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    //记录上一次拉伸的数值
    if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
        beginGestureScale = effectiveScale;
    }
    return YES;
}


- (void)handlePinchGesture:(UIPinchGestureRecognizer *)gestureRecognizer
{
    effectiveScale = beginGestureScale * gestureRecognizer.scale;
    
    currentWidth = self.width *effectiveScale;
    if (effectiveScale < 1.0)
    {
        effectiveScale = 1.0;
        currentWidth = self.width;
    }
    
    if (effectiveScale > 2)
    {
        effectiveScale = 2;
        currentWidth = self.width*effectiveScale;
    }
    
    
    [UIView animateWithDuration:0.025 animations:^{
        self.transform = CGAffineTransformMakeScale(effectiveScale, effectiveScale);
    }];
    
    if ([self.delegate respondsToSelector:@selector(pinGestureDidScale:ForView:)]&&self.delegate) {
        [self.delegate pinGestureDidScale:currentWidth/effectiveScale ForView:self];
    }

    
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)gesture
{

    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            NSLog(@"gesture began");
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint location = [gesture locationInView:self.superview];
            
            if ([self.delegate respondsToSelector:@selector(longPressGestureDidMove:withCurrentWidth:ForView:)]&&self.delegate) {
                [self.delegate longPressGestureDidMove:location withCurrentWidth:currentWidth/effectiveScale ForView:self];
            }
           
        }
            
            break;
        default:
            break;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
