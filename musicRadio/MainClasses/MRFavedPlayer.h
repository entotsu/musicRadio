//
//  MRFavedPlayer.h
//  musicRadio
//
//  Created by Takuya Okamoto on 2014/05/04.
//  Copyright (c) 2014年 Takuya Okamoto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRRadio.h"
#import "XCDYouTubeVideoPlayerViewController.h"




@protocol MRFavedPlayerDelegate <MRRadioDelegate>
@end





@interface MRFavedPlayer : NSObject <XCDYouTubeVideoPlayerViewControllerDelegete>
-(id)initWithVideoIdentifier:(NSString*)videoIdentifier;
-(void)playNext;
-(void)playPrev;
@property (nonatomic, weak) UIViewController <MRRadioDelegate> *delegeteViewController;
@end
