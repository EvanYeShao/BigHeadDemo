//
//  BGDViewController.h
//  BigHeadDemo
//
//  Created by zangqilong on 14-9-18.
//  Copyright (c) 2014年 zangqilong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BGDViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *bigHeadImageView;
@property (weak, nonatomic) IBOutlet UISlider *filterSlide;
@property (strong, nonatomic) IBOutlet UIView *addFrameButton;

@end
