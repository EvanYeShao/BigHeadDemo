//
//  BGDSelectedView.m
//  BigHeadDemo
//
//  Created by zangqilong on 14-9-22.
//  Copyright (c) 2014年 zangqilong. All rights reserved.
//

#import "BGDSelectedView.h"
#import "UIView+Positioning.h"

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))

@implementation BGDSelectedView

- (instancetype)initWithFrame:(CGRect)frame isCircle:(BOOL)circle
{
    self = [super initWithFrame:frame];
    if (self) {
        if (circle) {
         // self.layer.cornerRadius = CGRectGetHeight(self.frame)/2;

        }
        currentWidth = self.width;
        
        beginGestureScale = effectiveScale = 1.0;
        
//        self.layer.masksToBounds = YES;
//        self.layer.borderColor = [UIColor whiteColor].CGColor;
//        self.layer.borderWidth = 2;
        
        UIPinchGestureRecognizer *pinGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
        pinGesture.delegate = self;
        [self addGestureRecognizer:pinGesture];
        
        UILongPressGestureRecognizer *panGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [self addGestureRecognizer:panGesture];
        
        // Background ImageView
        
        bgImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        bgImageView.image = [UIImage imageNamed:@"circle"];
        [self addSubview:bgImageView];
        
        // 拉升图片坐标
        CGFloat scaleX = self.width/2+self.width/2*sin(RADIANS_TO_DEGREES(45))-10;
        CGFloat scaleY = self.width+self.width/2*cos(RADIANS_TO_DEGREES(45));
        scaleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(scaleX, scaleY, 26, 26)];
        scaleImageView.image = [UIImage imageNamed:@"sticker_scale"];
        [self addSubview:scaleImageView];
        [self bringSubviewToFront:scaleImageView];
        
        // 移除图片坐标
        CGFloat deleteX = self.width/2-self.width/2*sin(RADIANS_TO_DEGREES(45));
        CGFloat deleteY = self.width-self.width/2*cos(RADIANS_TO_DEGREES(45));
        deleteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(deleteX, deleteY, 26, 26)];
        deleteImageView.image = [UIImage imageNamed:@"sticker_delete"];
        [self addSubview:deleteImageView];
        [self bringSubviewToFront:deleteImageView];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
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
        scaleImageView.transform = CGAffineTransformIdentity;
    }];
    
    if ([self.delegate respondsToSelector:@selector(pinGestureDidScale:ForView:)]&&self.delegate) {
        [self.delegate pinGestureDidScale:currentWidth/effectiveScale ForView:self];
    }

    
}

- (void)handlePanGesture:(UILongPressGestureRecognizer *)gesture
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
