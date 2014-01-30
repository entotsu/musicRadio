//
//  MRMusicPlayer.h
//  musicRadio
//
//  Created by Takuya Okamoto on 2014/01/30.
//  Copyright (c) 2014年 Takuya Okamoto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface MRMusicPlayer : NSObject


-(int) setNowTrack: (NSString*)trackURL;
-(NSURL*) getNowTrack;

-(int) loveThisTrack;
-(int) commentTothisTrack;


-(NSURL*) goPreviousTrack;
-(NSURL*) goNextTrack;

- (int) playMusicWithURL:(NSString*)urlString;


@end
