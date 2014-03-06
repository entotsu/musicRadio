//
//  StartingRadioViewController.m
//  musicRadio
//
//  Created by Takuya Okamoto on 2014/02/26.
//  Copyright (c) 2014年 Takuya Okamoto. All rights reserved.
//

#import "StartingRadioViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "FXBlurView.h"
#import "MRLastfmRequest.h"
#import "MRRadio.h"
#import "XCDYouTubeVideoPlayerViewController.h"
#import "MusicPlayerViewController.h"

@interface StartingRadioViewController ()
@end





@implementation StartingRadioViewController {
    MRRadio *_appRadio;
    UIImageView *_diskImageView;
    UILabel *_titleLabel;
    XCDYouTubeVideoPlayerViewController *_youtubePlayer;
    UIButton *_startButton;
    NSString *_artistName;
}




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (id) initWithArtistName:(NSString*)artistName {
    self = [super init];
    if (self) {
        _artistName = artistName;
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"StartingRadioViewController did load");

    [self layoutSubView];
    
    //debug
    if (!_artistName) _artistName = @"androp";
    
    [self setArtistWithName:_artistName];
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        _appRadio = [[MRRadio alloc] init];
        _appRadio.delegeteStartViewController = self;
        [_appRadio fastArtistRandomPlay:_artistName];
    
//    });
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark MRRadioStartViewDelegate
//ディスクのアーティストのトラックが再生されたとき
- (void) didSuccessPlayArtistFirstTrack {
    NSLog(@"didSuccessPlayArtistFirstTrack");
    [self startTurningDisk];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [_appRadio generatePlaylistByArtistName:_artistName];
    });
//    [_appRadio generatePlaylistByArtistName:_artistName];
}


//プレイリストの最初のトラックの再生準備が完了した時。
- (void) canStartFirstTrack {
    NSLog(@"canStartFirstTrack");
    _startButton.enabled = YES;
    _startButton.titleLabel.textColor = [UIColor blackColor];
}




# pragma mark public method






#pragma mark private method
// TODO: スワイプできるようにする

- (void) layoutSubView {
    const CGFloat maxW = self.view.frame.size.width;
    const CGFloat maxH = self.view.frame.size.height;
    const CGFloat statusBar_and_nav_H = 20 + 44;
    
    CGFloat discCenterY = maxH/2.75;
    CGFloat discSize = maxW/1.6;
    CGFloat centerSize = discSize/5;
    CGFloat buttonWidth = maxW/1.6;
    CGFloat buttonHeight = buttonWidth/3;//ここの黄金比とかあるかな？
    CGFloat titleWidth = maxW/1.3;
    CGFloat titleHeight = 40;
    
    //背景
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CRSTL_BG"]];
    backgroundImage.frame = CGRectMake(0, 0, maxW, maxH);
    backgroundImage.backgroundColor = [UIColor colorWithRed:0.465117 green:0.792544 blue:1.0 alpha:1.0];
    [self.view addSubview:backgroundImage];
    FXBlurView *blurBG = [[FXBlurView alloc] initWithFrame:backgroundImage.frame];
    [self.view addSubview:blurBG];
    //ディスク
    _diskImageView = [[UIImageView alloc] init];
    _diskImageView.image = [UIImage imageNamed:@"music2_400"]; //defaultImage
    _diskImageView.frame = CGRectMake(0, 0, discSize, discSize);
    _diskImageView.center = CGPointMake(maxW/2, discCenterY);
    _diskImageView.clipsToBounds = YES;
    _diskImageView.layer.cornerRadius = discSize/2;
    [_diskImageView.layer setBorderWidth:5];
    [_diskImageView.layer setBorderColor:[[[UIColor whiteColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.view addSubview:_diskImageView];
    //ディスクの真ん中の部分
    UIView *centerOfDisc = [[UIView alloc] init];
    centerOfDisc.frame = CGRectMake(0, 0, centerSize, centerSize);
    centerOfDisc.center = CGPointMake(discSize/2, discSize/2);
    centerOfDisc.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    centerOfDisc.clipsToBounds = YES;
    centerOfDisc.layer.cornerRadius = centerSize/2;
    [_diskImageView addSubview:centerOfDisc];
    
    
    FXBlurView *startButtonBlurBG = [[FXBlurView alloc] init];
    startButtonBlurBG.frame = CGRectMake(0, 0, buttonWidth, buttonHeight);
    startButtonBlurBG.center = CGPointMake(maxW/2, maxH-buttonHeight*1.5);
    startButtonBlurBG.clipsToBounds = YES;
    startButtonBlurBG.layer.cornerRadius = buttonHeight/6;
    [self.view addSubview:startButtonBlurBG];
    _startButton = [[UIButton alloc] initWithFrame:startButtonBlurBG.frame];
    CGFloat customLetterSpacing = 6.0f;
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:@"start"];
    [attributedText addAttribute:NSKernAttributeName
                           value:[NSNumber numberWithFloat:customLetterSpacing]
                           range:NSMakeRange(0, attributedText.length)];
    [_startButton setAttributedTitle:attributedText forState:UIControlStateNormal];
    NSMutableAttributedString *loadingAttrText = [[NSMutableAttributedString alloc] initWithString:@"loading..."];
    [loadingAttrText addAttribute:NSKernAttributeName
                           value:[NSNumber numberWithFloat:customLetterSpacing]
                           range:NSMakeRange(0, loadingAttrText.length)];
    [_startButton setAttributedTitle:loadingAttrText forState:UIControlStateDisabled];
    [_startButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:26.0]];
    _startButton.titleLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [_startButton addTarget:self action:@selector(onTapStartButton) forControlEvents:UIControlEventTouchUpInside];
    _startButton.enabled = NO;
    [self.view addSubview:_startButton];
    
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.frame = CGRectMake(0, 0, titleWidth, titleHeight);
    _titleLabel.center = CGPointMake(maxW/2, (_diskImageView.center.y+discSize/2 + _startButton.frame.origin.y)/2);
    _titleLabel.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0];
    _titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.0];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:_titleLabel];
}



