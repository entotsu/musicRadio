//
//  MRRadio.h
//  musicRadio
//
//  Created by Takuya Okamoto on 2014/01/30.
//  Copyright (c) 2014年 Takuya Okamoto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRPlaylistManager.h"
#import "XCDYouTubeVideoPlayerViewController.h"




@class MRRadio;


@protocol MRRadioDelegate <NSObject>
@property (nonatomic, strong) UIView* youtubeBox;
@property (nonatomic, strong) UIButton* nextButton;
@property (nonatomic, strong) UILabel* nowPlayingLabel;
- (void) displayLyric:(NSString*)lyric;
- (void) displayBio:(NSString*)bio;
@end


@protocol MRRadioStartViewDelegate <NSObject>
- (void) didSuccessPlayArtistFirstTrack;
- (void) canStartFirstTrack;
@end








@interface MRRadio : NSObject <MRPlaylistGeneratorDelegate, XCDYouTubeVideoPlayerViewControllerDelegete>

- (void) fastArtistRandomPlay: (NSString*)artistName;

-(NSArray*) searchSongWithArtistName:(NSString*) keyword;

-(int) playArtistTopMusicRandomly:(NSString*) artistName;

-(void) generatePlaylistByArtistName:(NSString*)artistName;

-(int) startPlayRadio;
- (void) startPlaybackNextVideo;

-(int) getCurrentTrack;

-(void) onCreatedPlaylist;

-(int) togglePlayAndPause;
-(void) prepareNextTrack;
-(int) playPrevious;


-(int) loveCurrentTrack;
-(int) addLocalPlaylistThisTrack;


-(int) resetPlaylist;
-(NSString*) getNowPlayingTitle;
//-(int) generatePlaylistWithThisTrack;


- (int) test_random_play;//test
- (void) setTestView :(id)view;//test

@property (nonatomic, strong) XCDYouTubeVideoPlayerViewController *youtubePlayer;
@property (nonatomic, strong) XCDYouTubeVideoPlayerViewController *nextYoutubePlayer;
@property (nonatomic, unsafe_unretained) UIViewController <MRRadioDelegate> *delegeteViewController;
@property (nonatomic, unsafe_unretained) UIViewController <MRRadioStartViewDelegate> *delegeteStartViewController;

@end
