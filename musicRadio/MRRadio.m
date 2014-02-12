//
//  MRRadio.m
//  musicRadio
//
//  Created by Takuya Okamoto on 2014/01/30.
//  Copyright (c) 2014年 Takuya Okamoto. All rights reserved.
//

#import "MRRadio.h"
#import "MRPlaylistManager.h"
#import "MRLastfmRequest.h"
#import "MRExfmRequest.h"
#import "MRYoutubeRequest.h"

@implementation MRRadio {
    MRPlaylistManager *_playlistManager;
    MRLastfmRequest *_lastfmRequest;
    MRExfmRequest *_exfmRequest;
    MRYoutubeRequest *_youTubeRequest;
    BOOL _didPlayFastTrack;
    BOOL _isStopPlayer;
    NSString *_nowPlayingText;
}

@synthesize youtubePlayer;
@synthesize nextYoutubePlayer;
@synthesize delegeteViewController;



- (id) init
{
    NSLog(@"init of MRRadio.");
    self = [super init];
    
    if (self != nil) {
        _playlistManager = [[MRPlaylistManager alloc] init];
        _playlistManager.radio = self;
        _lastfmRequest = [[MRLastfmRequest alloc] init];
        _exfmRequest = [[MRExfmRequest alloc] init];
        _youTubeRequest = [[MRYoutubeRequest alloc] init];
        
        [self enableBackGroundPlayback];
        [self enableAutoPlay];
    }
    return self;
}




//------------------ public methods -----------------------------------

-(NSArray*) searchSongWithArtistName:(NSString*) keyword {
    NSLog(@"searchSongWithArtistName   keyword: %@", keyword);
    NSDictionary *artistSearchResult = [_lastfmRequest searchArtistByLastfmWithArtistName:keyword];
    return artistSearchResult[@"results"][@"artistmatches"][@"artist"];
}



-(int) generatePlaylistByArtistName: (NSString*)artistName {
    NSLog(@"MRRadio : generatePlaylistByArtistName");
    int relustOfGeneretingPlaylist = [_playlistManager generatePlaylistByArtistName:artistName];
    
    NSLog(@"result of generaging playlst :%d", relustOfGeneretingPlaylist);
    
    return 0;
}


//最初に手早くそのアーティストの曲を探して再生する。
//TODO　その時、アーティスト検索して何もでてこなかったらどうする？
//→　実際はないか。 lastFmで検索かけてるはず
- (void) fastArtistRandomPlay: (NSString*)artistName {
    NSString *randomVideoID = [_youTubeRequest getRandomVideoIDByKeyword:artistName];
    _nowPlayingText = artistName;
    [self prepearYouTubePlayerWithVideoID:randomVideoID];
}


-(void) prepareNextTrack {
    NSDictionary *songInfo = [_playlistManager getNextTrack];
    NSString *songKeyword = [NSString stringWithFormat:@"%@ %@", songInfo[@"artist"], songInfo[@"name"]];
    _nowPlayingText = [NSString stringWithFormat:@"%@ / %@", songInfo[@"artist"], songInfo[@"name"]];
    [self prepareYouTubeByKeyword:songKeyword];
}


//----------------------------------- Delegete ------------------------------

//PlaylystManager Delegete
- (void)randomSongCanPlay: (NSDictionary *)songInfo
{
    NSLog(@"randomSongCanPlay------------");
    NSString *songKeyword = [NSString stringWithFormat:@"%@ %@", songInfo[@"artist"], songInfo[@"name"]];
    _nowPlayingText = [NSString stringWithFormat:@"%@ / %@", songInfo[@"artist"], songInfo[@"name"]];
    [self prepareYouTubeByKeyword:songKeyword];
}


//YoutubePlayer Delegete
- (void) onYoutubeLoadingSuccess
{
    NSLog(@"[MRRadio prepearYouTubePlayerWithVideoID]　再生準備完了！！！*********");
    if (!_didPlayFastTrack) {
        [self startPlaybackNextVideo];
    }
    else {
        delegeteViewController.nextButton.enabled = YES;
    }
}

- (void) YouTubeErrorOccred
{
    NSLog(@"YouTubeErrorOccred");
    [self prepareNextTrack];
}



// ------------------- private method ----------------------------------------------



