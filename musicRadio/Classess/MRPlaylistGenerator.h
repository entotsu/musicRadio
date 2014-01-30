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
- (void) searchTrackWithName:(NSString *)trackName andArtist:(NSString*) artistName;


-(NSURL*)goPreviousTrack;
-(NSURL*)getNowTrack;
-(NSURL*)goNextTrack;


@end
