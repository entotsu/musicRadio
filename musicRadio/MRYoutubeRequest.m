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

- (NSDictionary*) searchByKeyword : (NSString *)keyword {
    NSString *url = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                     YOUTUBE_API_URL, @"?key=", YOUTUBE_API_KEY,
                     @"&part=id",
                     @"&q=", keyword];
    
    return [self getJsonWithURLString: url];
}


- (NSString *) getTopVideoIDByKeyword: (NSString *)keyword {
    NSDictionary *result = [self searchByKeyword:keyword];
    NSString *videoID = result[@"items"][0][@"id"][@"videoId"];
    NSLog(@"youtube top id: %@", videoID);
    return videoID;
}

- (NSString *) getRandomVideoIDByKeyword: (NSString *)keyword {
    NSDictionary *result = [self searchByKeyword:keyword];
    NSArray *videoArray = result[@"items"];
    int randIndex = (int)arc4random_uniform( (int)[videoArray count] );
    NSString *videoID = videoArray[randIndex][@"id"][@"videoId"];
    NSLog(@"youtube top id: %@", videoID);
    return videoID;
}
@end
