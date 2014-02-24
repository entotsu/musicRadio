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
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [_appRadio generatePlaylistByArtistName:_artistName];
    });
    
    [_appRadio fastArtistRandomPlay:_artistName];
}








- (void) layoutSubView {
    NSLog(@"musicPlayerView layoutSubview");
    const CGFloat maxW = self.view.frame.size.width;
    const CGFloat maxH = self.view.frame.size.height;
    const CGFloat statusBar_and_nav_H = 20+44;
    
    CGFloat player_H = 160;
    CGFloat button_W = 50;
    CGFloat button_H = button_W;
    CGFloat button_Margin = button_W/2;
    CGFloat nowLabel_H = 40;
    CGFloat infoView_H = maxH - statusBar_and_nav_H - nowLabel_H - player_H - button_H - button_Margin*2;
    CGFloat bioLabel_Margin = 20;
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blurBG4"]];
    backgroundImage.frame = CGRectMake(0, 0, maxW, maxH);
    [self.view addSubview:backgroundImage];
    
    _nowPlayingLabel = [[UILabel alloc] init];
    _nowPlayingLabel.frame = CGRectMake(0, 0, maxW, nowLabel_H);
    _nowPlayingLabel.center = CGPointMake(maxW/2, statusBar_and_nav_H + nowLabel_H/2);
    _nowPlayingLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [_nowPlayingLabel setTextColor:[[UIColor whiteColor] colorWithAlphaComponent:0.8]];
    [_nowPlayingLabel setFont:[UIFont fontWithName:@"Helvetica Neue Bold" size:32.0f]];
    [_nowPlayingLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:_nowPlayingLabel];
    
    _youTubeBox = [[UIView alloc] init];
    _youTubeBox.frame = CGRectMake(0, statusBar_and_nav_H + nowLabel_H, maxW, player_H);
    _youTubeBox.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_youTubeBox];
    
    _artistInfoScrollView = [[UIScrollView alloc] init];
    _artistInfoScrollView.frame = CGRectMake(0, statusBar_and_nav_H+nowLabel_H+player_H, maxW, infoView_H);
    _artistInfoScrollView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
    _artistInfoScrollView.contentSize = CGSizeMake(maxW, 500);//あとでどうにかする
    [self.view addSubview:_artistInfoScrollView];
    
    _bioLabel = [[UILabel alloc] init];
    _bioLabel.frame = CGRectMake(bioLabel_Margin, 0, maxW-bioLabel_Margin, 5000);
    [_bioLabel setTextColor:[[UIColor blackColor] colorWithAlphaComponent:0.8]];
    [_bioLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f]];
    [_bioLabel setTextAlignment:NSTextAlignmentNatural];
    _bioLabel.numberOfLines = 0;
    _bioLabel.lineBreakMode = NSLineBreakByCharWrapping;
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
    CGFloat bioLabel_Margin = 20;
    bioString = [bioString stringByReplacingOccurrencesOfString:@"                " withString:@""];
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"<a href=(.+)>"
                                              options:0
                                                error:nil];
    bioString = [regexp stringByReplacingMatchesInString:bioString
                                     options:0
                                       range:NSMakeRange(0,bioString.length)
                                withTemplate:@""];

    NSLog(@"%@",bioString);
    
//    float lineHeight = 1.5f;
//    NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
//    paragrahStyle.minimumLineHeight = lineHeight;
//    paragrahStyle.maximumLineHeight = lineHeight;
//    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:bioString];
//    [attributedText addAttribute:NSParagraphStyleAttributeName
//                           value:paragrahStyle
//                           range:NSMakeRange(0, attributedText.length)];
//    
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:bioString];
    [attributedText addAttribute:NSKernAttributeName value:[NSNumber numberWithFloat:1.2f] range:NSMakeRange(0, attributedText.length)];
    [_bioLabel setAttributedText:attributedText];
    
//    [_bioLabel setText:bioString];
    
    CGSize size = [_bioLabel.text sizeWithFont:_bioLabel.font constrainedToSize:CGSizeMake(self.view.frame.size.width- bioLabel_Margin, 5000) lineBreakMode:_bioLabel.lineBreakMode];
    
    _bioLabel.frame = CGRectMake(bioLabel_Margin,0, size.width-bioLabel_Margin, size.height);
    _artistInfoScrollView.contentSize = size;
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
    
    [_bioLabel setText:@""];
    
    //音楽再生開始後、アーティスト情報を取得して表示。
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self getArtistInfoWithName];
//    });

}







@end
