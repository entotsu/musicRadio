//
//  TestplayViewController2.m
//  musicRadio
//
//  Created by Takuya Okamoto on 2014/02/12.
//  Copyright (c) 2014年 Takuya Okamoto. All rights reserved.
//

#import "MusicPlayerViewController.h"
#import "MRRadio.h"
#import "MRLastfmRequest.h"

@interface MusicPlayerViewController ()
@end



@implementation MusicPlayerViewController{
    MRRadio *_appRadio;
    UIView *_youTubeBox;
    XCDYouTubeVideoPlayerViewController * _nextTrackPlayer;
    UIButton *_nextButton;
    UILabel *_nowPlayingLabel;
    UIScrollView *_artistInfoScrollView;
    UILabel *_bioLabel;
    NSString *_artistName;
    BOOL _isEnableNextButton;
}
@synthesize youtubeBox = _youTubeBox;
@synthesize nextButton = _nextButton;
@synthesize nowPlayingLabel = _nowPlayingLabel;
@synthesize artistName = _artistName;






- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"view did load");
    
    [self layoutSubView];
    
    //debug
    if (!_artistName)
        _artistName = @"ellegarden";
    
    _appRadio = [[MRRadio alloc] init];
    _appRadio.delegeteViewController = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [_appRadio generatePlaylistByArtistName:_artistName];
    });
    
    [_appRadio fastArtistRandomPlay:_artistName];
}








- (void) layoutSubView {
    NSLog(@"musicPlayerView layoutSubview");
    const CGFloat maxW = self.view.frame.size.width;
    const CGFloat maxH = self.view.frame.size.height;
    const CGFloat statusBar_H = 20;
    
    CGFloat player_H = 160;
    CGFloat button_W = 50;
    CGFloat button_H = button_W;
    CGFloat button_Margin = button_W/2;
    CGFloat nowLabel_H = 40;
    CGFloat infoView_H = maxH - statusBar_H - nowLabel_H - player_H - button_H - button_Margin*2;
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blurBG3"]];
    backgroundImage.frame = CGRectMake(0, 0, maxW, maxH);
    [self.view addSubview:backgroundImage];
    
    _nowPlayingLabel = [[UILabel alloc] init];
    _nowPlayingLabel.frame = CGRectMake(0, 0, maxW, nowLabel_H);
    _nowPlayingLabel.center = CGPointMake(maxW/2, statusBar_H + nowLabel_H/2);
    _nowPlayingLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
    [_nowPlayingLabel setTextColor:[[UIColor blackColor] colorWithAlphaComponent:0.8]];
    [_nowPlayingLabel setFont:[UIFont fontWithName:@"Helvetica Neue Bold" size:32.0f]];
    [_nowPlayingLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:_nowPlayingLabel];
    
    _youTubeBox = [[UIView alloc] init];
    _youTubeBox.frame = CGRectMake(0, statusBar_H + nowLabel_H, maxW, player_H);
    _youTubeBox.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_youTubeBox];
    
    _artistInfoScrollView = [[UIScrollView alloc] init];
    _artistInfoScrollView.frame = CGRectMake(0, statusBar_H+nowLabel_H+player_H, maxW, infoView_H);
    _artistInfoScrollView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
    _artistInfoScrollView.contentSize = CGSizeMake(maxW, 500);//あとでどうにかする
    [self.view addSubview:_artistInfoScrollView];
    
    _bioLabel = [[UILabel alloc] init];
    _bioLabel.frame = CGRectMake(0, 0, maxW, 300);
    [_bioLabel setTextColor:[[UIColor blackColor] colorWithAlphaComponent:0.8]];
    [_bioLabel setFont:[UIFont fontWithName:@"Helvetica Neue Ultra Light" size:8.0f]];
    [_bioLabel setTextAlignment:NSTextAlignmentCenter];
    _bioLabel.numberOfLines = 0;
    _bioLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _bioLabel.adjustsFontSizeToFitWidth = YES;
    [_artistInfoScrollView addSubview:_bioLabel];
    
    
    _nextButton = [[UIButton alloc] init];
    _nextButton.enabled = NO;
    _nextButton.frame = CGRectMake(maxW - button_W - button_Margin, maxH - button_H - button_Margin, button_W, button_H);
    [_nextButton setBackgroundImage:[UIImage imageNamed:@"nextButton"] forState:UIControlStateNormal];
    [_nextButton addTarget:self action:@selector(onTapNextButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_nextButton];
    
    UIButton *_heartButton = [[UIButton alloc] init];
    _heartButton.frame = CGRectMake(button_Margin, maxH - button_H - button_Margin, button_W, button_H);
    [_heartButton setBackgroundImage:[UIImage imageNamed:@"heart_80"] forState:UIControlStateNormal];
    [self.view addSubview:_heartButton];
    
}


- (void) getArtistInfoWithName {
    MRLastfmRequest *lastfmReqest = [[MRLastfmRequest alloc] init];
    NSDictionary *artistInfo = [lastfmReqest getArtistInfoWithName:_artistName];
    
    NSString *bioSummary = artistInfo[@"artist"][@"bio"][@"summary"];
    
    [self displayArtistInfoWithName:bioSummary];
}


- (void) displayArtistInfoWithName: (NSString*)bioString {
    
//    bioString = [bioString stringByReplacingOccurrencesOfString:@" " withString:@""];
//    bioString = [bioString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    NSLog(@"bioString: '%@'",bioString);
    
    [_bioLabel setText:bioString];
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




// ----------------- <MRRadioDelegete> -------------------------
- (void) didPlayMusic{
    NSLog(@"didPlayMusic ^^^^^^^^^^^^^^^^^^^^^^^^   artistname:%@", _artistName);
    [self getArtistInfoWithName];
}







@end
