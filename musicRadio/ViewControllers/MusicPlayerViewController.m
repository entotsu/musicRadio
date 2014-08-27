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
#import "ShadowStyleLabel.h"

@interface MusicPlayerViewController ()
@end



@implementation MusicPlayerViewController{
    MRRadio *_appRadio;
    UIView *_youTubeBox;
    UIView * _nextYoutubeBox;
    UIButton *_nextButton;
//    ShadowStyleLabel *_nowPlayingLabel;
    ShadowStyleLabel *_artistNameLabel;
    ShadowStyleLabel *_trackNameLabel;
    UIScrollView *_artistInfoScrollView;
    UILabel *_bioLabel;
    UILabel *_lyricLabel;
    NSString *_seedArtist;
    BOOL _isEnableNextButton;
    UIButton *_pauseButton;
    UIButton *_playButton;
    UIButton *_favButton;
    UIImageView *_artworkView;
}
@synthesize youtubeBox = _youTubeBox;
@synthesize nextYoutubeBox = _nextYoutubeBox;
@synthesize nextButton = _nextButton;
//@synthesize nowPlayingLabel = _nowPlayingLabel;
@synthesize artistNameLabel = _artistNameLabel;
@synthesize trackNameLabel = _trackNameLabel;
@synthesize artworkView = _artworkView;
@synthesize seedArtist = _seedArtist;
@synthesize appRadio = _appRadio;
@synthesize pauseButton = _pauseButton;

@synthesize playing_favVideoId = _playing_favVideoId;

@synthesize favedPlayer = _favedPlayer;


static NSString * const LYRIC_NOTFOUND = @"歌詞が見つかりませんでした。";


- (void) dealloc {
    NSLog(@"dealloc MusicPlayerViewwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww");
    _appRadio = nil;
    _youTubeBox = nil;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"view did load");
    
    //debug
//    if (!_seedArtist) _seedArtist = @"ellegarden";

    
    [self layoutSubView];
    
    if (!_playing_favVideoId) {
        if (_appRadio) {     //StartViewありのばあいは　ここが動く
            _appRadio.delegeteViewController = self;
            [self onTapNextButton];
        }
        else {    //startViewなし　いまはここが動く
            dispatch_async(dispatch_get_main_queue(), ^{
                _appRadio = [[MRRadio alloc] init];
                _appRadio.delegeteViewController = self;
                [_appRadio fastArtistRandomPlay:_seedArtist];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    sleep(2);
                    [_appRadio generatePlaylistByArtistName:_seedArtist];
                });
            });
        }
    }
    else {
        NSLog(@"fav play");
        _favedPlayer = [[MRFavedPlayer alloc] initWithVideoIdentifier:_playing_favVideoId];
        _favedPlayer.delegeteViewController = self;
        [_favedPlayer playNext];
    }
    
    
    
    
    // ステータスバーの表示/非表示メソッド呼び出し
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7以降
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 7未満
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    
    //ボタン表示してすぐに無効化すると表示されないのでここで無効化しておく。
    _pauseButton.enabled = NO;
    _nextButton.enabled = NO;
}




// ステータスバーの非表示
- (BOOL)prefersStatusBarHidden
{
    return YES;
}





