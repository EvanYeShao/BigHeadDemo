//
//  BGDViewController.m
//  BigHeadDemo
//
//  Created by zangqilong on 14-9-18.
//  Copyright (c) 2014年 zangqilong. All rights reserved.
//

#import "BGDViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>

@interface BGDViewController ()<UIGestureRecognizerDelegate>
{
    UIImage *originalImage;
    UIImage *tempImage;
    
    CGFloat beginGestureScale;
    CGFloat effectiveScale;
    
    CIContext *_context;
    CGFloat imageScale;
}
@property (nonatomic, copy) NSArray *assets;
@end

@implementation BGDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _context = [CIContext contextWithOptions:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getImage:) name:@"kChoosedImage" object:nil];
    
    beginGestureScale = effectiveScale = 1.0;
    
    
  
    
    _framButton.layer.masksToBounds = YES;
    _framButton.layer.cornerRadius = CGRectGetHeight(_framButton.frame)/2;
    _framButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _framButton.layer.borderWidth = 2;
    
    UIPinchGestureRecognizer *pinGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    pinGesture.delegate = self;
    [_framButton addGestureRecognizer:pinGesture];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [_framButton addGestureRecognizer:longPress];

}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    //记录上一次拉伸的数值
    if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
        beginGestureScale = effectiveScale;
    }
    return YES;
}


- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer
{
    
    BOOL allTouchesAreOnThePreviewLayer = YES;
    NSUInteger numTouches = [recognizer numberOfTouches], i;
    for ( i = 0; i < numTouches; ++i ) {
        CGPoint location = [recognizer locationOfTouch:i inView:self.bigHeadImageView];
        CGPoint convertedLocation = [self.bigHeadImageView.layer convertPoint:location fromLayer:self.view.layer];
        if ( ! [_bigHeadImageView.layer containsPoint:convertedLocation] ) {
            allTouchesAreOnThePreviewLayer = NO;
            NSLog(@"break handle");
            break;
        }
    }
    
    
    
    if ( allTouchesAreOnThePreviewLayer ) {
        
        NSLog(@"handle pin scale is %f",recognizer.scale);
        effectiveScale = beginGestureScale * recognizer.scale;
        if (effectiveScale < 1.0)
            effectiveScale = 1.0;
        
        if (effectiveScale > 2)
            effectiveScale = 2;
        [UIView animateWithDuration:0.025 animations:^{
            _framButton.transform = CGAffineTransformMakeScale(effectiveScale, effectiveScale);
        }];
    }
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint location = [gesture locationInView:self.bigHeadImageView];
            _framButton.center = location;
        }
            
            break;
        default:
            break;
    }
}

- (void)getImage:(NSNotification *)noti
{
    originalImage  = (UIImage *)noti.object;
    tempImage = originalImage;
    self.bigHeadImageView.image = originalImage;
    CGRect scaledRect =  AVMakeRectWithAspectRatioInsideRect(originalImage.size,self.bigHeadImageView.bounds);
    imageScale = originalImage.size.width/scaledRect.size.width;
    NSLog(@"originalImage width is %f,height is %f",originalImage.size.width,originalImage.size.height);
    NSLog(@"width is %f,height is %f",scaledRect.size.width,scaledRect.size.height);
}

#pragma mark -
#pragma mark Slide Action

- (IBAction)slideValueChanged:(id)sender
{
    NSLog(@"value changed");
    UISlider *slider = (UISlider *)sender;
    if (!originalImage) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请先加载tup" message:nil delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
        return;
    }else
    {
        CGPoint convertPoint = [self.view convertPoint:_framButton.center toView:self.bigHeadImageView];
       
       self.bigHeadImageView.image = [self distortionFilterWithImage:tempImage
                                                          WithVector:CGPointMake(_framButton.center.x, _framButton.center.y)
                                                          WithRadius:_framButton.bounds.size.width*imageScale
                                                          WithScale:(slider.value)];
    }
}

#pragma mark  -
#pragma mark CIBumpDistortion

-(UIImage *)distortionFilterWithImage:(UIImage *)image WithVector:(CGPoint)vector WithRadius:(CGFloat)radius
                            WithScale:(CGFloat)scale
{
    if (!image) return nil;
    
    CIImage *input = [CIImage imageWithCGImage:image.CGImage];
    CIFilter *bumpDistortion = [CIFilter filterWithName:@"CIBumpDistortion"];
    [bumpDistortion setValue:input forKey:kCIInputImageKey];
    [bumpDistortion setValue:[CIVector vectorWithX:originalImage.size.width/2+50 Y:originalImage.size.height/2] forKey:@"inputCenter"];
    [bumpDistortion setValue:[NSNumber numberWithFloat:radius] forKey:@"inputRadius"];
    [bumpDistortion setValue:[NSNumber numberWithFloat:scale] forKey:@"inputScale"];
    
    return [self imageWithCoreImage:[bumpDistortion outputImage]];
}

- (UIImage *)imageWithCoreImage:(CIImage *)image
{
    // 生成图片需要调整方向，不然加完滤镜图像是landscape方向。
    CGImageRef cgimg = [_context createCGImage:image fromRect:[image extent]];
    UIImage *uiimage = [UIImage imageWithCGImage:cgimg scale:1.0 orientation:originalImage.imageOrientation];
    CGImageRelease(cgimg);
    
    return uiimage;
}

#pragma mark - Open Asset Picker
- (IBAction)openImagePickerController:(id)sender
{
    [self performSegueWithIdentifier:@"modalToGroup" sender:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
