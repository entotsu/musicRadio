//
//  MRFavedPlayer.m
//  musicRadio
//
//  Created by Takuya Okamoto on 2014/05/04.
//  Copyright (c) 2014年 Takuya Okamoto. All rights reserved.
//

#import "MRFavedPlayer.h"
#import <CoreData/CoreData.h>
#import "Faved.h"



@interface MRFavedPlayer () {
    NSManagedObjectContext *_managedObjectContext;
    NSArray *_favedArray;
    XCDYouTubeVideoPlayerViewController *_youtubePlayer;
    int _idx;
}
-(void)playVideoWithFaved:(Faved *)faved;
-(void)getFavedPlaylist;

// Auto Play Next Track
-(void)enableAutoPlay;
-(void)finishPlayback;

// Background Playback
-(void)enableBackGroundPlayback;
-(void)willEnterBackground;
-(void)playplayer;

@end







@implementation MRFavedPlayer

#pragma mark public method

- (id) initWithVideoIdentifier:(NSString *)videoIdentifier
{
    NSLog(@"init of MRFavedPlayer.");
    self = [super init];
    if (self != nil) {
        //CoreDataの準備
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        _managedObjectContext = appDelegate.managedObjectContext;
        
        
        //プレイリストを取得する  _favedArray =
        [self getFavedPlaylist];

        
        //今の曲が何曲目か特定   _idx =
        _idx = 0;
        for (Faved *fav in _favedArray) {
            if ([fav.videoId isEqualToString:videoIdentifier])
                break;
            _idx++;
        }
    }
    return self;
}




// finishPlaybackから呼ぶ。
// idxを++して、次の曲を再生する playVideoWithFaved:
-(void) playNext {
}

// View側でPrevボタンを押した時に動く
// idxを--して、前の曲を再生する playVideoWithFaved:
-(void) playPrev {
    [self playVideoWithFaved:_favedArray[_idx]];
}











#pragma mark Local Method
// youtube player を再生
// MusicViewのラベルとアートワークを更新
-(void) playVideoWithFaved:(Faved *)faved {
    NSLog(@"playVideoWithFaved");
    
    self.delegeteViewController.artistNameLabel.text = [[faved valueForKey:@"artist"] description];
    self.delegeteViewController.trackNameLabel.text = [[faved valueForKey:@"title"] description];
    self.delegeteViewController.artworkView.image = [[UIImage alloc] initWithData:[faved valueForKey:@"artwork"]];
    NSString *videoId = [[faved valueForKey:@"videoId"] description];
    _youtubePlayer = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:videoId];
    _youtubePlayer.delegete = self;
    _youtubePlayer.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    _youtubePlayer.moviePlayer.allowsAirPlay = YES;
    _youtubePlayer.moviePlayer.controlStyle = MPMovieControlStyleNone;
    NSLog(@"self.delegeteViewController.youtubeBox:%@",self.delegeteViewController.youtubeBox);
    [_youtubePlayer presentInView:self.delegeteViewController.youtubeBox];//何度かbackしてるとここで落ちる
    [_youtubePlayer.moviePlayer play];
}







-(void)getFavedPlaylist {
    
    // 検索用のNSFetchRequestを生成する。
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    // 検索対象のエンティティを設定する。(ここではSampleというエンティティ)
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Faved"
                                              inManagedObjectContext:_managedObjectContext];
    [request setEntity:entity];
    
    //    // 検索結果のソートを設定する。(ここではcreationDateを降順に設定)
    //    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO];
    //    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    //    [request setSortDescriptors:sortDescriptors];
    
    // 検索条件を設定する。(ここではtitle="sample"のデータを取得)
    //    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"videoId = %@",videoId];
    //    [request setPredicate:predicate];
    
    // データを検索する。
    NSError *error = nil;
    _favedArray = [_managedObjectContext executeFetchRequest:request error:&error];
}









#pragma mark XCDYouTubeVideoPlayerViewController Delegate
- (void) onYoutubeLoadingSuccess {
    NSLog(@"onYoutubeLoadingSuccess");

}
- (void) YouTubeErrorOccred {
    NSLog(@"YouTubeErrorOccred");
}







#pragma mark Auto Play Next Track
- (void) enableAutoPlay {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishPlayback) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}


- (void) finishPlayback {
    NSLog(@"----- finishPlayback of favedPlayer ------");
    
    NSTimeInterval remainTime = _youtubePlayer.moviePlayer.duration - _youtubePlayer.moviePlayer.currentPlaybackTime;
    NSLog(@"remainTime : %f", remainTime);
    
    if (remainTime <= 0) {
        NSLog(@"VIDEO IS END!!");
        
        //次の動画を再生する関数を呼ぶ
        
        //ポーズボタンを無効化する
        self.delegeteViewController.pauseButton.enabled = NO;
    }
}










#pragma mark Background Playback

- (void) enableBackGroundPlayback {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
}
- (void) willEnterBackground {
    NSLog(@"willEnterBackground");
    if(_youtubePlayer.moviePlayer.playbackState == MPMoviePlaybackStatePlaying)
        [self performSelector:@selector(playplayer) withObject:nil afterDelay:0.001];
}
- (void) playplayer {
    [_youtubePlayer.moviePlayer play];
}


@end
