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
#import "MRLyricFetcher.h"

@implementation MRRadio {
    MRPlaylistManager *_playlistManager;
    MRLastfmRequest *_lastfmRequest;
    MRExfmRequest *_exfmRequest;
    MRYoutubeRequest *_youTubeRequest;
    BOOL _didPlayFastTrack;
    BOOL _isStopPlayer;
    NSString *_nowPlayingText;
    
    NSString *_nextArtistName;
    NSString *_nextTrackName;
    
    MRLyricFetcher *_lyricFetcher;
    NSString *_nextLyricString;
    NSString *_lyricString;
    
    NSString *_nextArtistBio;
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
        _lyricFetcher = [[MRLyricFetcher alloc] init];
        
        [self enableBackGroundPlayback];
        [self enableAutoPlay];
    }
    return self;
}














//------------------ public methods -----------------------------------



// 初回の再生
- (void) fastArtistRandomPlay: (NSString*)artistName {
    _didPlayFastTrack = NO;
    _nowPlayingText = artistName;
    NSString *randomVideoID = [_youTubeRequest getRandomVideoIDByKeyword:artistName];
    _nextArtistName = artistName;
    [self prepearYouTubePlayerWithVideoID:randomVideoID];
}

// プレイリスト作成
-(void) generatePlaylistByArtistName: (NSString*)artistName {
    NSLog(@"MRRadio : generatePlaylistByArtistName");
    [_playlistManager generatePlaylistBySimilarArtistsWithArtistName:artistName];
}


// 次の曲の準備
-(void) prepareNextTrack {
    NSDictionary *songInfo = [_playlistManager getNextTrack];
    [self prepareYouTubeWithSongInfo:songInfo];
}












//----------------------------------- Delegete ------------------------------

#pragma mark PlaylystManager Delegete

//プレイリスト作成後に最初の一曲目を手早く渡してもらうデリゲートメソッド
- (void)randomSongCanPlay: (NSDictionary *)songInfo
{
    NSLog(@"randomSongCanPlay------------");
    [self prepareYouTubeWithSongInfo:songInfo];
}



#pragma mark YoutubePlayer Delegete
- (void) onYoutubeLoadingSuccess
{
    NSLog(@"onYoutubeLoadingSuccess　再生準備完了！！！◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆");
    // 最初のプレイの時
    if (!_didPlayFastTrack) {
        [self startPlaybackNextVideo];
    }
    else {
        //スタートボタンを有効にする処理
        //TODO: できればプレイヤーを表示する時にdelegeteをはずしたほうがいいかも
        if (self.delegeteStartViewController) {
            [self.delegeteStartViewController canStartFirstTrack];
        }
        //ネクストボタンを有効にする
        if (delegeteViewController) {
            delegeteViewController.nextButton.enabled = YES;
        }
        //ここで動画preloadしたいけど無理っぽい。動画再生前にpreloadして再生？next_next_playerまで用意して・・
        
        //歌詞を取得
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            _nextLyricString = [_lyricFetcher getLyricWithTitle:_nextTrackName andArtist:_nextArtistName];
        });
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            _nextArtistBio = [self getArtistBioWithName:_nextArtistName];
        });
    }
}


- (void) YouTubeErrorOccred
{
    NSLog(@"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  YouTubeErrorOccred ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    if (!_didPlayFastTrack) {
        //初回のアーティスト曲再生でエラーした場合は他の動画をチョイスしてみる。
        NSLog(@"first Artist Movie Error.");
        [self fastArtistRandomPlay:_nowPlayingText];
    }
    else {
        NSLog(@"Next Movie Error.");
        [self prepareNextTrack];
    }
}














// ------------------- private method ----------------------------------------------



