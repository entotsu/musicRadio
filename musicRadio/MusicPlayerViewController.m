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
    UILabel *_lyricLabel;
    NSString *_artistName;
    BOOL _isEnableNextButton;
}
@synthesize youtubeBox = _youTubeBox;
@synthesize nextButton = _nextButton;
@synthesize nowPlayingLabel = _nowPlayingLabel;
@synthesize artistName = _artistName;


static NSString * const LYRIC_NOTFOUND = @"歌詞が見つかりませんでした。";


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
    
    UIImageView *backgroundImage = [[UIImageView alloc] init];//initWithImage:[UIImage imageNamed:@"blurBG4"]];
    backgroundImage.frame = CGRectMake(0, 0, maxW, maxH);
    backgroundImage.backgroundColor = [UIColor colorWithRed:0.465117 green:0.792544 blue:1.0 alpha:1.0];
    [self.view addSubview:backgroundImage];
    
    _nowPlayingLabel = [[UILabel alloc] init];
    _nowPlayingLabel.frame = CGRectMake(0, 0, maxW, nowLabel_H);
    _nowPlayingLabel.center = CGPointMake(maxW/2, statusBar_and_nav_H + nowLabel_H/2);
    _nowPlayingLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
    [_nowPlayingLabel setTextColor:[[UIColor blackColor] colorWithAlphaComponent:0.8]];
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
    bioString = [bioString stringByReplacingOccurrencesOfString:@"                " withString:@""];
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"<a href=(.+)>"
                                              options:0
                                                error:nil];
    bioString = [regexp stringByReplacingMatchesInString:bioString
                                     options:0
                                       range:NSMakeRange(0,bioString.length)
                                withTemplate:@""];
    NSLog(@"%@",bioString);
    [self setText:bioString toLabel:_bioLabel];
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
    CGSize size2 = CGSizeMake(self.view.frame.size.width- margin, 5000);
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
- (void) didPlayMusic{
    NSLog(@"didPlayMusic ^^^^^^^^^^^^^^^^^^^^^^^^   artistname:%@", _artistName);
    
    //音楽再生開始後、アーティスト情報を取得して表示。
    [self getArtistInfoWithName];
}


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





@end
