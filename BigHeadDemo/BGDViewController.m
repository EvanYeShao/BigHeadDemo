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
#import "UIImageView+GeometryConversion.h"
#import "UIView+Positioning.h"
#import "BGDSelectedView.h"
#import "UIImage+BGDUtility.h"
#import "BGDPreviewController.h"

CGFloat const kBeginWidth = 100.0f;

@interface BGDViewController ()<SelectedViewDelegate>
{
    UIImage *originalImage;
    UIImage *tempImage;
    UIImage *bumpImage;
    
    CIContext *_context;
    CGFloat imageScale;
    CGFloat circleWidth;
    CGFloat rectangleWidth;
    
    BOOL rectangleShow;
    
    BGDSelectedView *circleView;
    BGDSelectedView *rectangleView;
    
    CGRect overstepBoundary;
    CGRect convertRectForCrop;
    CGRect convertCircleForCrop;
}
@property (nonatomic, copy) NSArray *assets;
@end

@implementation BGDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _context = [CIContext contextWithOptions:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getImage:) name:@"kChoosedImage" object:nil];
    
    circleWidth = rectangleWidth = kBeginWidth;
    
    circleView = [[BGDSelectedView alloc] initWithFrame:
                  CGRectMake(_bigHeadImageView.width/2,_bigHeadImageView.height/2, kBeginWidth,kBeginWidth) isCircle:YES];
    circleView.delegate = self;
    [_bigHeadImageView addSubview:circleView];
    
    rectangleView = [[BGDSelectedView alloc] initWithFrame:
                     CGRectMake(_bigHeadImageView.width/2,_bigHeadImageView.height/2, kBeginWidth,kBeginWidth) isCircle:NO];
    rectangleView.delegate = self;
 
}

#pragma mark - Notification Method
- (void)getImage:(NSNotification *)noti
{
  
    originalImage  = (UIImage *)noti.object;
    tempImage = originalImage;
    self.bigHeadImageView.image = originalImage;
    imageScale = [self.bigHeadImageView getScaleRatioFromImage];
    
    // 越界边界
    
    CGFloat overX = (self.bigHeadImageView.width  - originalImage.size.width  * imageScale) / 2.0f;
   
    CGFloat overY = (self.bigHeadImageView.height  - originalImage.size.height  * imageScale) / 2.0f;
    CGFloat overWidth = self.bigHeadImageView.width - overX*2;
    CGFloat overHeight = self.bigHeadImageView.height - overY*2;
    overstepBoundary = CGRectMake(overX, overY, overWidth, overHeight);
    
}

#pragma mark - SelectedView delegate

- (void)pinGestureDidScale:(CGFloat)currentWidth ForView:(UIView *)view
{
    if (view == circleView) {
        circleWidth = currentWidth;
    }else
    {
        rectangleWidth = currentWidth;
    }
}

- (void)longPressGestureDidMove:(CGPoint)moveCenter withCurrentWidth:(CGFloat)currentWidth ForView:(UIView *)view
{
    
    CGPoint fixPosition = moveCenter;
    
    if (moveCenter.x-currentWidth/2 <= overstepBoundary.origin.x) {
        fixPosition.x = overstepBoundary.origin.x+currentWidth/2;
   
    }
    if (moveCenter.x+currentWidth/2 >= overstepBoundary.origin.x+overstepBoundary.size.width) {
        fixPosition.x = overstepBoundary.origin.x+overstepBoundary.size.width-currentWidth/2;
    }
    if (moveCenter.y-currentWidth/2 <= overstepBoundary.origin.y) {
        fixPosition.y = overstepBoundary.origin.y+currentWidth/2;
    }
    if (moveCenter.y+currentWidth/2 >= overstepBoundary.origin.y+overstepBoundary.size.height) {
        fixPosition.y = overstepBoundary.origin.y+overstepBoundary.size.height-currentWidth/2;
    }
    view.center = fixPosition;
    rectangleView.bgImageView.image = nil;
    
}

#pragma mark - Slide Action

- (IBAction)slideValueChanged:(id)sender
{
    
    UISlider *slider = (UISlider *)sender;
    if (!originalImage) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请先加载图片" message:nil delegate:nil
                                              cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
        return;
    }else
    {
        CGPoint convertPoint = circleView.center;
        convertPoint = CGPointMake(convertPoint.x, self.bigHeadImageView.height-convertPoint.y);
        
        CGPoint imagePoint = [self.bigHeadImageView convertPointFromView:convertPoint];
        bumpImage = [self distortionFilterWithImage:tempImage
                                                           WithVector:imagePoint
                                                           WithRadius:circleWidth*2/imageScale
                                                            WithScale:(slider.value)*0.6];
        
        self.bigHeadImageView.image = bumpImage;
      
    }
}

#pragma mark - BarButton Action