- (void) layoutSubView {
    NSLog(@"musicPlayerView layoutSubview");
    const CGFloat maxW = self.view.frame.size.width;
    const CGFloat maxH = self.view.frame.size.height;
    const CGFloat statusBar_and_nav_H = 20+44;
    
    CGFloat player_H = 160;
    CGFloat player_W_full = maxW*10;
    
    CGFloat button_W = 40;
    CGFloat button_H = button_W;
    CGFloat button_Margin = button_W/2;
    CGFloat nowLabel_H = 30;
    CGFloat infoView_H = maxH - statusBar_and_nav_H - nowLabel_H - player_H - button_H - button_Margin*2;
    CGFloat bioLabel_Margin = 20;
    CGFloat blurRadius = 10;
    CGFloat artworkSize = 50;
    
//    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CRSTL_BG"]];
//    backgroundImage.frame = CGRectMake(0, 0, maxW, maxH);
//    backgroundImage.backgroundColor = [UIColor colorWithRed:0.465117 green:0.792544 blue:1.0 alpha:1.0];
//    [self.view addSubview:backgroundImage];
    
    
    
    _nextYoutubeBox = [[UIView alloc] init];
    //    _youTubeBox.frame = CGRectMake(0, statusBar_and_nav_H + nowLabel_H, maxW, player_H);
    _nextYoutubeBox.frame = CGRectMake(0, 0, player_W_full, maxH); //dev -40
    _nextYoutubeBox.center = CGPointMake(maxW/2, maxH/2);
    _nextYoutubeBox.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_nextYoutubeBox];
    
    _youTubeBox = [[UIView alloc] init];
    //    _youTubeBox.frame = CGRectMake(0, statusBar_and_nav_H + nowLabel_H, maxW, player_H);
    _youTubeBox.frame = CGRectMake(0, 0, player_W_full, maxH); //dev -40
    _youTubeBox.center = CGPointMake(maxW/2, maxH/2);
    _youTubeBox.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_youTubeBox];
    
    //dev
//    _nextYoutubeBox.frame = CGRectMake(0, maxH/2, maxW, maxH/2); //dev -40
//    _youTubeBox.frame = CGRectMake(0, 0, maxW, maxH/2); //dev -40

    
    
    
    UIToolbar *navigationBar = [[UIToolbar alloc] init];
    navigationBar.frame = CGRectMake(0, 0, maxW, statusBar_and_nav_H);
    navigationBar.barStyle = UIBarStyleBlack;
//    navigationBar.barTintColor = [[UIColor clearColor] colorWithAlphaComponent:0.01];
    [self.view addSubview:navigationBar];
    UILabel *navigationBarLabel = [[UILabel alloc] init];
    navigationBarLabel.frame = CGRectMake(0, 0, maxW-100, statusBar_and_nav_H);
    navigationBarLabel.center = CGPointMake(maxW/2, statusBar_and_nav_H/2);
    [navigationBarLabel setTextColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5]];
    [navigationBarLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:18.0f]];
    [navigationBarLabel setTextAlignment:NSTextAlignmentCenter];
    navigationBarLabel.adjustsFontSizeToFitWidth = YES;
    navigationBarLabel.adjustsLetterSpacingToFitWidth = YES;
    NSString *navText = [NSString stringWithFormat:@"%@ MIX",_seedArtist];
    [self setKernedText:navText toUILabel:navigationBarLabel];
    [navigationBar addSubview:navigationBarLabel];
    UIButton *backButton = [[UIButton alloc] init];
    backButton.frame = CGRectMake(0, 0, 40, 40);
    backButton.center = CGPointMake(statusBar_and_nav_H/2, statusBar_and_nav_H/2);
