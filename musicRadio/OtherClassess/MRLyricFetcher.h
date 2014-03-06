//
//  MRLyricFetcher.h
//  musicRadio
//
//  Created by Takuya Okamoto on 2014/02/24.
//  Copyright (c) 2014年 Takuya Okamoto. All rights reserved.
//

#import "MRHttpRequest.h"

@interface MRLyricFetcher : MRHttpRequest

-(NSString*) getLyricWithTitle:(NSString*)title andArtist:(NSString*)artistName;

@end
