//
//  TestplayViewController2.m
//  musicRadio
//
//  Created by Takuya Okamoto on 2014/02/12.
//  Copyright (c) 2014年 Takuya Okamoto. All rights reserved.
//

#import "MusicPlayerViewController.h"
#import "MRRadio.h"


@interface MusicPlayerViewController ()
@end



@implementation MusicPlayerViewController{
    MRRadio *_appRadio;
    UIView *_youTubeBox;
    XCDYouTubeVideoPlayerViewController * _nextTrackPlayer;
    UIButton *_nextButton;
    UILabel *_nowPlayingLabel;
    BOOL _isEnableNextButton;
}
@synthesize youtubeBox = _youTubeBox;
@synthesize nextButton = _nextButton;
@synthesize nowPlayingLabel = _nowPlayingLabel;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //↓なぜかうまくいかない？うごいてない？
//        _appRadio = [[MRRadio alloc] init];
//        _appRadio.delegeteViewController = self;
    }
    return self;
}







- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"view did load");
    _appRadio = [[MRRadio alloc] init];
    _appRadio.delegeteViewController = self;
    
    NSString *artistName = @"ELLEGARDEN";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [_appRadio generatePlaylistByArtistName:artistName];
    });
    
    [self layoutSubView];
    
    [_appRadio fastArtistRandomPlay:artistName];
}








- (void) layoutSubView {
    
    const CGFloat maxW = self.view.frame.size.width;
    const CGFloat maxH = self.view.frame.size.height;
    const CGFloat statusBar_H = 20;
    
    CGFloat player_H = 200;
    CGFloat button_W = 120;
    CGFloat button_H = 60;
    CGFloat nowLabel_H = 20;
    
    _youTubeBox = [[UIView alloc] init];
    _youTubeBox.frame = CGRectMake(0, statusBar_H, maxW, player_H);
    _youTubeBox.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_youTubeBox];
    
    _nextButton = [[UIButton alloc] init];
    _nextButton.enabled = NO;
    _nextButton.frame = CGRectMake(0, 0, button_W, button_H);
    _nextButton.center = CGPointMake(maxW/2, statusBar_H + player_H + nowLabel_H +button_H);
    _nextButton.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:1];
    [_nextButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [_nextButton setTitle:@"PlayNext!" forState:UIControlStateNormal];
    [_nextButton setTitle:@"Loading..." forState:UIControlStateDisabled];
    [_nextButton addTarget:self action:@selector(onTapNextButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_nextButton];
    
    _nowPlayingLabel = [[UILabel alloc] init];
    _nowPlayingLabel.frame = CGRectMake(0, 0, maxW-maxW/6, nowLabel_H);
    _nowPlayingLabel.center = CGPointMake(maxW/2, statusBar_H + player_H + nowLabel_H);
    [_nowPlayingLabel setTextColor:[UIColor blackColor]];
    [_nowPlayingLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:_nowPlayingLabel];
}






-(void) onTapNextButton {
    NSLog(@"########### onTapNextButton ###############");
    _nextButton.enabled = NO;
    [_appRadio startPlaybackNextVideo];
}










- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}











@end
