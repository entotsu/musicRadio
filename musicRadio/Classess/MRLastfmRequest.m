//
//  MRLastfmRequest.m
//  musicRadio
//
//  Created by Takuya Okamoto on 2014/01/31.
//  Copyright (c) 2014年 Takuya Okamoto. All rights reserved.
//

#import "MRLastfmRequest.h"
#import "MRHttpRequest.h"

@implementation MRLastfmRequest {
    MRHttpRequest *_httpRequest;
}
static NSString * const LASTFM_API_URL = @"http://ws.audioscrobbler.com/2.0/";
static NSString * const LASTFM_API_KEY = @"3119649624fae2e9531bc4639a08cba8";





- (id) init
{
    NSLog(@"init of MRLastfmRequest.");
    self = [super init];
    
    if (self != nil) {
        //ここにサブクラス固有の初期化をかく
        _httpRequest = [[MRHttpRequest alloc] init];
    }
    return self;
}






-(NSDictionary*) searchArtistByLastfmWithArtistName: (NSString*)artistName {
    NSString *url = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                     LASTFM_API_URL, @"?api_key=", LASTFM_API_KEY, @"&format=json"
                     @"&method=artist.search",
                     @"&artist=", artistName];
    return [_httpRequest getJsonWithURLString:url];
}




-(NSArray*) getTopTracksWithArtistName: (NSString*)artistName {
    NSString *url = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                     LASTFM_API_URL, @"?api_key=", LASTFM_API_KEY, @"&format=json"
                     @"&method=artist.getTopTracks",
                     @"&artist=", artistName];

    NSDictionary *result = [_httpRequest getJsonWithURLString:url];
    return result[@"toptracks"][@"track"];
}


-(NSArray*) getTopTracksWithArtistMbid: (NSString*)mbid {
    NSString *url = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                     LASTFM_API_URL, @"?api_key=", LASTFM_API_KEY, @"&format=json"
                     @"&method=artist.getTopTracks",
                     @"&mbid=", mbid];
    
    NSDictionary *result = [_httpRequest getJsonWithURLString:url];
    return result[@"toptracks"][@"track"];
}



-(NSArray*) getSimilarTracksWithMbid: (NSString*)mbid {
    NSString *url = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                     LASTFM_API_URL, @"?api_key=", LASTFM_API_KEY, @"&format=json"
                     @"&method=track.getSimilar",
                     @"&mbid=", mbid];
    
    NSDictionary *result = [_httpRequest getJsonWithURLString:url][@"similartracks"];
    
    BOOL is_not_exists = [result.allKeys containsObject:@"artist"];
    if (is_not_exists) {
        return NULL;
    }
    
    return result[@"track"];
}




-(NSArray*) getSimilarArtistsWithArtistName: (NSString*)artistName {
    NSString *url = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                     LASTFM_API_URL, @"?api_key=", LASTFM_API_KEY, @"&format=json"
                     @"&method=artist.getsimilar",
                     @"&artist=", artistName];
    
    NSDictionary *result = [_httpRequest getJsonWithURLString:url];
    
    BOOL is_error = [result.allKeys containsObject:@"error"];
    if (is_error) {
        NSLog(@"ERROR!: similar Artist Error : %@", result[@"message"]);
        return nil;
    }
    
    return result[@"similarartists"][@"artist"];
}




@end
