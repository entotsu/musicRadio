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
#import "FXBlurView.h"
#import <QuartzCore/QuartzCore.h>


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
    UILabel *_lyricLabel;
    NSString *_seedArtist;
    BOOL _isEnableNextButton;
}
@synthesize youtubeBox = _youTubeBox;
@synthesize nextButton = _nextButton;
@synthesize nowPlayingLabel = _nowPlayingLabel;
@synthesize seedArtist = _seedArtist;
@synthesize appRadio = _appRadio;


static NSString * const LYRIC_NOTFOUND = @"歌詞が見つかりませんでした。";


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"view did load");
    
    [self layoutSubView];
    
    //debug
    if (!_seedArtist) _seedArtist = @"ellegarden";

    //本来はここが動く
    if (_appRadio) {
        _appRadio.delegeteViewController = self;
        [self onTapNextButton];
    }
    //debug
    else {
        _appRadio = [[MRRadio alloc] init];
        _appRadio.delegeteViewController = self;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [_appRadio generatePlaylistByArtistName:_seedArtist];
        });
        
        [_appRadio fastArtistRandomPlay:_seedArtist];
    }
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
    CGFloat blurRadius = 10;
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CRSTL_BG"]];
    backgroundImage.frame = CGRectMake(0, 0, maxW, maxH);
    backgroundImage.backgroundColor = [UIColor colorWithRed:0.465117 green:0.792544 blue:1.0 alpha:1.0];
    [self.view addSubview:backgroundImage];
    
    CGRect nowPlayingViewFrame = CGRectMake(0, 0, maxW, nowLabel_H);
    FXBlurView *nowPlayingBlurView = [[FXBlurView alloc] init];
    nowPlayingBlurView.frame = nowPlayingViewFrame;
    nowPlayingBlurView.center = CGPointMake(maxW/2, statusBar_and_nav_H + nowLabel_H/2);
    nowPlayingBlurView.blurRadius = blurRadius;
    [self.view addSubview:nowPlayingBlurView];
    _nowPlayingLabel = [[UILabel alloc] init];
    _nowPlayingLabel.frame = nowPlayingViewFrame;
    _nowPlayingLabel.backgroundColor = [UIColor clearColor];
    [_nowPlayingLabel setTextColor:[UIColor blackColor]];
    [_nowPlayingLabel setFont:[UIFont fontWithName:@"Helvetica Neue Bold" size:32.0f]];
    [_nowPlayingLabel setTextAlignment:NSTextAlignmentCenter];
    [nowPlayingBlurView addSubview:_nowPlayingLabel];
    
    _youTubeBox = [[UIView alloc] init];
    _youTubeBox.frame = CGRectMake(0, statusBar_and_nav_H + nowLabel_H, maxW, player_H);
    _youTubeBox.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_youTubeBox];
    
    
    FXBlurView *scrollBlurBG = [[FXBlurView alloc] init];
    scrollBlurBG.frame = CGRectMake(0, statusBar_and_nav_H+nowLabel_H+player_H, maxW, infoView_H);;
    scrollBlurBG.blurRadius = blurRadius;
    [self.view addSubview:scrollBlurBG];
    _artistInfoScrollView = [[UIScrollView alloc] init];
    _artistInfoScrollView.frame = CGRectMake(0,0, maxW, infoView_H);
    _artistInfoScrollView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
    _artistInfoScrollView.contentSize = CGSizeMake(maxW, 500);//あとでどうにかする
    [scrollBlurBG addSubview:_artistInfoScrollView];
    
    
    _lyricLabel = [[UILabel alloc] init];
    _lyricLabel.frame = CGRectMake(bioLabel_Margin, 0, maxW-bioLabel_Margin, 5000);
    [_lyricLabel setTextColor:[[UIColor blackColor] colorWithAlphaComponent:0.8]];
    [_lyricLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f]];
    [_lyricLabel setTextAlignment:NSTextAlignmentNatural];
    _lyricLabel.numberOfLines = 0;
    _lyricLabel.lineBreakMode = NSLineBreakByCharWrapping;
    _lyricLabel.adjustsFontSizeToFitWidth = YES;
    [_artistInfoScrollView addSubview:_lyricLabel];
    _lyricLabel.hidden = YES; //最初はプロフ
    //タッチイベントの追加
    _lyricLabel.userInteractionEnabled = YES;
    [_lyricLabel addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapLyricLabel)]];
    
    _bioLabel = [[UILabel alloc] init];
    _bioLabel.frame = CGRectMake(bioLabel_Margin, 0, maxW-bioLabel_Margin, 5000);
    [_bioLabel setTextColor:[[UIColor blackColor] colorWithAlphaComponent:0.8]];
    [_bioLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f]];
    [_bioLabel setTextAlignment:NSTextAlignmentNatural];
    _bioLabel.numberOfLines = 0;
    _bioLabel.lineBreakMode = NSLineBreakByCharWrapping;
    _bioLabel.adjustsFontSizeToFitWidth = YES;
    [_artistInfoScrollView addSubview:_bioLabel];
    //タッチイベントの追加
    _bioLabel.userInteractionEnabled = YES;
    [_bioLabel addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapBioLabel)]];
    
    
    FXBlurView *buttonSheetBlurView = [[FXBlurView alloc] init];
    buttonSheetBlurView.frame = CGRectMake(0, maxH - button_H - button_Margin*2, maxW, button_H+button_Margin*2);
    buttonSheetBlurView.blurRadius = blurRadius;
    buttonSheetBlurView.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:buttonSheetBlurView];
    _nextButton = [[UIButton alloc] init];
    _nextButton.enabled = NO;
    _nextButton.frame = CGRectMake(maxW - button_W - button_Margin, button_Margin, button_W, button_H);
    [_nextButton setBackgroundImage:[UIImage imageNamed:@"nextButton"] forState:UIControlStateNormal];
    [_nextButton addTarget:self action:@selector(onTapNextButton) forControlEvents:UIControlEventTouchUpInside];
    [buttonSheetBlurView addSubview:_nextButton];
    
    UIButton *_heartButton = [[UIButton alloc] init];
    _heartButton.frame = CGRectMake(button_Margin, button_Margin, button_W, button_H);
    [_heartButton setBackgroundImage:[UIImage imageNamed:@"heart_80"] forState:UIControlStateNormal];
    [buttonSheetBlurView addSubview:_heartButton];
    
}






