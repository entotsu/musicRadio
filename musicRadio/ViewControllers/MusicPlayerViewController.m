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
    XCDYouTubeVideoPlayerViewController * _nextTrackPlayer;
    UIButton *_nextButton;
    ShadowStyleLabel *_nowPlayingLabel;
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
    
    //debug
    if (!_seedArtist) _seedArtist = @"ELLEGARDEN";

    
    [self layoutSubView];
    
    if (_appRadio) {     //StartViewありのばあいは　ここが動く
        _appRadio.delegeteViewController = self;
        [self onTapNextButton];
    }
    else {    //startViewなし　いまはここが動く
        dispatch_async(dispatch_get_main_queue(), ^{
            _appRadio = [[MRRadio alloc] init];
            _appRadio.delegeteViewController = self;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                [_appRadio generatePlaylistByArtistName:_seedArtist];
            });
            [_appRadio fastArtistRandomPlay:_seedArtist];
        });
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
    
    
    _youTubeBox = [[UIView alloc] init];
    //    _youTubeBox.frame = CGRectMake(0, statusBar_and_nav_H + nowLabel_H, maxW, player_H);
    _youTubeBox.frame = CGRectMake(0, 0, player_W_full, maxH); //dev -40
    _youTubeBox.center = CGPointMake(maxW/2, maxH/2);
    _youTubeBox.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_youTubeBox];
    
    
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
    backButton.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.2];
    [backButton addTarget:self action:@selector(onTapBackButton) forControlEvents:UIControlEventTouchUpInside];
    [navigationBar addSubview:backButton];
    
    _nowPlayingLabel = [[ShadowStyleLabel alloc] init];
    _nowPlayingLabel.frame = CGRectMake(maxW*0.25, maxH - maxH/4 -nowLabel_H/2, maxW*0.75, nowLabel_H);
    _nowPlayingLabel.backgroundColor = [UIColor clearColor];
    [_nowPlayingLabel setTextColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5]];
    [_nowPlayingLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0f]];
    [_nowPlayingLabel setTextAlignment:NSTextAlignmentCenter];
    _nowPlayingLabel.adjustsFontSizeToFitWidth = YES;
    _nowPlayingLabel.adjustsLetterSpacingToFitWidth = YES;
    _nowPlayingLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:1];
    _nowPlayingLabel.shadowOffset = CGSizeMake(0, 1);
    [self.view addSubview:_nowPlayingLabel];
    
    
    
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
    _nextButton.enabled = NO;
    _nextButton.frame = CGRectMake(maxW - button_W - button_Margin, button_Margin, button_W, button_H);
    [_nextButton setBackgroundImage:[UIImage imageNamed:@"next40"] forState:UIControlStateNormal];
    [_nextButton addTarget:self action:@selector(onTapNextButton) forControlEvents:UIControlEventTouchUpInside];
    [buttonSheetBlurView addSubview:_nextButton];
    
    UIButton *_heartButton = [[UIButton alloc] init];
    _heartButton.frame = CGRectMake(button_Margin, button_Margin, button_W, button_H);
    [_heartButton setBackgroundImage:[UIImage imageNamed:@"heart40"] forState:UIControlStateNormal];
    [buttonSheetBlurView addSubview:_heartButton];
    
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
