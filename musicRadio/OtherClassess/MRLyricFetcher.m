//
//  MRLyricFetcher.m
//  musicRadio
//
//  Created by Takuya Okamoto on 2014/02/24.
//  Copyright (c) 2014年 Takuya Okamoto. All rights reserved.
//

#import "MRLyricFetcher.h"

@implementation MRLyricFetcher



- (NSString*) getLyricWithTitle:(NSString*)title andArtist:(NSString*)artistName {
    
    NSString *lyricId = [self getLyricIdWithTitle:title andArtist:artistName];
    
    if (lyricId) {
        NSString *url = [NSString stringWithFormat:@"%@%@",
                         @"http://www.utamap.com/phpflash/flashfalsephp.php?unum=",lyricId];
        NSString *lyricHtml = [self getHtmlWithURLString:url];
        NSString *lyricString;
        
        if ([lyricHtml rangeOfString:@"test2="].location != NSNotFound) {
            //歌詞があった場合
            NSArray *splited = [lyricHtml componentsSeparatedByString:@"="];
            lyricString = [splited lastObject];
        }
        
        return lyricString;
    }
    else {
        return nil;
    }
}







- (NSString*) getLyricIdWithTitle:(NSString*)title andArtist:(NSString*)artistName {
    
    NSNumber *pageCount = [NSNumber numberWithInt:0];
    
    while (1) {
        
        NSString *url = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                         @"http://www.utamap.com/searchkasi.php",
                         @"?act=search&searchname=artist&sortname=1&pattern=3",
                         @"&word=",artistName,
                         @"&page=",[pageCount stringValue]];
        
        NSString *htmlString = [self getHtmlWithURLString:url];
        
        NSString *pattern   = @"surl=(.+)\">(.+)</A>";
        
        // 正規表現検索を実行
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
        //    NSTextCheckingResult *match = [regex firstMatchInString:htmlString options:0 range:NSMakeRange(0, htmlString.length)];
        NSArray *matchesArray = [regex matchesInString:htmlString options:0 range:NSMakeRange(0, htmlString.length)];
        
        // マッチした場合
        if ([matchesArray count] > 0) {
            int i, length = (int)[matchesArray count];
            for (i=0; i<length; i++) {
                NSTextCheckingResult *match = matchesArray[i];
                NSString *pageId = [htmlString substringWithRange:[match rangeAtIndex:1]];
                NSString *trackName = [htmlString substringWithRange:[match rangeAtIndex:2]];
                //タイトルをチェックして一致したらIDを返す
                if ([trackName caseInsensitiveCompare:title] == NSOrderedSame) {
                    NSLog(@"■■■■■■■■■　歌詞が見つかりました !!!! ■■■■■■■■■■■■");
                    NSLog(@"%@", trackName);
                    return pageId;
                }
            }
            NSLog(@"歌詞が見つからなかったので次のページに遷移します");
            //ページカウントを増やして次のURLを叩く。
            pageCount = [NSNumber numberWithInt:[pageCount intValue] + 1];
        } else {
            //結局うたまっぷでは見つからなかった場合。
            NSLog(@"** 歌詞が見つかりませんでした **");
            return nil;
        }
        
    }
}












- (NSString*) getHtmlWithURLString:(NSString*)url {
    //encoding
    NSArray *splitedURL = [url componentsSeparatedByString:@"?"];
    NSString *urlParamsString = splitedURL[1];
    urlParamsString = (NSString *)CFBridgingRelease(
                                                    CFURLCreateStringByAddingPercentEscapes(
                                                                                            NULL,
                                                                                            (CFStringRef)urlParamsString,
                                                                                            NULL,
                                                                                            (CFStringRef)@"!*'();/@+$,%#[]",
                                                                                            kCFStringEncodingUTF8
                                                                                            )
                                                    );
    url = [NSString stringWithFormat:@"%@?%@",splitedURL[0],urlParamsString];
    
    
    NSLog(@"getHTML -> '%@' ... ", url);
    //ライブラリでGet
    NSString *htmlString = [self sendGetRequest:url];
    
    return htmlString;
}





@end
