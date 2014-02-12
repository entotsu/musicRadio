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
    [self prepearYouTubePlayerWithVideoID:randomVideoID];
}


-(void) playNext {
    NSDictionary *songInfo = [_playlistManager getNextTrack];
    NSString *songKeyword = [NSString stringWithFormat:@"%@ %@", songInfo[@"artist"], songInfo[@"name"]];
    [self playYouTubeByKeyword:songKeyword];
}


//----------------------------------- Delegete ------------------------------

//PlaylystManager Delegete
- (void)randomSongCanPlay: (NSString *)songKeyword
{
    NSLog(@"randomSongCanPlay------------ 【%@】",songKeyword);
    [self playYouTubeByKeyword:songKeyword];
}


//YoutubePlayer Delegete
- (void) YouTubeErrorOccred
{
    NSLog(@"YouTubeErrorOccred");
    [self playNext];
}



- (void) onYoutubeLoadingSuccess
{
    [self.delegeteViewController CanStartNextTrack];
}



// ------------------- private method ----------------------------------------------



- (void) playYouTubeByKeyword: (NSString *)songKeyword {
    NSString *topVideoID = [_youTubeRequest getTopVideoIDByKeyword:songKeyword];

    if (topVideoID) {
        [self prepearYouTubePlayerWithVideoID:topVideoID];
        //ここ、つまりランダム再生が始まってからボタンが使えるようになる
        //実際にenableになるのは、再生開始時。
        [self.delegeteViewController EnableNextButton];
    }
    else {
        [self YouTubeErrorOccred];
    }
}



- (void) prepearYouTubePlayerWithVideoID: (NSString*)videoID {
    NSLog(@"[MRRadio prepearYouTubePlayerWithVideoID]");
    self.nextYoutubePlayer = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:videoID];
    self.nextYoutubePlayer.delegete = self;
    self.nextYoutubePlayer.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    self.nextYoutubePlayer.moviePlayer.allowsAirPlay = YES;
    //これで再生可能になったタイミングでViewのデリゲートメソッドが呼ばれる。
    //エラーならYouTubeErrorOccredが呼ばれる。
    
}




// --------------------- BackGround Playback ------------------------

-(void) enableBackGroundPlayback {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willTerminate) name:UIApplicationWillTerminateNotification object:nil];
}
- (void) willEnterBackground {
    NSLog(@"willEnterBackground");
    [self performSelector:@selector(playplayer) withObject:nil afterDelay:0.001];
}
- (void) playplayer {
    [youtubePlayer.moviePlayer play];
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
