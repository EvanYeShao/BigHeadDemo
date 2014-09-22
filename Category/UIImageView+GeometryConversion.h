//
//  BGDGroupPickerViewController.m
//  BigHeadDemo
//
//  Created by zangqilong on 14-9-19.
//  Copyright (c) 2014年 zangqilong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface UIImageView (GeometryConversion)

- (CGPoint)convertPointFromImage:(CGPoint)imagePoint;
- (CGRect)convertRectFromImage:(CGRect)imageRect;

- (CGPoint)convertPointFromView:(CGPoint)viewPoint;
- (CGRect)convertRectFromView:(CGRect)viewRect;

- (CGFloat)getScaleRatioFromImage;

-(CGRect) cropRectForFrame:(CGRect)frame;
@end
