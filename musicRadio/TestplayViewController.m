//
//  TestplayViewController.m
//  musicRadio
//
//  Created by Takuya Okamoto on 2014/01/31.
//  Copyright (c) 2014年 Takuya Okamoto. All rights reserved.
//

#import "TestplayViewController.h"
#import "MRRadio.h"

@interface TestplayViewController ()

@end

@implementation TestplayViewController {
    MRRadio *_appRadio;
    UITextField *_textField;
}

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
    NSLog(@"test view did load.");
    
    [self initView];
    
    
    _appRadio = [[MRRadio alloc] init];
}


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
}


- (void) onTapTestButton {
    
    [_appRadio resetPlaylist];
    
    NSString *keyword = [_textField text];
    NSArray *artistSearchResult = [_appRadio searchSongWithArtistName:keyword];
    NSString *playlistArtistName = artistSearchResult[0][@"name"];
    NSLog(@"playlistArtistName :%@", playlistArtistName);
    [_appRadio generatePlaylistByArtistName:playlistArtistName];

}



- (void) testPlay {
    
    //実際は検索のマド作る
    NSString *searchKeyword = @"ellegarden";
    
    _appRadio = [[MRRadio alloc] init];
    
    NSArray *artistSearchResult = [_appRadio searchSongWithArtistName:searchKeyword];
    
    //実際はここで選ばせる？
    NSString *playlistArtistName = artistSearchResult[0][@"name"];
    NSLog(@"playlistArtistName :%@", playlistArtistName);
    
    [_appRadio generatePlaylistByArtistName:playlistArtistName];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
