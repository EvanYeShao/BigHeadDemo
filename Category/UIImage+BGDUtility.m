//
//  UIImage+BGDUtility.m
//  BigHeadDemo
//
//  Created by zangqilong on 14-9-22.
//  Copyright (c) 2014年 zangqilong. All rights reserved.
//

#import "UIImage+BGDUtility.h"
#import <CoreImage/CoreImage.h>

@implementation UIImage (BGDUtility)

- (UIImage *)cropImageInRect:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return result;

}

- (UIImage *)addImage:(UIImage *)image inRect:(CGRect)smallRect
{
    UIGraphicsBeginImageContext(self.size);
    
    // Draw image1
    [self drawInRect:CGRectMake(0,0, self.size.width, self.size.height)];
    
    // Draw image2
    [image drawInRect:CGRectMake(smallRect.origin.x,smallRect.origin.y, image.size.width, image.size.height)];
    
    UIImage *resultingImage =UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return  resultingImage;
}

@end
