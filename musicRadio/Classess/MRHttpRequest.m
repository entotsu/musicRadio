//
//  MRHttpRequest.m
//  musicRadio
//
//  Created by Takuya Okamoto on 2014/01/31.
//  Copyright (c) 2014年 Takuya Okamoto. All rights reserved.
//

#import "MRHttpRequest.h"

@implementation MRHttpRequest





- (NSDictionary*) getJsonWithURLString:(NSString*)url {
    //encoding　エンコードしすぎてないか心配ｗ
    url = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                NULL, (CFStringRef)url, NULL, (CFStringRef)@"!*'();@+$,%#[]", kCFStringEncodingUTF8));
    
    NSLog(@"getJSON -> %@", url);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSData *json_data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:json_data options:kNilOptions error:&error];
    
    if( error ) {
        NSLog(@"http get json EROOR!");
        NSLog(@"%@",error);
    }
    
    return json;
}



@end
