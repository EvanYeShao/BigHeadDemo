//
//  BGDPreviewController.h
//  BigHeadDemo
//
//  Created by zangqilong on 14-9-22.
//  Copyright (c) 2014年 zangqilong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BGDPreviewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;
@property (nonatomic, strong) UIImage *previewImage;
@end
