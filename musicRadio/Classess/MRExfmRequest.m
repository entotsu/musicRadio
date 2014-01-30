//
//  MRExfmRequest.m
//  musicRadio
//
//  Created by Takuya Okamoto on 2014/01/31.
//  Copyright (c) 2014年 Takuya Okamoto. All rights reserved.
//

#import "MRExfmRequest.h"
#import "MRHttpRequest.h"

@implementation MRExfmRequest {
    MRHttpRequest *_httpRequest;
}
static NSString * const EXFM_SONG_SEARCH_URL = @"http://ex.fm/api/v3/song/search/";



- (id) init
{
    NSLog(@"init of MRExfmRequest.");
    self = [super init];
    
    if (self != nil) {
        //ここにサブクラス固有の初期化をかく
        _httpRequest = [[MRHttpRequest alloc] init];
    }
    return self;
}






-(NSDictionary*) searchSongByExfmWithKeyword: (NSString*)keyword {
    NSString *url = [NSString stringWithFormat:@"%@%@",EXFM_SONG_SEARCH_URL,keyword];
    return [_httpRequest getJsonWithURLString:url];
}







@end