//    backButton.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.2];
    [backButton setImage:[UIImage imageNamed:@"searchIcon_white_40.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(onTapBackButton) forControlEvents:UIControlEventTouchUpInside];
    backButton.alpha = 0.7;
    [navigationBar addSubview:backButton];
    
    
    _artworkView = [[UIImageView alloc] init];
    _artworkView.frame = CGRectMake(0, 0, artworkSize, artworkSize);
    _artworkView.center = CGPointMake(maxH/4 - (button_H+button_Margin*2), maxH - maxH/4);
    _artworkView.image = [UIImage imageNamed:@"music2_400"];
    [self.view addSubview:_artworkView];
    
    
    _artistNameLabel = [[ShadowStyleLabel alloc] init];
    _artistNameLabel.frame = CGRectMake(_artworkView.frame.origin.x+artworkSize+20, _artworkView.frame.origin.y, maxW*0.75, nowLabel_H);
    _artistNameLabel.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0];
    [_artistNameLabel setTextColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5]];
    [_artistNameLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0f]];
    [_artistNameLabel setTextAlignment:NSTextAlignmentLeft];
    _artistNameLabel.adjustsFontSizeToFitWidth = YES;
    _artistNameLabel.adjustsLetterSpacingToFitWidth = YES;
    _artistNameLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:1];
    _artistNameLabel.shadowOffset = CGSizeMake(0, 1);
    [self setKernedText:@"" toUILabel:_artistNameLabel];
    [self.view addSubview:_artistNameLabel];
    
    
    
    _trackNameLabel = [[ShadowStyleLabel alloc] init];
    _trackNameLabel.frame = CGRectMake(_artworkView.frame.origin.x+artworkSize+20, _artworkView.center.y, maxW*0.75, nowLabel_H);
    _trackNameLabel.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0];
    [_trackNameLabel setTextColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5]];
    [_trackNameLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0f]];
    [_trackNameLabel setTextAlignment:NSTextAlignmentLeft];
    _trackNameLabel.adjustsFontSizeToFitWidth = YES;
    _trackNameLabel.adjustsLetterSpacingToFitWidth = YES;
    _trackNameLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:1];
    _trackNameLabel.shadowOffset = CGSizeMake(0, 1);
    [self setKernedText:@"" toUILabel:_trackNameLabel];
    [self.view addSubview:_trackNameLabel];
    

//    
//    _nowPlayingLabel = [[ShadowStyleLabel alloc] init];
//    _nowPlayingLabel.frame = CGRectMake(_artworkView.frame.origin.x+artworkSize+20, _artworkView.center.y -nowLabel_H/2, maxW*0.75, nowLabel_H);
//    _nowPlayingLabel.backgroundColor = [UIColor clearColor];
//    [_nowPlayingLabel setTextColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5]];
//    [_nowPlayingLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0f]];
//    [_nowPlayingLabel setTextAlignment:NSTextAlignmentLeft];
//    _nowPlayingLabel.adjustsFontSizeToFitWidth = YES;
//    _nowPlayingLabel.adjustsLetterSpacingToFitWidth = YES;
//    _nowPlayingLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:1];
//    _nowPlayingLabel.shadowOffset = CGSizeMake(0, 1);
//    _nowPlayingLabel.alpha = 0.1;
//    [self.view addSubview:_nowPlayingLabel];

    
    
    FXBlurView *scrollBlurBG = [[FXBlurView alloc] init];
    scrollBlurBG.frame = CGRectMake(0, statusBar_and_nav_H+nowLabel_H+player_H, maxW, infoView_H);;
    scrollBlurBG.blurRadius = blurRadius;
    scrollBlurBG.dynamic = YES;
//    [self.view addSubview:scrollBlurBG];
    _artistInfoScrollView = [[UIScrollView alloc] init];
    _artistInfoScrollView.frame = CGRectMake(0,0, maxW, infoView_H);
    _artistInfoScrollView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
    _artistInfoScrollView.contentSize = CGSizeMake(maxW, 500);//あとでどうにかする
//    [scrollBlurBG addSubview:_artistInfoScrollView];
    
    
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
    
    
//    FXBlurView *buttonSheetBlurView = [[FXBlurView alloc] init];
    UIToolbar *buttonSheetBlurView = [[UIToolbar alloc] init];
    buttonSheetBlurView.frame = CGRectMake(0, maxH - button_H - button_Margin*2, maxW, button_H+button_Margin*2);
//    buttonSheetBlurView.center = CGPointMake(_youTubeBox.frame.size.width/2, maxH - (buttonSheetBlurView.frame.size.height)/2);
//    buttonSheetBlurView.blurRadius = 20;//blurRadius;
//    buttonSheetBlurView.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
//    buttonSheetBlurView.underlyingView = _youTubeBox;
    buttonSheetBlurView.barStyle = UIBarStyleBlack;
