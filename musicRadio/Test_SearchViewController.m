//
//  Test_SearchViewController.m
//  musicRadio
//
//  Created by Takuya Okamoto on 2014/02/13.
//  Copyright (c) 2014年 Takuya Okamoto. All rights reserved.
//

#import "Test_SearchViewController.h"
#import "MusicPlayerViewController.h"

@interface Test_SearchViewController ()
@end





@implementation Test_SearchViewController {
    UITextField *_textField;
    UILabel *_infoLabel;
    NSString *_searchedArtist;
}



//------------LifeCycle-------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


//------------Event----------------



- (void) onTapTestButton {
    NSString *artistName = [_textField text];
 
    MusicPlayerViewController *musicView = [[MusicPlayerViewController alloc] init];
    musicView.artistName = artistName;
    
    [self presentViewController:musicView animated:YES completion:nil];
    
    
}


//----------privateMethod-----------

- (void) initView {
    
    int maxW = self.view.frame.size.width;
    int maxH = self.view.frame.size.height;
    
    _textField = [[UITextField alloc] init];
    _textField.frame = CGRectMake(0, 0, maxW-maxW/5, 50);
    _textField.center = CGPointMake(maxW/2, maxH/3);
    _textField.borderStyle = UITextBorderStyleNone;
    _textField.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.2];
    [self.view addSubview:_textField];
    
    UIButton *button = [[UIButton alloc] init];
    button.frame = CGRectMake(0, 0, maxW/2, 50);
    button.center = CGPointMake(maxW/2, maxH/3 + 50 + 30);
    button.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    [button setTitle:@"Play Radio!" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onTapTestButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    _infoLabel = [[UILabel alloc] init];
    _infoLabel.frame = CGRectMake(0, 0, maxW-maxW/4, 50);
    _infoLabel.center = CGPointMake(maxW/2, maxH/3 - 80);
    [_infoLabel setText:@"Type artist name."];
    [self.view addSubview:_infoLabel];
    
}

@end
