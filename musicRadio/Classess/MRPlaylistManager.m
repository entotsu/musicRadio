//
//  MRPlaylistGenerator.m
//  musicRadio
//
//  Created by Takuya Okamoto on 2014/01/30.
//  Copyright (c) 2014年 Takuya Okamoto. All rights reserved.
//

#import "MRPlaylistManager.h"
#import "MRLastfmRequest.h"

#define MAX_PLAYLIST_LENGTH  2000

@implementation MRPlaylistManager {
    MRLastfmRequest *_lastfmRequest;
    NSMutableArray *_playList;
    int _nowIndex;
}
@synthesize radio;
@synthesize isHavingTrack;


- (id) init
{
    NSLog(@"init of MRPlaylistGenerator.");
    self = [super init];
    
    if (self != nil) {
        //ここにサブクラス固有の初期化をかく
        _lastfmRequest = [[MRLastfmRequest alloc] init];
        _playList = [NSMutableArray array];
    }
    return self;
}



// --------------- public method ------------------

- (void) generatePlaylistBySimilarArtistsWithArtistName: (NSString*)artistName {
    NSLog(@"[MRPlaylistManager generatePlaylistBySimilarArtistsWithArtistName]");
    NSMutableArray *similarArtists = [NSMutableArray arrayWithArray:[_lastfmRequest getSimilarArtistsWithArtistName:artistName]];

//    int i;
    
//    for (i=0; i<(int)[similarArtists count]; i++) {
    while (0 <= (int)[similarArtists count]) {
        //次のアーティストをランダムで取得
        int randIndex = (int)arc4random_uniform( (int)[similarArtists count] );
        NSDictionary *artist = [similarArtists[randIndex] copy];
        [similarArtists removeObjectAtIndex:randIndex];
        
        NSLog(@"+++++++++++++++++++ similar Artist 【%@】",artist[@"name"]);
        NSString *mbid = artist[@"mbid"];
        if ([mbid isEqualToString:@""] || mbid == nil) {
            [self generatePlaylistBySimilarTrackWithArtistName:artist[@"name"] orMbid:nil isSimilarArtist:YES];
        }
        else {
            [self generatePlaylistBySimilarTrackWithArtistName:nil orMbid:mbid isSimilarArtist:YES];
        }
        if([_playList count] >= MAX_PLAYLIST_LENGTH) break;
    }
}





