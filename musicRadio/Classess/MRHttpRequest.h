//
//  MRHttpRequest.h
//  musicRadio
//
//  Created by Takuya Okamoto on 2014/01/31.
//  Copyright (c) 2014年 Takuya Okamoto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRHttpRequest : NSObject

- (NSDictionary*) getJsonWithURLString:(NSString*)url;

@end