//    buttonSheetBlurView.barTintColor = [[UIColor clearColor] colorWithAlphaComponent:0.1];
    [self.view addSubview:buttonSheetBlurView];
//    [_youTubeBox addSubview:buttonSheetBlurView];
//    [_youTubeBox insertSubview:buttonSheetBlurView atIndex:9999];

    _nextButton = [[UIButton alloc] init];
//    _nextButton.enabled = NO;//ここで無効化するとボタンがでない
    _nextButton.frame = CGRectMake(maxW - button_W - button_Margin, button_Margin, button_W, button_H);
    [_nextButton setBackgroundImage:[UIImage imageNamed:@"next"] forState:UIControlStateNormal];
    [_nextButton addTarget:self action:@selector(onTapNextButton) forControlEvents:UIControlEventTouchUpInside];
    [buttonSheetBlurView addSubview:_nextButton];
    
    _favButton = [[UIButton alloc] init];
    _favButton.frame = CGRectMake(button_Margin, button_Margin, button_W, button_H);
    [_favButton setBackgroundImage:[UIImage imageNamed:@"heart"] forState:UIControlStateNormal];
    [_favButton addTarget:self action:@selector(onTapFavButton) forControlEvents:UIControlEventTouchUpInside];
    [buttonSheetBlurView addSubview:_favButton];
    
    _pauseButton = [[UIButton alloc] init];
//    _pauseButton.enabled = NO;//ここで無効化するとボタンがでない
    _pauseButton.frame = CGRectMake(0, 0, button_W, button_H);
    _pauseButton.center = CGPointMake(buttonSheetBlurView.frame.size.width/2, buttonSheetBlurView.frame.size.height/2);
    [_pauseButton setBackgroundImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    [_pauseButton addTarget:self action:@selector(onTapPauseButton) forControlEvents:UIControlEventTouchUpInside];
    [buttonSheetBlurView addSubview:_pauseButton];
    
    _playButton = [[UIButton alloc] init];
    _playButton.hidden = YES;
    _playButton.frame = CGRectMake(0, 0, button_W, button_H);
    _playButton.center = CGPointMake(buttonSheetBlurView.frame.size.width/2, buttonSheetBlurView.frame.size.height/2);
    [_playButton setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [_playButton addTarget:self action:@selector(onTapPlayButton) forControlEvents:UIControlEventTouchUpInside];
    [buttonSheetBlurView addSubview:_playButton];
}


//カーニングしたテキストをラベルに設定する
- (void) setKernedText:(NSString*)text toUILabel:(UILabel*)label{
    NSLog(@"text :%@",text);
    CGFloat customLetterSpacing = 6.0f;
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedText addAttribute:NSKernAttributeName
                           value:[NSNumber numberWithFloat:customLetterSpacing]
                           range:NSMakeRange(0, attributedText.length)];
    [label setAttributedText:attributedText];
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









- (void) onTapBackButton {
    NSLog(@"on tap back button");
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void) onTapPlayButton {
    NSLog(@"on tap play button");
    _playButton.hidden = YES;
    _pauseButton.hidden = NO;
    [_appRadio.youtubePlayer.moviePlayer play];
}

- (void) onTapPauseButton {
    NSLog(@"on tap pause button");
    _pauseButton.hidden = YES;
    _playButton.hidden = NO;
    [_appRadio.youtubePlayer.moviePlayer pause];
}

-(void) onTapNextButton {
    NSLog(@"########### onTapNextButton ###############");
    _nextButton.enabled = NO;
    _pauseButton.enabled = NO;
    [_appRadio startPlaybackNextVideo];
}

- (void) onTapFavButton {
    [_appRadio addFaved];
    _favButton.enabled = NO;
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


-(void) onPlayTrack {
    NSLog(@"on Play Track");
    _favButton.enabled = !([_appRadio checkAlreadyExsistingFavedWithVideoId:_appRadio.youtubePlayer.videoIdentifier]);
}




@end
