//
//  FirstNavigationViewController.m
//  musicRadio
//
//  Created by Takuya Okamoto on 2014/02/26.
//  Copyright (c) 2014年 Takuya Okamoto. All rights reserved.
//

#import "FirstNavigationViewController.h"

@interface FirstNavigationViewController ()
@end




@implementation FirstNavigationViewController

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
	// Do any additional setup after loading the view.
    NSLog(@"FirstNavigationViewController did load");
//    self.navigationBar.barTintColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.41];
    self.navigationBar.alpha = 0.1f;
    self.navigationBar.translucent = YES;
    self.navigationBar.barTintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