- (IBAction)handlebarButtonAction:(id)sender
{
    if (rectangleShow) {
        // 视图中矩形的位置
        CGRect currentImageRect = CGRectMake(rectangleView.x, rectangleView.y, rectangleWidth, rectangleWidth);
        
        // 转换到图片中的矩形位置
        convertRectForCrop = [self.bigHeadImageView cropRectForFrame:currentImageRect];
        NSLog(@"x is %f,y is %f,rectanglewidth is %f",convertRectForCrop.origin.x,convertRectForCrop.origin.y,convertRectForCrop.size.width);
        
        UIImage *convertImage = [bumpImage cropImageInRect:convertRectForCrop];
        
        rectangleView.bgImageView.image = [self oldPhotowithImage:convertImage Amount:0.5 withSize:CGSizeMake(convertRectForCrop.size.width, convertRectForCrop.size.width)];
    }
    
}

#pragma mark - Plus Action

- (IBAction)handlePlusAction:(id)sender
{
    if (rectangleShow) {
         [rectangleView removeFromSuperview];
       
    }else
    {
        [_bigHeadImageView addSubview:rectangleView];
    }
     rectangleShow = !rectangleShow;
}

#pragma mark - CIBumpDistortion

-(UIImage *)distortionFilterWithImage:(UIImage *)image WithVector:(CGPoint)vector WithRadius:(CGFloat)radius
                            WithScale:(CGFloat)scale
{
    if (!image) return nil;
    
    CIImage *input = [CIImage imageWithCGImage:image.CGImage];
    CIFilter *bumpDistortion = [CIFilter filterWithName:@"CIBumpDistortion"];
    [bumpDistortion setValue:input forKey:kCIInputImageKey];
    [bumpDistortion setValue:[CIVector vectorWithX:vector.x Y:vector.y] forKey:@"inputCenter"];
    [bumpDistortion setValue:[NSNumber numberWithFloat:radius] forKey:@"inputRadius"];
    [bumpDistortion setValue:[NSNumber numberWithFloat:scale] forKey:@"inputScale"];
    
    return [self imageWithCoreImage:[bumpDistortion outputImage] withSize:originalImage.size];
}

- (UIImage *)imageWithCoreImage:(CIImage *)image withSize:(CGSize)size
{
    // 生成图片需要调整方向，不然加完滤镜图像是landscape方向。
    CGImageRef cgimg = [_context createCGImage:image fromRect:
                        CGRectMake(0, 0, size.width, size.height)];
    UIImage *uiimage = [UIImage imageWithCGImage:cgimg scale:1.0 orientation:originalImage.imageOrientation];
    CGImageRelease(cgimg);
    
    return uiimage;
}

#pragma mark  -
#pragma mark OldPhoto

-(UIImage *)oldPhotowithImage:(UIImage *)image Amount:(float)intensity withSize:(CGSize)size{
    CIImage *input = [CIImage imageWithCGImage:image.CGImage];
    CIFilter *sepia = [CIFilter filterWithName:@"CISepiaTone"];
    [sepia setValue:input forKey:kCIInputImageKey];
    [sepia setValue:@(intensity) forKey:@"inputIntensity"]; //1
    
    CIFilter *random = [CIFilter filterWithName:@"CIRandomGenerator"];  //2
    
    CIFilter *lighten = [CIFilter filterWithName:@"CIColorControls"];
    [lighten setValue:random.outputImage forKey:kCIInputImageKey];
    [lighten setValue:@(1 - intensity) forKey:@"inputBrightness"];
    [lighten setValue:@0.0 forKey:@"inputSaturation"];  //3
    
    CIImage *croppedImage = [lighten.outputImage imageByCroppingToRect:[input extent]];  //4
    
    CIFilter *composite = [CIFilter filterWithName:@"CIHardLightBlendMode"];
    [composite setValue:sepia.outputImage forKey:kCIInputImageKey];
    [composite setValue:croppedImage forKey:kCIInputBackgroundImageKey];  //5
    
    CIFilter *vignette = [CIFilter filterWithName:@"CIVignette"];
    [vignette setValue:composite.outputImage forKey:kCIInputImageKey];
    [vignette setValue:@(intensity * 2) forKey:@"inputIntensity"];
    [vignette setValue:@(intensity * 30) forKey:@"inputRadius"];  //6
    
    return [self imageWithCoreImage:[vignette outputImage] withSize:size]; //7
}

#pragma mark - Open Asset Picker
- (IBAction)openImagePickerController:(id)sender
{
    [self performSegueWithIdentifier:@"modalToGroup" sender:nil];
    
}

#pragma mark - Push To Preview
- (IBAction)pushToPreview:(id)sender
{
    [self performSegueWithIdentifier:@"pushToPreview" sender:nil];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"pushToPreview"]) {
        BGDPreviewController *previewController = (BGDPreviewController *)segue.destinationViewController;
        if (rectangleView.bgImageView.image) {
            previewController.previewImage = [self.bigHeadImageView.image addImage:rectangleView.bgImageView.image inRect:convertRectForCrop];
        }else
        {
            previewController.previewImage =self.bigHeadImageView.image;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
