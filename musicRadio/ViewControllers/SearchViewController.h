//
//  SearchViewController.h
//  musicRadio
//
//  Created by Takuya Okamoto on 2014/03/07.
//  Copyright (c) 2014年 Takuya Okamoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicPlayerViewController.h"

@interface SearchViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) MusicPlayerViewController* musicPlayerView;

@end
