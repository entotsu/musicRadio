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






-(NSArray*) searchArtistByLastfmWithArtistName: (NSString*)artistName {
    NSMutableArray *returnArray;
    NSString *url = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                     LASTFM_API_URL, @"?api_key=", LASTFM_API_KEY, @"&format=json"
                     @"&method=artist.search&limit=4",
                     @"&artist=", artistName];

    NSDictionary *result = [_httpRequest getJsonWithURLString:url];
    
    if (result == nil) {
        return nil;
    }
    
    NSDictionary *artistMatches = result[@"results"][@"artistmatches"];
    NSString *total = result[@"results"][@"opensearch:totalResults"];
    
    if ([total isEqual: @"0"]) {
        NSLog(@" artist search result is 0!");
        return [NSArray new];
    }
    else if ([total isEqual:@"1"]) {
        NSLog(@"one!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        returnArray = [NSMutableArray array];
        [returnArray addObject:artistMatches[@"artist"]];
    }
    else {
        returnArray = artistMatches[@"artist"];
    }
    
    return (NSArray*)returnArray;
}




-(NSArray*) getTopTracksWithArtistName: (NSString*)artistName {
    NSString *url = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                     LASTFM_API_URL, @"?api_key=", LASTFM_API_KEY, @"&format=json"
                     @"&method=artist.getTopTracks&limit=100",
                     @"&artist=", artistName];

    NSDictionary *result = [_httpRequest getJsonWithURLString:url];
    if (result == nil) {
        return nil;
    }
    return result[@"toptracks"][@"track"];
}


-(NSArray*) getTopTracksWithArtistMbid: (NSString*)mbid {
    NSString *url = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                     LASTFM_API_URL, @"?api_key=", LASTFM_API_KEY, @"&format=json"
                     @"&method=artist.getTopTracks&limit=100",
                     @"&mbid=", mbid];
    
    NSDictionary *result = [_httpRequest getJsonWithURLString:url];
    if (result == nil) {
        return nil;
    }
    return result[@"toptracks"][@"track"];
}



-(NSArray*) getSimilarTracksWithMbid: (NSString*)mbid {
    NSString *url = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                     LASTFM_API_URL, @"?api_key=", LASTFM_API_KEY, @"&format=json"
                     @"&method=track.getSimilar",
                     @"&mbid=", mbid];
    
    NSDictionary *result = [_httpRequest getJsonWithURLString:url][@"similartracks"];
    
    if (result == nil) {
        return nil;
    }
    
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
    
    if (result == nil) {
        return nil;
    }
    
    BOOL is_error = [result.allKeys containsObject:@"error"];
    if (is_error) {
        NSLog(@"ERROR!: similar Artist Error : %@", result[@"message"]);
        return nil;
    }
    
    return result[@"similarartists"][@"artist"];
}



-(NSDictionary*) getArtistInfoWithName: (NSString*)artistName {
    NSString *url = [NSString stringWithFormat:@"%@%@%@%@%@%@%@",
                     LASTFM_API_URL, @"?api_key=", LASTFM_API_KEY,
                     @"&method=artist.getinfo",
                     @"&format=json&lang=jp",
                     @"&artist=", artistName];
    
    NSDictionary *result = [_httpRequest getJsonWithURLString:url];
    
    if (result == nil) {
        return nil;
    }
    
    BOOL is_error = [result.allKeys containsObject:@"error"];
    if (is_error) {
        return NULL;
    }
    
    return result;
}


//http://ws.audioscrobbler.com/2.0/?method=geo.gettopartists&country=japan&api_key=3119649624fae2e9531bc4639a08cba8&format=json

- (NSArray *) getTopArtists {
    NSString *url = [NSString stringWithFormat:@"%@%@%@%@%@",
                     LASTFM_API_URL, @"?api_key=", LASTFM_API_KEY,
                     @"&method=geo.gettopartists",
                     @"&country=japan&format=json&limit=260"];
    
    NSDictionary *result = [_httpRequest getJsonWithURLString:url];
    
    if (result == nil) {
        NSLog(@"ERROR: top artist is not returned!!");
        return nil;
    }
    
    return result[@"topartists"][@"artist"];
}



- (NSArray *) getHypeArtists {
    NSString *url = [NSString stringWithFormat:@"%@%@%@%@%@",
                     LASTFM_API_URL, @"?api_key=", LASTFM_API_KEY,
                     @"&method=geo.getmetrohypeartistchart",
                     @"&country=japan&metro=tokyo&format=json"];

    NSDictionary *result = [_httpRequest getJsonWithURLString:url];
    
    if (result == nil) {
        NSLog(@"ERROR: hype artist is not returned!!");
        return nil;
    }
    return result[@"topartists"][@"artist"];
}



@end
