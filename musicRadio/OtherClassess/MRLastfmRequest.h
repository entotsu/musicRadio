//
//  MRLastfmRequest.h
//  musicRadio
//
//  Created by Takuya Okamoto on 2014/01/31.
//  Copyright (c) 2014年 Takuya Okamoto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRLastfmRequest : NSObject

-(NSArray*) searchArtistByLastfmWithArtistName: (NSString*)artistName;
-(NSArray*) getTopTracksWithArtistName: (NSString*)artistName;
-(NSArray*) getTopTracksWithArtistMbid: (NSString*)mbid;
-(NSArray*) getSimilarTracksWithMbid: (NSString*)mbid;
-(NSArray*) getSimilarArtistsWithArtistName: (NSString*)artistName;
-(NSDictionary*) getArtistInfoWithName: (NSString*)artistName;
- (NSArray *) getTopArtists;
- (NSArray *) getHypeArtists;
@end
