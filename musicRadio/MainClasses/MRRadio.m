//
//  MRRadio.m
//  musicRadio
//
//  Created by Takuya Okamoto on 2014/01/30.
//  Copyright (c) 2014年 Takuya Okamoto. All rights reserved.
//

//TODO: PlaylistManagerの連携を全て外す。

#import "MRRadio.h"
#import "MRLastfmRequest.h"
#import "MRExfmRequest.h"
#import "MRYoutubeRequest.h"
#import "MRLyricFetcher.h"

@implementation MRRadio {
    MRLastfmRequest *_lastfmRequest;
    MRExfmRequest *_exfmRequest;
    MRYoutubeRequest *_youTubeRequest;
    BOOL _didPlayFastTrack;
    BOOL _didGetFirstSimilarSongInfo;
    BOOL _isFinishToGetNextTrack;
    BOOL _isPreparingNextTrack;
    BOOL _isStartPlaying;
    NSString *_nowPlayingText;
    
    NSString *_nextArtistName;
    NSString *_nextTrackName;
    
    MRLyricFetcher *_lyricFetcher;
    NSString *_nextLyricString;
    NSString *_lyricString;
    
    NSString *_nextArtistBio;
    
    NSArray *_similarArtists;
}

@synthesize youtubePlayer;
@synthesize nextYoutubePlayer;
@synthesize delegeteViewController;



- (id) init
{
    NSLog(@"init of MRRadio.");
    self = [super init];
    
    if (self != nil) {
        _lastfmRequest = [[MRLastfmRequest alloc] init];
        _exfmRequest = [[MRExfmRequest alloc] init];
        _youTubeRequest = [[MRYoutubeRequest alloc] init];
        _lyricFetcher = [[MRLyricFetcher alloc] init];
        
        [self enableBackGroundPlayback];
        [self enableAutoPlay];
    }
    return self;
}

- (void) dealloc {
    NSLog(@"dealloc MRRadio");
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
//    [_playlistManager generatePlaylistBySimilarArtistsWithArtistName:artistName];
    [self setArtistForPrepare:artistName];
}


// 次の曲の準備
-(void) prepareNextTrack {
    NSLog(@"★★★★★★★★★★★★★★★★★ 次の曲を準備します ★★★★★★★★★★★★★★★★★");
    if(!_isPreparingNextTrack && !_isFinishToGetNextTrack) {
        _isPreparingNextTrack = YES;
        NSDictionary *songInfo = [self searchAndGetNextTrack];
        if (songInfo) {
            [self prepareYouTubeWithSongInfo:songInfo];
        }
        else {
            _isPreparingNextTrack = NO;
            [self prepareNextTrack];
        }
    }
    else {
        NSLog(@"もう準備していました");
    }
}








//----------------------------------- Delegete ------------------------------

#pragma mark PlaylystManager Delegete

//プレイリスト作成後に最初の一曲目を手早く渡してもらうデリゲートメソッド
- (void)randomSongCanPlay: (NSDictionary *)songInfo //今は呼ばれない
{
    NSLog(@"randomSongCanPlay------------");
    _didGetFirstSimilarSongInfo = YES;
    [self prepareYouTubeWithSongInfo:songInfo];
}



#pragma mark YoutubePlayer Delegete
- (void) onYoutubeLoadingSuccess
{
    NSLog(@"onYoutubeLoadingSuccess　再生準備完了！！！◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆----PlayState: %d", (int)youtubePlayer.moviePlayer.playbackState);
    NSLog(@"loadstate: %d   _isStartPlaying: %d", (int)youtubePlayer.moviePlayer.loadState, _isStartPlaying);
    // 最初のプレイの時
    if (!_didPlayFastTrack) { //さいしょのプレイでsimilarが再生されると次の曲が用意されない
        [self startPlaybackNextVideo];
    }
    else if(!_isFinishToGetNextTrack) {//ここが何故か２回呼ばれるから仕方なくフラグで分ける。
        
        //もし準備完了後になにも再生されてない状態だったら再生する。
        if (!_isStartPlaying) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                NSLog(@"---------------------------check");
                if (!_isStartPlaying) {
                    NSLog(@"再生準備後に音楽再生されてなかったのですぐに再生します。");
                    [self startPlaybackNextVideo];
                }
                else {
                    [self onSuccessPreparingNextTrack];
                }
            });
        }
        else {
            [self onSuccessPreparingNextTrack];
        }
    }
}



