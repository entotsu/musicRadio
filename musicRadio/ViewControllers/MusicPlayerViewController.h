//
//  TestplayViewController2.h
//  musicRadio
//
//  Created by Takuya Okamoto on 2014/02/12.
//  Copyright (c) 2014年 Takuya Okamoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRRadio.h"

@interface MusicPlayerViewController : UIViewController <MRRadioDelegate>

- (void) getArtistInfoWithName;

@property (nonatomic,strong) UIView* youtubeBox;
@property (nonatomic,strong) UIView* nextYoutubeBox;
@property (nonatomic,strong) UIButton* nextButton;
@property (nonatomic, strong) UILabel* nowPlayingLabel;
@property (nonatomic, strong) NSString* seedArtist;
@property (nonatomic, strong) MRRadio* appRadio;
@property (nonatomic, strong) UIButton* pauseButton;

@end
