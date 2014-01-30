//
//  MRRadio.h
//  musicRadio
//
//  Created by Takuya Okamoto on 2014/01/30.
//  Copyright (c) 2014年 Takuya Okamoto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRRadio : NSObject



-(NSArray*) searchSongWithArtistName:(NSString*) keyword;

-(int) playArtistTopMusicRandomly:(NSString*) artistName;

-(int) generatePlaylistByArtistName:(NSString*)artistName;

-(int) startPlayRadio;

-(int) getCurrentTrack;

-(void) onCreatedPlaylist;

-(int) togglePlayAndPause;
-(int) goNext;
-(int) goPrevious;


-(int) loveCurrentTrack;
-(int) addLocalPlaylistThisTrack;


-(int) resetPlaylist;

//-(int) generatePlaylistWithThisTrack;


@end
