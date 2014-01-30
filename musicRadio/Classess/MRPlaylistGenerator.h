//
//  MRPlaylistGenerator.h
//  musicRadio
//
//  Created by Takuya Okamoto on 2014/01/30.
//  Copyright (c) 2014年 Takuya Okamoto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRPlaylistGenerator : NSObject

//lastfmで検索してプレイリストを作成
//- (void) searchTrackWithName:(NSString *)trackName andArtist:(NSString*) artistName;
-(int) generatePlaylistByArtistName: (NSString*)artistName callback:(id)callback;


-(NSDictionary*)getRandomTrack;

-(NSURL*)getNowTrack;
-(NSURL*)goPreviousTrack;
-(NSURL*)goNextTrack;

-(int) resetPlaylist;

@end
