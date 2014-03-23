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
    //TODO ここローカライズするときに日本以外の国でJPとカテゴリId外す。
    //それかそれぞれローカライズする。(大変だけど)
    NSString *url = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                     YOUTUBE_API_URL, @"?key=", YOUTUBE_API_KEY,
                     @"&part=snippet&type=video&order=relevance&regionCode=JP&videoCategoryId=10",//国は日本、カテゴリはMusic
                     @"&q=", keyword];

    if (limit>0 && limit<=50)
        url = [NSString stringWithFormat:@"%@%@%d", url, @"&maxResults=", limit];
    
    
    return [self getJsonWithURLString: url];
}







- (NSDictionary *) getTopVideoByKeyword: (NSString *)keyword {
    NSDictionary *result = [self searchByKeyword:keyword andLimit:1];
    
//    NSLog(@"getTopVideoIDByKeyword  result: %@",result);
    
    //もし検索結果が０件だったらnilを返す。
    if ([result[@"items"] count] == 0)
        return nil;
    
    //  TODO  ここで動画の長さを判定して、もし合わなかったら次の曲にする。→LIMITふやす
    
    NSDictionary *topVideo = result[@"items"][0];
    return topVideo;
}







//最初にアーティスト手っ取り早く取ってくるメソッド。制限はどれくらいがいいだろう？
- (NSString *) getRandomVideoIDByKeyword: (NSString *)keyword {
    NSDictionary *result = [self searchByKeyword:keyword andLimit:20];//50件は多すぎるか。
//    NSLog(@"YouTube result : %@",result);
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
