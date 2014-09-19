//
//  BGDGroupPickerViewController.m
//  BigHeadDemo
//
//  Created by zangqilong on 14-9-19.
//  Copyright (c) 2014年 zangqilong. All rights reserved.
//

#import "BGDGroupPickerViewController.h"
#import "BGDGroupThumbCell.h"
#import "BGDThumbPickViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AssetsDataIsInaccessibleViewController.h"

@interface BGDGroupPickerViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) NSMutableArray *groups;
@property (nonatomic, strong) ALAssetsGroup *defaultGroup;
@property (nonatomic, strong) ALAssetsFilter *assetsFilter;
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@end

@implementation BGDGroupPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"start");
    
    [self setupButtons];
    [self setupGroup];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setup

- (void)setupButtons
{
    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(dismiss:)];
}

- (void)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setupGroup
{
    if (self.assetsLibrary == nil) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    if (self.groups == nil) {
        _groups = [[NSMutableArray alloc] init];
    } else {
        [self.groups removeAllObjects];
    }
    
    // setup our failure view controller in case enumerateGroupsWithTypes fails
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        
        AssetsDataIsInaccessibleViewController *assetsDataInaccessibleViewController =
        [self.storyboard instantiateViewControllerWithIdentifier:@"inaccessibleViewController"];
        
        NSString *errorMessage = nil;
        switch ([error code]) {
            case ALAssetsLibraryAccessUserDeniedError:
            case ALAssetsLibraryAccessGloballyDeniedError:
                errorMessage = @"The user has declined access to it.";
                break;
            default:
                errorMessage = @"Reason unknown.";
                break;
        }
        
        assetsDataInaccessibleViewController.explanation = errorMessage;
        [self presentViewController:assetsDataInaccessibleViewController animated:NO completion:nil];
    };
    
    // emumerate through our groups and only add groups that contain photos
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        
        if (group!=nil)
        {
            [self.groups addObject:group];
        }else
        {
             [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    };
    
    // enumerate only photos
    NSUInteger groupTypes = ALAssetsGroupAll;
    [self.assetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];
  
}



#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
   
    return self.groups.count;
    
}


// the image view inside the collection view cell prototype is tagged with "1"

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    BGDGroupThumbCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.clipsToBounds = NO;
    // load the asset for this cell
    ALAssetsGroup *groupForCell = self.groups[indexPath.row];
    CGImageRef posterImageRef = [groupForCell posterImage];
    UIImage *thumbnail = [UIImage imageWithCGImage:posterImageRef];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    imageView.image = thumbnail;
    imageView.transform = CGAffineTransformMakeRotation(10*M_PI/180);
   
    UIImageView *bottomImageView = (UIImageView *)[cell viewWithTag:2];
    bottomImageView.image = thumbnail;
    
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:3];
    nameLabel.text = [groupForCell valueForProperty:ALAssetsGroupPropertyName];
    
    UILabel *countLabel = (UILabel *)[cell viewWithTag:4];
    countLabel.text = [NSString stringWithFormat:@"%ld",[groupForCell numberOfAssets]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showDetail" sender:indexPath];
}


#pragma mark - Segue support

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *selectedIndexPath = (NSIndexPath *)sender;
        if (self.groups.count > (NSUInteger)selectedIndexPath.row) {
    
            BGDThumbPickViewController *albumContentsViewController = [segue destinationViewController];
            albumContentsViewController.assetsGroup = self.groups[selectedIndexPath.row];
        }
    }
}

@end
