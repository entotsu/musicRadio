//
//  StartingRadioViewController.h
//  musicRadio
//
//  Created by Takuya Okamoto on 2014/02/26.
//  Copyright (c) 2014年 Takuya Okamoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRRadio.h"

@interface StartingRadioViewController : UIViewController <MRRadioStartViewDelegate>

- (id) initWithArtistName:(NSString*)artistName;

@end
