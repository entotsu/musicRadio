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
    BOOL _isEnableNextButton;
}



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
    CGFloat button_W = 100;
    CGFloat button_H = 60;
    
    _youTubeBox = [[UIView alloc] init];
    _youTubeBox.frame = CGRectMake(0, statusBar_H, maxW, player_H);
    _youTubeBox.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_youTubeBox];
    
    _nextButton = [[UIButton alloc] init];
    _nextButton.enabled = NO;
    _nextButton.frame = CGRectMake(0, 0, button_W, button_H);
    _nextButton.center = CGPointMake(maxW/2, statusBar_H + player_H + button_H);
    _nextButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    [_nextButton setTitle:@"PlayNext!" forState:UIControlStateNormal];
    [_nextButton addTarget:self action:@selector(onTapNextButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_nextButton];
}

-(void) onTapNextButton {
    NSLog(@"########### onTapNextButton ###############");
    _nextButton.enabled = NO;
    [_appRadio playNext];
}










- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





//--------------- Delegete --------------------------


-(void) EnableNextButton
{
    _isEnableNextButton = YES;
}


//成功delgeteがRadioにいったらそこからこっちにdelegete飛ばしてすり替えて再生する。
- (void) CanStartNextTrack
{
    NSLog(@"MusicPlayer : CanStartNextTrack");
    if (_appRadio.youtubePlayer) {
        [_appRadio.youtubePlayer.moviePlayer stop];
        _appRadio.youtubePlayer = nil;
    }
    _appRadio.youtubePlayer = _appRadio.nextYoutubePlayer;
    NSLog(@"youtubePlayer : %@", _appRadio.youtubePlayer);
    [_appRadio.youtubePlayer presentInView:_youTubeBox];
    [_appRadio.youtubePlayer.moviePlayer play];
    _appRadio.nextYoutubePlayer = nil;
    
    //再生された数秒後にタイミングでNextButtonが押せるようになる。
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        sleep(5);
        if (_isEnableNextButton) _nextButton.enabled = YES;
    });
}




@end
