//
//  MRPlaylistGenerator.h
//  musicRadio
//
//  Created by Takuya Okamoto on 2014/01/30.
//  Copyright (c) 2014年 Takuya Okamoto. All rights reserved.
//

#import <Foundation/Foundation.h>






@class MRPlaylistManager;


@protocol MRPlaylistGeneratorDelegate <NSObject>
- (void) randomSongCanPlay:(NSDictionary *)songInfo;
@end



@interface MRPlaylistManager : NSObject
//lastfmで検索してプレイリストを作成
//- (void) searchTrackWithName:(NSString *)trackName andArtist:(NSString*) artistName;
-(int) generatePlaylistBySimilarTrackWithArtistName: (NSString*)artistName orMbid:(NSString*)mbid isSimilarArtist:(BOOL)isSimilarArtist;
- (void) generatePlaylistBySimilarArtistsWithArtistName: (NSString*)artistName;
-(NSDictionary*)getRandomTrack;
-(NSDictionary*)getNowTrack;
-(NSDictionary*)getPreviousTrack;
-(NSDictionary*)getNextTrack;
-(int) resetPlaylist;


@property (nonatomic,assign) id <MRPlaylistGeneratorDelegate> radio;
@property BOOL isHavingTrack;

@end
