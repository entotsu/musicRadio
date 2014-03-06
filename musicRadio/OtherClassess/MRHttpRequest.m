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
    
    NSArray *splitedURL = [url componentsSeparatedByString:@"?"];
    NSString *urlParamsString = splitedURL[1];
    //パラメータ部だけエンコード (スラッシュもエンコードするため)
    urlParamsString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
            NULL, (CFStringRef)urlParamsString, NULL, (CFStringRef)@"!*'();/@+$,%#[]", kCFStringEncodingUTF8));
    url = [NSString stringWithFormat:@"%@?%@",splitedURL[0],urlParamsString];
    
    NSLog(@"getJSON -> '%@' ... ", url);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSData *json_data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    if (json_data) {
        NSError *error = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:json_data options:kNilOptions error:&error];
        
        if( error ) {
            NSLog(@"http get json EROOR!");
            NSLog(@"%@",error);
        }
        return json;
    }
    else {
        NSLog(@"####################### request response is nil!! #############################");
        return nil;
    }
    
    
    
}







- (NSString *)sendGetRequest:(NSString *)url {
	NSURL *nsurl = [NSURL URLWithString:url];
	NSURLRequest *request = [NSURLRequest requestWithURL:nsurl];
	NSURLResponse *response = nil;
	NSError *error = nil;
	NSData *data = [
                    NSURLConnection
                    sendSynchronousRequest : request
                    returningResponse : &response
                    error : &error
                    ];
    
	// error
	NSString *errorStr = [error localizedDescription];
	if (0 < [errorStr length]) {
		return nil;
	}
    
	// response
	int encodeArray[] = {
		NSUTF8StringEncoding,			// UTF-8
		NSShiftJISStringEncoding,		// Shift_JIS
		NSJapaneseEUCStringEncoding,	// EUC-JP
		NSISO2022JPStringEncoding,		// JIS
		NSUnicodeStringEncoding,		// Unicode
		NSASCIIStringEncoding			// ASCII
	};
    
	NSString *dataString = nil;
	int max = sizeof(encodeArray) / sizeof(encodeArray[0]);
	for (int i=0; i<max; i++) {
		dataString = [
                      [NSString alloc]
                      initWithData : data
                      encoding : encodeArray[i]
                      ];
		if (dataString != nil) {
			break;
		}
	}
	return dataString;
}



@end
