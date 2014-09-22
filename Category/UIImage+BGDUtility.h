//
//  UIImage+BGDUtility.h
//  BigHeadDemo
//
//  Created by zangqilong on 14-9-22.
//  Copyright (c) 2014年 zangqilong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (BGDUtility)

- (UIImage *)cropImageInRect:(CGRect)rect;

- (UIImage *)addImage:(UIImage *)image inRect:(CGRect)smallRect;
@end
