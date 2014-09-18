//
//  BGDViewController.m
//  BigHeadDemo
//
//  Created by zangqilong on 14-9-18.
//  Copyright (c) 2014年 zangqilong. All rights reserved.
//

#import "BGDViewController.h"


@interface BGDViewController ()
{
  
}
@property (nonatomic, copy) NSArray *assets;
@end

@implementation BGDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
 
	// Do any additional setup after loading the view, typically from a nib.
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
