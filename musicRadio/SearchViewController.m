//
//  SearchViewController.m
//  musicRadio
//
//  Created by Takuya Okamoto on 2014/01/30.
//  Copyright (c) 2014年 Takuya Okamoto. All rights reserved.
//

#import "SearchViewController.h"


@interface SearchViewController ()

@end





@implementation SearchViewController

static NSString * const EXFM_SONG_SEARCH_URL = @"http://ex.fm/api/v3/song/search/";


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"search view did load.");
    
    //実際は検索のマド作る
    NSString *searchKeyword = @"ONE OK ROCK nothing helps";
    
    NSDictionary *songSearchResult = [self searchSongAtExfmByKeyword:searchKeyword];
//    NSLog(@"%@",songSearchResult);

    //実際はここで選ばせる
    NSLog(@"%@",[songSearchResult objectForKey:@"songs"][0]);
    //これをMusic再生してみよう
    NSString *songURL = [[songSearchResult objectForKey:@"songs"][0] objectForKey:@"url"];
    NSLog(@"%@",songURL);
}



- (NSDictionary*) searchSongAtExfmByKeyword: (NSString*)keyword {

    NSString *url = [NSString stringWithFormat:@"%@%@",EXFM_SONG_SEARCH_URL,keyword];
    
    return [self httpGetJsonWithURLString:url];

}







- (NSDictionary*) httpGetJsonWithURLString:(NSString*)url {
    //encoding
    url = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                    NULL,
                    (CFStringRef)url,
                    NULL,
                    (CFStringRef)@"!*'();@&=+$,?%#[]",//こんなにエンコードする必要あるかな？
                    kCFStringEncodingUTF8));
    
    NSLog(@"%@",url);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSData *json_data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSError *error=nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:json_data options:kNilOptions error:&error];
    
    return json;
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
