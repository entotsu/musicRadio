//
//  MRRadio.h
//  musicRadio
//
//  Created by Takuya Okamoto on 2014/01/30.
//  Copyright (c) 2014年 Takuya Okamoto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XCDYouTubeVideoPlayerViewController.h"

#import <CoreData/CoreData.h>

#import "AppDelegate.h"

@class MRRadio;


@protocol MRRadioDelegate <NSObject>
@property (nonatomic, strong) UIView* youtubeBox;
@property (nonatomic, strong) UIView* nextYoutubeBox;
@property (nonatomic, strong) UIButton* nextButton;
@property (nonatomic, strong) UIButton* pauseButton;
//@property (nonatomic, strong) UILabel* nowPlayingLabel;
@property (nonatomic, strong) UILabel* artistNameLabel;
@property (nonatomic, strong) UILabel* trackNameLabel;
@property (nonatomic, strong) UIImageView* artworkView;
- (void) displayLyric:(NSString*)lyric;
- (void) displayBio:(NSString*)bio;
- (void) onPlayTrack;
@end


@protocol MRRadioStartViewDelegate <NSObject>
- (void) didSuccessPlayArtistFirstTrack;
- (void) canStartFirstTrack;
@end








@interface MRRadio : NSObject <XCDYouTubeVideoPlayerViewControllerDelegete>

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

- (BOOL) checkAlreadyExsistingFavedWithVideoId:(NSString *)videoId;
- (BOOL) addFaved;

@property (nonatomic, strong) XCDYouTubeVideoPlayerViewController *youtubePlayer;
@property (nonatomic, strong) XCDYouTubeVideoPlayerViewController *nextYoutubePlayer;
@property (nonatomic, weak) UIViewController <MRRadioDelegate> *delegeteViewController;
@property (nonatomic, weak) UIViewController <MRRadioStartViewDelegate> *delegeteStartViewController;


//CoreData
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@end