- (void) onSuccessPreparingNextTrack {
    _isFinishToGetNextTrack = YES;
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
        //                _nextLyricString = [_lyricFetcher getLyricWithTitle:_nextTrackName andArtist:_nextArtistName];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        //                _nextArtistBio = [self getArtistBioWithName:_nextArtistName];
    });

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
        [self prepareNextTrack];
    }
}














// ------------------- private method ----------------------------------------------



- (void) prepareYouTubeWithSongInfo: (NSDictionary *)songInfo {

    _isPreparingNextTrack = NO;
    
    NSString *artistName = songInfo[@"artist"];
    NSString *trackName = songInfo[@"name"];

    if ((!artistName) || (!trackName)) {
        NSLog(@"EROOR: アーティスト名またはトラック名がnull");
        return [self YouTubeErrorOccred];
    }
    
    _nextArtistName = artistName;
    _nextTrackName = trackName;
    _nowPlayingText = [NSString stringWithFormat:@"%@ - %@", artistName, trackName];
    
    NSString *searchKeyword = [NSString stringWithFormat:@"%@ %@", artistName, trackName];
    NSDictionary *topVideo = [_youTubeRequest getTopVideoByKeyword:searchKeyword];

    NSString *videoTitle = topVideo[@"snippet"][@"title"];
    NSString *topVideoID = topVideo[@"id"][@"videoId"];
    
    NSLog(@"□□□□□□□□ search word :【%@】　□□□□□□□□□□",searchKeyword);
    NSLog(@"■■■■■■■■ video title :【%@】　■■■■■■■■■■",videoTitle);
    
    //動画のバリデーション------------------------------------
    if (!topVideo) return [self YouTubeErrorOccred];
    //ここでその動画のタイトルをチェックする。
    //①アーティスト名とトラック名が入っている
    if ([videoTitle rangeOfString:trackName options:NSCaseInsensitiveSearch].location == NSNotFound
     && [videoTitle rangeOfString:artistName options:NSCaseInsensitiveSearch].location == NSNotFound)
        return [self YouTubeErrorOccred];
    //②カラオケ　歌ってみた (弾いてみた) が入っていない
    NSArray *NG_words = @[@"歌ってみ",@"うたってみ",@"カラオケ",@"カバー",@"cover",@"コピー",@"copy",@"ピッチ",@"弾いてみ"];
    for (NSString* NG_word in NG_words) {
        if ([videoTitle rangeOfString:NG_word options:NSCaseInsensitiveSearch].location != NSNotFound) {
            return [self YouTubeErrorOccred];
        }
    }
    
    //バリデーションが通れば次の動画を準備する。
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
    
    _isFinishToGetNextTrack = NO;
    _isStartPlaying = NO;

    
    if (youtubePlayer) {
        [youtubePlayer.moviePlayer stop];
        youtubePlayer = nil;
    }
    youtubePlayer = nextYoutubePlayer;
    
    youtubePlayer.moviePlayer.controlStyle = MPMovieControlStyleNone;
    [youtubePlayer presentInView:delegeteViewController.youtubeBox];
    
    [youtubePlayer.moviePlayer play];
    nextYoutubePlayer = nil;
    
    //view側のnowPlayingTextとアーティスト名の更新
    [delegeteViewController.nowPlayingLabel setText:_nowPlayingText];
    
    //これでbioの更新が行われる  //あとでリファクタリングする
    if(_didPlayFastTrack) [delegeteViewController displayBio:_nextArtistBio];
    
    //(最初以外は) 歌詞のセット
    if(_didPlayFastTrack) [delegeteViewController displayLyric:_nextLyricString];
    
    
    //今のを再生したら次のトラックを準備する   最初のトラックの時は行われないが特例で、最初にSimilarTrackが流れてしまった場合のみ次の曲の準備に入る
//    if ((_didPlayFastTrack && _playlistManager.isHavingTrack) || ((!_didPlayFastTrack)&&_didGetFirstSimilarSongInfo)) {
    //↓プレイリストマネージャーを切ったのでこっちに改変
    if (!_didPlayFastTrack &&_didGetFirstSimilarSongInfo) {
        delegeteViewController.nextButton.enabled = NO;
    }

}





//FIXME: 正規表現をよくする。
- (NSString*) getArtistBioWithName:(NSString*)artistName {
    NSDictionary *artistInfo = [_lastfmRequest getArtistInfoWithName:artistName];
    NSString *bioString = artistInfo[@"artist"][@"bio"][@"summary"];

    NSLog(@"bio: %@",bioString);
    
    if (bioString) {
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
    }
    
    return bioString;
}