- (void) prepareYouTubeByKeyword: (NSString *)songKeyword {
    NSString *topVideoID = [_youTubeRequest getTopVideoIDByKeyword:songKeyword];

    if (topVideoID) {
        [self prepearYouTubePlayerWithVideoID:topVideoID];
    }
    else {
        [self YouTubeErrorOccred];
    }
}
- (void) prepearYouTubePlayerWithVideoID: (NSString*)videoID {
    self.nextYoutubePlayer = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:videoID];
    self.nextYoutubePlayer.delegete = self;
    self.nextYoutubePlayer.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    self.nextYoutubePlayer.moviePlayer.allowsAirPlay = YES;

    //これで再生可能になったタイミングでonYoutubeLoadingSuccessにて↓のメソッドが呼ばれる。
    //エラーならYouTubeErrorOccredが呼ばれる。
}
- (void) startPlaybackNextVideo {
    NSLog(@"MusicPlayer : startPlaybackNextVideo");
    
    _isStopPlayer = NO;
    if(!_didPlayFastTrack) _didPlayFastTrack = YES;
    
    if (youtubePlayer) {
        [youtubePlayer.moviePlayer stop];
        youtubePlayer = nil;
    }
    youtubePlayer = nextYoutubePlayer;
    NSLog(@"youtubePlayer : %@", youtubePlayer);
    [youtubePlayer presentInView:delegeteViewController.youtubeBox];
    [youtubePlayer.moviePlayer play];
    nextYoutubePlayer = nil;
    
    [delegeteViewController.nowPlayingLabel setText:_nowPlayingText];
    
    //今のを再生したら次のトラックを準備する
    if (_didPlayFastTrack && _playlistManager.isHavingTrack) {
        delegeteViewController.nextButton.enabled = NO;
        [self prepareNextTrack];
    }
}



// --------------------- BackGround Playback ------------------------

- (void) enableBackGroundPlayback {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willTerminate) name:UIApplicationWillTerminateNotification object:nil];
}
- (void) willEnterBackground {
    NSLog(@"willEnterBackground");
    if(youtubePlayer.moviePlayer.playbackState == MPMoviePlaybackStatePlaying)
        [self performSelector:@selector(playplayer) withObject:nil afterDelay:0.001];
}
- (void) playplayer {
    [youtubePlayer.moviePlayer play];
}

//-------------------- Auto play ------------------
- (void) enableAutoPlay {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishPreload) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishPlayback) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}

- (void) finishPreload {
    NSLog(@"--------- finishPreload ---------------");
}

- (void) finishPlayback {
    NSLog(@"----- finishPlayback ------");
    
    NSTimeInterval remainTime = youtubePlayer.moviePlayer.duration - youtubePlayer.moviePlayer.currentPlaybackTime;
    NSLog(@"remainTime : %f", remainTime);
    
    if (remainTime <= 0) {
        NSLog(@"VIDEO IS END!!");
        _isStopPlayer = YES;
        [self startPlaybackNextVideo];
    }
}

//
//
//
//
////--------------  test ---------------------------
//- (int) test_random_play {
//    NSString *playUrlString = [self get_random_play_url];
//    
//    NSLog(@"play url!!");
//    [_musicPlayer playMusicWithURL:playUrlString];
//    
//    return 0;
//}
//
//
//- (NSString*) get_random_play_url {
//    
//    NSDictionary *randomTrack = [_playlistGanerator getRandomTrack];
//    
//    NSString *songSearhKeyword = [NSString stringWithFormat:@"%@ %@",
//                                  randomTrack[@"artist"],randomTrack[@"name"]];
//    
//    _nowPlayingName = [NSString stringWithFormat:@"%@ / %@",
//                          randomTrack[@"name"],randomTrack[@"artist"]];
//    
//    NSLog(@"-----Song Search : %@",songSearhKeyword);
//    
//    NSDictionary *songSearchResult = [_exfmRequest searchSongByExfmWithKeyword:songSearhKeyword];
//    
//    NSLog(@"song search results count :%@",songSearchResult[@"results"]);
//    
//    if ( [[songSearchResult[@"results"] stringValue] isEqualToString:@"0"] ) {
//        NSLog(@" song search result is 0!!!!!!!!!!!!!!!!!!!!!!!!!!! ");
//        return [self get_random_play_url];//再起！！こわ！ｗ
//    }
//    else {
//        NSDictionary *song = songSearchResult[@"songs"][0];
//        [_testView setLabelText:_nowPlayingName];//test
//        return song[@"url"];
//    }
//}
//
//
//-(int) resetPlaylist {
//    [_playlistGanerator resetPlaylist];
//    return 0;
//}
//
//-(NSString*) getNowPlayingTitle {
//    return _nowPlayingName;
//}
//
//
////------------------あとでけす----------------------
//- (void) setTestView :(id)view{
//    _testView = view;
//}
//

@end