//アーティスト名からプレイリストをつくる。
//まずトップトラックを取得し、
//(もし、似ているアーティストでの検索ならそれも追加していく)
//そのトップトラックを上から順番に、似ているトラックを探していく。
//似ているトラックが見つからなかった時点で、そのアーティストでは似ているトラックを探すのをあきらめる。
//(そしてもし、検索対象アーティストのシミラートラックを探しているフェーズにて、トラックが見つからない場合は、そのアーティストに似ているアーティストでそれを随時検索していく。)
//また、
//随時、「トラック数が基準を超えてないか」を確認し、2000曲を超えていたらプレイリスト作成を終える。
//「まだ一曲目のプレイリストを再生していない」場合はいくらかの曲が集まった時点ですぐに次の再生準備を行う。
-(int) generatePlaylistBySimilarTrackWithArtistName: (NSString*)artistName orMbid:(NSString*)mbid isSimilarArtist:(BOOL)isSimilarArtist {

    NSLog(@"generatePlaylistByArtistName");

    static BOOL is_playing = NO;//ここ注意　プレイリストの一曲目をまだ返してない時のみ。
    BOOL disableFindingSimilarTrack = YES;//やっぱ最初からsimilarTrackを探さない方針に変更。
    
    //ここで似てるアーティストが０だと落ちる
    /*
     getJSON -> 'http://ws.audioscrobbler.com/2.0/?api_key=3119649624fae2e9531bc4639a08cba8&format=json&method=artist.getTopTracks&mbid=27f0af0e-4d1f-4808-a58b-090e400dcc43' ...
     2014-02-13 21:40:18.518 musicRadio[19350:3f03] *** Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: 'data parameter is nil'
     *** First throw call stack:
     (
     0   CoreFoundation                      0x0000000101e9f795 __exceptionPreprocess + 165
     1   libobjc.A.dylib                     0x000000010185c991 objc_exception_throw + 43
     2   CoreFoundation                      0x0000000101e9f5ad +[NSException raise:format:] + 205
     3   Foundation                          0x00000001015374a8 +[NSJSONSerialization JSONObjectWithData:options:error:] + 67
     4   musicRadio                          0x0000000100002a41 -[MRHttpRequest getJsonWithURLString:] + 593
     5   musicRadio                          0x0000000100006f7b -[MRLastfmRequest getTopTracksWithArtistMbid:] + 203
     */
    NSArray *topTracks;
    if (mbid)
        topTracks = [_lastfmRequest getTopTracksWithArtistMbid:mbid];
    else if(artistName)
        topTracks = [_lastfmRequest getTopTracksWithArtistName:artistName];
    else
        NSLog(@"ERROR!! : This Method must get 'artistname' or 'mbid'.");
    
    
    int topTrackLength = (int)[topTracks count];
    NSLog(@"toptracks count: %d", topTrackLength);
    
    
    //ここでループしてプレイリスト作成する。
    int i, j;
    for (i=0; i<topTrackLength; i++) {
        
        if( [_playList count] >= MAX_PLAYLIST_LENGTH ) break;
        
        NSDictionary *track = topTracks[i];
        
//        NSLog(@"toptracks %d: ========================= → %@", i, topTracks[i][@"name"]);
        if (isSimilarArtist) {
            [self addTrackToPlaylist:topTracks[i]];
        }
        
        NSArray *similarTracks;
        if (!disableFindingSimilarTrack)
             similarTracks = [_lastfmRequest getSimilarTracksWithMbid:track[@"mbid"]];
        
        //似てるトラックが見つかれば追加。見つからなければ次のアーティストにいく。
        if (similarTracks) {
            int similarTracksLength = (int)[similarTracks count];
            NSLog(@"similarTrack is exist!   length: %d", similarTracksLength);
            for (j=0; j<similarTracksLength; j++) {
                [self addTrackToPlaylist:similarTracks[j]];

                //similarTrackで最初に沢山追加ついかした時にランダムで再生準備する。
                if (!is_playing){
                    is_playing = YES;
                    [self.radio randomSongCanPlay:[self getNextTrack]];
                }
                if([_playList count] >= MAX_PLAYLIST_LENGTH) break;
            }
            //ここでまだ一曲目を再生してなかったらラジオに今あるなかからランダムで渡す。
            //ちなみにここはsimilarTrackが初めて検出された時のタイミング。
            if (!is_playing){
                is_playing = YES;
                [self.radio randomSongCanPlay:[self getNextTrack]];
            }
        }
        //そのアーティストの場合は次のアーティストにいく
        else if (!isSimilarArtist) {
            NSLog(@"similar tracks is not exist!!");
            //ここで似てるアーティストに変更
            [self generatePlaylistBySimilarArtistsWithArtistName:artistName];
            break;
        }
        //似てるアーティストから来た場合は次のトップトラックへ。
        else if (isSimilarArtist) {
            disableFindingSimilarTrack = YES;
        }
    }
    //最初にTopTrack全部追加したあとにまだ再生してなかったらランダムで渡す。
    if (!is_playing){
        is_playing = YES;
        [self.radio randomSongCanPlay:[self getNextTrack]];
    }
    NSLog(@"generatePlaylistBySimilarTrackWithArtistName is END.   playlist length: %d",(int)[_playList count]);
    return 0;
}





- (void) addTrackToPlaylist:(NSDictionary *)addTrack {
    //画像がない場合は "nothing"!!!!!!!!!!!!!!!!
    NSString *trackImage = @"nothing";
    BOOL is_image_exist = [addTrack.allKeys containsObject:@"image"];
    if (is_image_exist) trackImage = addTrack[@"image"][3];
    
    NSDictionary *addDict = @{@"name"   : addTrack[@"name"],
                              @"artist" : addTrack[@"artist"][@"name"],
                              @"image"  : trackImage,
                              @"mbid"   : addTrack[@"mbid"]};
    [_playList addObject:addDict];
    
    if (!isHavingTrack) isHavingTrack = YES;
}









-(NSDictionary*)getRandomTrack {
    int randIndex = (int)arc4random_uniform( (int)[_playList count] );
    return _playList[randIndex];
}


-(NSDictionary*)getNextTrack {
    int randIndex = (int)arc4random_uniform( (int)[_playList count] );
    //次のトラックをコピーして削除
    NSDictionary *nextTrackInfo = [_playList[randIndex] copy];
    [_playList removeObjectAtIndex:randIndex];
    return nextTrackInfo;
}


-(int) resetPlaylist {
    [_playList removeAllObjects];
    return 0;
}




@end