- (void) setText:(NSString*)text toLabel:(UILabel*)label {
    
    [label setText:@""];
    
    //行間を調整したいけど行間じゃなくて文字間になってるなう。
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedText addAttribute:NSKernAttributeName value:[NSNumber numberWithFloat:1.2f] range:NSMakeRange(0, attributedText.length)];
    [label setAttributedText:attributedText];
    
    [self adjustSizeOfLabel:label withText:text];

}

- (void) adjustSizeOfLabel:(UILabel*)label withText:(NSString*)text {
    const CGFloat margin = 40;
    //ラベルとスクロールViewの大きさ調節
    CGSize size2 = CGSizeMake(self.view.frame.size.width-margin, 5000);
    CGSize size = [label.text sizeWithFont:label.font constrainedToSize:size2 lineBreakMode:label.lineBreakMode];
    label.frame = CGRectMake(margin, margin/2, size.width-margin, size.height);
    _artistInfoScrollView.contentSize = CGSizeMake(size.width, size.height + margin*2);

}












-(void) onTapNextButton {
    NSLog(@"########### onTapNextButton ###############");
    _nextButton.enabled = NO;
    [_appRadio startPlaybackNextVideo];
}

- (void) onTapLyricLabel {
    [self showBio];
}

- (void) onTapBioLabel {
    [self showLyric];
}



- (void) showBio {
    if (_bioLabel.hidden) {
        _lyricLabel.hidden = YES;
        _bioLabel.hidden = NO;
        [self adjustSizeOfLabel:_bioLabel withText:_bioLabel.text];
    }
}

- (void) showLyric {
    if (_lyricLabel.hidden) {
        if (_lyricLabel.text){
            _bioLabel.hidden = YES;
            _lyricLabel.hidden = NO;
            [self adjustSizeOfLabel:_lyricLabel withText:_lyricLabel.text];
        } else {
            [self showBio];
        }
    }
}






- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




// ----------------- <MRRadioDelegete> -------------------------

- (void) displayLyric:(NSString*)lyric {
    if (!lyric) {
        lyric = LYRIC_NOTFOUND;
        [self showBio];
    }
    [self setText:lyric toLabel:_lyricLabel];
    if (!([lyric isEqualToString:LYRIC_NOTFOUND])) {
        [self showLyric];
    }
}

- (void) displayBio:(NSString*)bio {
    if (!bio) bio = @"アーティスト情報が見つかりませんでした。";
    [self setText:bio toLabel:_bioLabel];
}






@end