- (void) prepareYouTubeWithSongInfo: (NSDictionary *)songInfo {

    NSString *artistName = songInfo[@"artist"];
    NSString *trackName = songInfo[@"name"];

    _nextArtistName = artistName;
    _nextTrackName = trackName;
    _nowPlayingText = [NSString stringWithFormat:@"%@ - %@", artistName, trackName];
    
    NSString *searchKeyword = [NSString stringWithFormat:@"%@ %@", artistName, trackName];
    NSDictionary *topVideo = [_youTubeRequest getTopVideoByKeyword:searchKeyword];

    NSString *videoTitle = topVideo[@"snippet"][@"title"];
    NSString *topVideoID = topVideo[@"id"][@"videoId"];
    
    NSLog(@"□□□□□□□□ search word :【%@】　□□□□□□□□□□",searchKeyword);
    NSLog(@"■■■■■■■■ video title :【%@】　■■■■■■■■■■",videoTitle);
    
    
    if (!topVideo) return [self YouTubeErrorOccred];
    //ここでその動画のタイトルをチェックする。
    //①アーティスト名とトラック名が入っている
    if ([videoTitle rangeOfString:trackName options:NSCaseInsensitiveSearch].location == NSNotFound)
        return [self YouTubeErrorOccred];
    if ([videoTitle rangeOfString:artistName options:NSCaseInsensitiveSearch].location == NSNotFound)
        return [self YouTubeErrorOccred];
    //②カラオケ　歌ってみた (弾いてみた) が入っていない
    if ([videoTitle rangeOfString:@"歌ってみた" options:NSCaseInsensitiveSearch].location != NSNotFound)
        return [self YouTubeErrorOccred];
    if ([videoTitle rangeOfString:@"うたってみた" options:NSCaseInsensitiveSearch].location != NSNotFound)
        return [self YouTubeErrorOccred];
    if ([videoTitle rangeOfString:@"カラオケ" options:NSCaseInsensitiveSearch].location != NSNotFound)
        return [self YouTubeErrorOccred];
    if ([videoTitle rangeOfString:@"カバー" options:NSCaseInsensitiveSearch].location != NSNotFound)
        return [self YouTubeErrorOccred];
    if ([videoTitle rangeOfString:@"コピー" options:NSCaseInsensitiveSearch].location != NSNotFound)
        return [self YouTubeErrorOccred];
    if ([videoTitle rangeOfString:@"cover" options:NSCaseInsensitiveSearch].location != NSNotFound)
        return [self YouTubeErrorOccred];
    if ([videoTitle rangeOfString:@"ピッチ" options:NSCaseInsensitiveSearch].location != NSNotFound)
        return [self YouTubeErrorOccred];
    if ([videoTitle rangeOfString:@"弾いてみた" options:NSCaseInsensitiveSearch].location != NSNotFound)
        return [self YouTubeErrorOccred];
    
    return [self prepearYouTubePlayerWithVideoID:topVideoID];
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
    NSLog(@"MusicPlayer : startPlaybackNextVideo >>>>>>>>>>>>>>>>>>>>> not 1st?:%d",_didPlayFastTrack);
    
    _isStopPlayer = NO;
    
    if (youtubePlayer) {
        [youtubePlayer.moviePlayer stop];
        youtubePlayer = nil;
    }
    youtubePlayer = nextYoutubePlayer;
    

    [youtubePlayer presentInView:delegeteViewController.youtubeBox];
    
    [youtubePlayer.moviePlayer play];
    nextYoutubePlayer = nil;
    
    //view側のnowPlayingTextとアーティスト名の更新
    [delegeteViewController.nowPlayingLabel setText:_nowPlayingText];
    
    //これでbioの更新が行われる  //あとでリファクタリングする
    if(_didPlayFastTrack) [delegeteViewController displayBio:_nextArtistBio];
    
    //(最初以外は) 歌詞のセット
    if(_didPlayFastTrack) [delegeteViewController displayLyric:_nextLyricString];
    
    //今のを再生したら次のトラックを準備する
    if (_didPlayFastTrack && _playlistManager.isHavingTrack) {
        delegeteViewController.nextButton.enabled = NO;
        [self prepareNextTrack];
    }

}





//FIXME: 正規表現をよくする。
- (NSString*) getArtistBioWithName:(NSString*)artistName {
    NSDictionary *artistInfo = [_lastfmRequest getArtistInfoWithName:artistName];
    NSString *bioString = artistInfo[@"artist"][@"bio"][@"summary"];

    NSLog(@"bio: %@",bioString);
    
    bioString = [bioString stringByReplacingOccurrencesOfString:@"                " withString:@""];
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"<a href=(.+)>"
                                                                            options:0
                                                                              error:nil];
    bioString = [regexp stringByReplacingMatchesInString:bioString
                                                 options:0
                                                   range:NSMakeRange(0,bioString.length)
                                            withTemplate:@""];
    NSLog(@"-----------------------------");
    NSLog(@"bio2: %@",bioString);
    
    return bioString;
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




//-------------------- Auto play ----- 自動で次の曲にいく処理 ------------------
- (void) enableAutoPlay {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishPreload) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishPlayback) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}

- (void) finishPreload {
    NSLog(@"--------- finishPreload ---------------");
    //最初のプレイの場合はフラグを立てる。
    if(!_didPlayFastTrack){
        _didPlayFastTrack = YES;
        [self.delegeteStartViewController didSuccessPlayArtistFirstTrack];
    }
}

//FIXME: StartViewで再生してるときにこれくると落ちる。
//→ _didFirstPlayFinishみたいなの必要かも。で、それだったらもっかいrandomPlayする。
- (void) finishPlayback {
    NSLog(@"----- finishPlayback ------");
    
    NSTimeInterval remainTime = youtubePlayer.moviePlayer.duration - youtubePlayer.moviePlayer.currentPlaybackTime;
    NSLog(@"remainTime : %f", remainTime);
    
    if (_didPlayFastTrack && remainTime <= 0) {
        NSLog(@"VIDEO IS END!!");
        _isStopPlayer = YES;
        [self startPlaybackNextVideo];
    }
}



@end
