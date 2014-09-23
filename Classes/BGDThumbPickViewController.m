//
//  BGDThumbPickViewController.m
//  BigHeadDemo
//
//  Created by zangqilong on 14-9-18.
//  Copyright (c) 2014年 zangqilong. All rights reserved.
//

#import "BGDThumbPickViewController.h"
#import "BGDThumbCell.h"

@interface BGDThumbPickViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
{
    UIImage *selectedImage;
    NSIndexPath *selectedIndex;
}
@end

@implementation BGDThumbPickViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    
    if (!self.assets) {
        _assets = [[NSMutableArray alloc] init];
    } else {
        [self.assets removeAllObjects];
    }
    
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        
        if (result) {
            [self.assets addObject:result];
        }
    };
    
    ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
    [self.assetsGroup setAssetsFilter:onlyPhotosFilter];
    [self.assetsGroup enumerateAssetsUsingBlock:assetsEnumerationBlock];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self.thumbCollectionView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    
    return self.assets.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"photoCell";
    
    BGDThumbCell *cell = (BGDThumbCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // load the asset for this cell
    ALAsset *asset = self.assets[indexPath.row];
    CGImageRef thumbnailImageRef = [asset thumbnail];
    UIImage *thumbnail = [UIImage imageWithCGImage:thumbnailImageRef];
    
    // apply the image to the cell
    cell.assetImageView.image = thumbnail;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *asset = self.assets[indexPath.row];
    
    selectedImage = [UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage];
    
    BGDThumbCell *cell = (BGDThumbCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    if ([indexPath compare:selectedIndex] == NSOrderedSame) {
        cell.maskImageView.image = nil;
        selectedImage = nil;
        selectedIndex = nil;
    }else
    {
        cell.maskImageView.image = [UIImage imageNamed:@"c360_cloud_small_image_selected"];
        selectedIndex = indexPath;
    }
    
    
   
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    selectedImage = nil;
    
    BGDThumbCell *cell = (BGDThumbCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
     cell.maskImageView.image = nil;
}

- (IBAction)btnChoose:(id)sender
{
    if (selectedImage) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kChoosedImage" object:selectedImage];
        [self dismissViewControllerAnimated:YES completion:nil];
    }else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请选择一张图片" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
}

- (void)dealloc
{
    
}

@end
