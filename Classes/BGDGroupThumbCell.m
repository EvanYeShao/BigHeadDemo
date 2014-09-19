//
//  BGDGroupThumbCell.m
//  BigHeadDemo
//
//  Created by zangqilong on 14-9-19.
//  Copyright (c) 2014年 zangqilong. All rights reserved.
//

#import "BGDGroupThumbCell.h"

@implementation BGDGroupThumbCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    _bottomImageView.transform = CGAffineTransformMakeRotation(15*M_PI/180);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
