//
//  MRYoutubeRequest.h
//  musicRadio
//
//  Created by Takuya Okamoto on 2014/02/12.
//  Copyright (c) 2014年 Takuya Okamoto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRHttpRequest.h"

@interface MRYoutubeRequest :MRHttpRequest

- (NSDictionary*) searchByKeyword: (NSString *)keyword;
- (NSDictionary *) getTopVideoByKeyword: (NSString *)keyword;
- (NSString *) getRandomVideoIDByKeyword: (NSString *)keyword;
@end
