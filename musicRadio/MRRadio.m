//
//  MRRadio.m
//  musicRadio
//
//  Created by Takuya Okamoto on 2014/01/30.
//  Copyright (c) 2014年 Takuya Okamoto. All rights reserved.
//

#import "MRRadio.h"
#import "MRPlaylistGenerator.h"
#import "MRMusicPlayer.h"
#import "MRLastfmRequest.h"
#import "MRExfmRequest.h"
#import "TestplayViewController.h" //test

@implementation MRRadio {
    MRPlaylistGenerator *_playlistGanerator;
    MRLastfmRequest *_lastfmRequest;
    MRExfmRequest *_exfmRequest;
    MRMusicPlayer *_musicPlayer;
    NSString *_nowPlayingName;//test
    
    TestplayViewController *_testView;//test
}





- (id) init
{
    NSLog(@"init of MRRadio.");
    self = [super init];
    
    if (self != nil) {
        _playlistGanerator = [[MRPlaylistGenerator alloc] init];
        _lastfmRequest = [[MRLastfmRequest alloc] init];
        _exfmRequest = [[MRExfmRequest alloc] init];
        _musicPlayer = [[MRMusicPlayer alloc] init];
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
    
    int relustOfGeneretingPlaylist = [_playlistGanerator generatePlaylistByArtistName:artistName callback:self];
    
    NSLog(@"result of generaging playlst :%d", relustOfGeneretingPlaylist);
    
    return 0;
}


-(void) onCreatedPlaylist {
    NSLog(@"on created playlist------------");
    
    [self test_random_play];

}




// ------------------- private method ----------------------------------------------










//--------------  test ---------------------------
- (int) test_random_play {
    NSString *playUrlString = [self get_random_play_url];
    
    NSLog(@"play url!!");
    [_musicPlayer playMusicWithURL:playUrlString];
    
    return 0;
}


- (NSString*) get_random_play_url {
    
    NSDictionary *randomTrack = [_playlistGanerator getRandomTrack];
    
    NSString *songSearhKeyword = [NSString stringWithFormat:@"%@ %@",
                                  randomTrack[@"artist"],randomTrack[@"name"]];
    
    _nowPlayingName = [NSString stringWithFormat:@"%@ / %@",
                          randomTrack[@"name"],randomTrack[@"artist"]];
    
    NSLog(@"-----Song Search : %@",songSearhKeyword);
    
    NSDictionary *songSearchResult = [_exfmRequest searchSongByExfmWithKeyword:songSearhKeyword];
    
    NSLog(@"song search results count :%@",songSearchResult[@"results"]);
    
    if ( [[songSearchResult[@"results"] stringValue] isEqualToString:@"0"] ) {
        NSLog(@" song search result is 0!!!!!!!!!!!!!!!!!!!!!!!!!!! ");
        return [self get_random_play_url];//再起！！こわ！ｗ
    }
    else {
        NSDictionary *song = songSearchResult[@"songs"][0];
        [_testView setLabelText:_nowPlayingName];//test
        return song[@"url"];
    }
}


-(int) resetPlaylist {
    [_playlistGanerator resetPlaylist];
    return 0;
}

-(NSString*) getNowPlayingTitle {
    return _nowPlayingName;
}


//------------------あとでけす----------------------
- (void) setTestView :(id)view{
    _testView = view;
}


@end
