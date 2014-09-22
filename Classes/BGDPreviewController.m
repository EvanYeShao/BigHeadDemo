//
//  BGDPreviewController.m
//  BigHeadDemo
//
//  Created by zangqilong on 14-9-22.
//  Copyright (c) 2014年 zangqilong. All rights reserved.
//

#import "BGDPreviewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

NSString * const kCustomAlbumName = @"BigHeadAlbum";

@interface BGDPreviewController ()
{
    ALAssetsLibrary *library;
}

@end

@implementation BGDPreviewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.previewImageView.image = self.previewImage;
    library = [[ALAssetsLibrary alloc] init];
    
}

- (IBAction)exportToLibrary:(id)sender
{
    if (self.previewImage)
    {
        [library saveImage:_previewImage toAlbum:kCustomAlbumName withCompletionBlock:^(NSError *error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"储存成功" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