#pragma mart PrivateMethod (GetNextTrack)
//-------- その時その時で次のアーティストを取得する場合のメソッド --------------------
- (void) setArtistForPrepare: (NSString*)artistName {
    NSLog(@"setArtistForPrepare");
    _similarArtists = [_lastfmRequest getSimilarArtistsWithArtistName:artistName];
    if (!_similarArtists) NSLog(@"ERROR: similar artist not found!!");
}


- (NSDictionary*) searchAndGetNextTrack{
    if (_similarArtists) {
        int randIndex = (int)arc4random_uniform( (int)[_similarArtists count] );
        NSDictionary *artist = _similarArtists[randIndex];
        NSString *mbid = artist[@"mbid"];
        NSString *artistName = artist[@"name"];
        NSLog(@"+++++++++++++++++++ similar Artist 【%@】%@",artistName, mbid);
        
        //次の曲の情報の取得
        NSArray *topTracks;
        if (![mbid isEqualToString:@""])
            topTracks = [_lastfmRequest getTopTracksWithArtistMbid:mbid];
        else if(![artistName isEqualToString:@""])
            topTracks = [_lastfmRequest getTopTracksWithArtistName:artistName];
        else
            NSLog(@"ERROR!! : This Method must get 'artistname' or 'mbid'.");
        
        //topトラックがとれたら、ランダムで選んで返す
        if (topTracks) {
            int rand = (int)arc4random_uniform( (int)[topTracks count] );
            NSDictionary* nextTrack = topTracks[rand];

            //情報をシンプルにして返す。
            NSString *trackImage = @"nothing";
            BOOL is_image_exist = [nextTrack.allKeys containsObject:@"image"];
            if (is_image_exist) trackImage = nextTrack[@"image"][3];
            
            NSDictionary *trackInfo = @{@"name"   : nextTrack[@"name"],
                                      @"artist" : nextTrack[@"artist"][@"name"],
                                      @"image"  : trackImage,
                                      @"mbid"   : nextTrack[@"mbid"]};
            return trackInfo;
        }
        else {
            NSLog(@"ERROR: Faild to get toptrack!");
            return nil;
        }
    }
    return nil;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLoadStateDidChange) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishPlayback) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}

- (void) onLoadStateDidChange {
    NSLog(@"--------- onLoadStateDidChange ---------------　playstate:%d", (int)youtubePlayer.moviePlayer.playbackState);
    NSLog(@"loadstate: %d",(int)youtubePlayer.moviePlayer.loadState);
    
    if (youtubePlayer.moviePlayer.loadState == 3) {
        
        _isStartPlaying = YES;
        
        //再生が開始されたらポーズボタンを有効化する
        delegeteViewController.pauseButton.enabled = YES;
        
        //一曲目の場合
        if(!_didPlayFastTrack){
            _didPlayFastTrack = YES;    //最初のプレイの場合はフラグを立てる。
            [self.delegeteStartViewController didSuccessPlayArtistFirstTrack];
            //最初のプレイが開始したタイミングで２曲目を準備する
            [self prepareNextTrack];
        }
    }

    //２秒後にもし準備してなかったら準備する。
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [self prepareNextTrack];
        });
    });
    
}



//FIXME: StartViewで再生してるときにこれくると落ちる。
//→ _didFirstPlayFinishみたいなの必要かも。で、それだったらもっかいrandomPlayする。
- (void) finishPlayback {
    NSLog(@"----- finishPlayback ------");
    
    NSTimeInterval remainTime = youtubePlayer.moviePlayer.duration - youtubePlayer.moviePlayer.currentPlaybackTime;
    NSLog(@"remainTime : %f", remainTime);
    
    if (_didPlayFastTrack && remainTime <= 0) {
        NSLog(@"VIDEO IS END!!");
        _isStartPlaying = NO;
        
        //ここで再生自体に失敗した場合、次の曲をとって再生する。
        //つまり次の曲が無いとき、prepareNextTrackする。
        if (!_isFinishToGetNextTrack) {
            NSLog(@"再生に失敗！！");
            [self prepareNextTrack];
        }
        else {
            [self startPlaybackNextVideo];
        }
        
        //ポーズボタンを無効化する
        delegeteViewController.pauseButton.enabled = NO;
    }
}



@end