- (void) setTextToTitleLabel:(NSString*)text {
    CGFloat customLetterSpacing = 6.0f;
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedText addAttribute:NSKernAttributeName
                           value:[NSNumber numberWithFloat:customLetterSpacing]
                           range:NSMakeRange(0, attributedText.length)];
    [_titleLabel setAttributedText:attributedText];
}



- (void) setArtistWithName:(NSString*)name {
    [self setTextToTitleLabel:[NSString stringWithFormat:@"%@ MIX",name]];
    
    //画像を取得してふわっと表示。
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        UIImage *artistImage = [self getArtistImageWithName:name];
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView transitionWithView:_diskImageView
                              duration:1.0f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                _diskImageView.image = artistImage;
                            } completion:nil];
        });
    });
}



- (void) startTurningDisk {
    // y軸に対して回転．（z軸を指定するとUIViewのアニメーションのように回転）
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    // アニメーションのオプションを設定
    animation.duration = 2.5;//2.5; // アニメーション速度
    animation.repeatCount = MAXFLOAT; // 繰り返し回数
    
    // 回転角度を設定
//    animation.fromValue = [NSNumber numberWithFloat:0.0]; // 開始時の角度
    animation.toValue = [NSNumber numberWithFloat:2 * M_PI]; // 終了時の角度
    animation.cumulative = YES;
    
    // アニメーションを追加
    [_diskImageView.layer addAnimation:animation forKey:@"rotate-layer"];
}



- (UIImage*) getArtistImageWithName:(NSString*)artistName {
    MRLastfmRequest *lastfmReq = [[MRLastfmRequest alloc] init];
    NSDictionary *artistInfo = [lastfmReq getArtistInfoWithName:artistName];
    NSString *artistImageURL = artistInfo[@"artist"][@"image"][3][@"#text"];
    
    //画像URLからUIImageを生成
    if ([artistImageURL isEqualToString:@""]) {
        NSLog(@"image is nothing!");
        return nil;
    }else {
        NSLog(@"image URL : %@",artistImageURL);
        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:artistImageURL]];
        UIImage *artistImage = [UIImage imageWithData:imgData];
        return artistImage;
    }
}


# pragma mark events
- (void) onTapStartButton {
    NSLog(@"on tap start button");
    _startButton.enabled = NO;
    MusicPlayerViewController *musicView = [[MusicPlayerViewController alloc] init];
    [musicView setSeedArtist:_artistName];
    [musicView setAppRadio:_appRadio];
    [self.navigationController pushViewController:musicView animated:YES];
}




@end
