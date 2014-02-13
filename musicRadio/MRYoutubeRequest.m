//
//  MRYoutubeRequest.m
//  musicRadio
//
//  Created by Takuya Okamoto on 2014/02/12.
//  Copyright (c) 2014年 Takuya Okamoto. All rights reserved.
//

#import "MRYoutubeRequest.h"


static NSString * const YOUTUBE_API_URL = @"https://www.googleapis.com/youtube/v3/search";
static NSString * const YOUTUBE_API_KEY = @"AIzaSyArZbAYSmERlrJTgQggy8bZ_8xU7Y5z0G0";


@implementation MRYoutubeRequest

- (NSDictionary*) searchByKeyword : (NSString *)keyword andLimit:(int)limit {
    NSString *url = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                     YOUTUBE_API_URL, @"?key=", YOUTUBE_API_KEY,
                     @"&part=id&type=video&order=relevance&regionCode=JP&videoCategoryId=10",//カテゴリはMusic
                     @"&q=", keyword];

    if (limit>0 && limit<=50)
        url = [NSString stringWithFormat:@"%@%@%d", url, @"&maxResults=", limit];
    
    
    return [self getJsonWithURLString: url];
}


- (NSString *) getTopVideoIDByKeyword: (NSString *)keyword {
    NSDictionary *result = [self searchByKeyword:keyword andLimit:0];
    
    NSLog(@"getTopVideoIDByKeyword  result: %@",result);
    
    //もし検索結果が０件だったらnilを返す。
    if ([result[@"items"] count] == 0)
        return nil;
    
    NSString *videoID = result[@"items"][0][@"id"][@"videoId"];
    NSLog(@"youtube top id: %@", videoID);
    return videoID;
}



//最初にアーティスト手っ取り早く取ってくるメソッド。制限はどれくらいがいいだろう？
- (NSString *) getRandomVideoIDByKeyword: (NSString *)keyword {
    NSDictionary *result = [self searchByKeyword:keyword andLimit:10];//50件は多すぎるか。
    NSLog(@"YouTube result : %@",result);
    //もし検索結果が０件だったらnilを返す。
    if ([result[@"items"] count] == 0)
        return nil;
    NSArray *videoArray = result[@"items"];
    int randIndex = (int)arc4random_uniform( (int)[videoArray count] );
    NSString *videoID = videoArray[randIndex][@"id"][@"videoId"];
    NSLog(@"youtube random fast VideoID → %@", videoID);
    return videoID;
}
@end
