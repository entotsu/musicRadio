//
//  MRMusicPlayer.m
//  musicRadio
//
//  Created by Takuya Okamoto on 2014/01/30.
//  Copyright (c) 2014年 Takuya Okamoto. All rights reserved.
//

#import "MRMusicPlayer.h"

@implementation MRMusicPlayer {
    AVAudioPlayer *_audioPlayer;
}



- (int) setNowTrack: (NSString*)trackURL {

    return [self playMusicWithURL:trackURL];
}


-(NSURL*) getNowTrack {
    return [[NSURL alloc] init];
}

-(int) loveThisTrack {
    return 0;
}

-(int) commentTothisTrack {
    return 0;
}


-(NSURL*) goPreviousTrack {
    return [[NSURL alloc] init];

}


-(NSURL*) goNextTrack {
    return [[NSURL alloc] init];

}







- (int) playMusicWithURL: (NSString*) urlString {
    
    NSError *error;
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    _audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
    //    AVAudioPlayer *_audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    
    if (data == nil) {
        NSLog(@"data: %@",data);
        NSLog(@"data is nil!!  URL not Found!!!");
        return 1;
    }
    
    if( error ) {
        NSLog(@"%@", error);
        return 2;
    }
    
    //    AVAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    //    NSArray *metadata = [asset commonMetadata];
    
    //    for ( AVMetadataItem *item in metadata ) {
    //        if( [[item commonKey] isEqualToString:@"title"] ){
    //            _currentPlayingTitle = [item stringValue];
    //        }
    //        if( [[item commonKey] isEqualToString:@"artist"] ){
    //            _currentPlayingArtist = [item stringValue];
    //        }
    //        if ([[item commonKey] isEqualToString:@"artwork"]) {
    //            UIImage *img = nil;
    //            if ([item.keySpace isEqualToString:AVMetadataKeySpaceiTunes]) {
    //                img = [UIImage imageWithData:[item.value copyWithZone:nil]];
    //            }
    //            else { // if ([item.keySpace isEqualToString:AVMetadataKeySpaceID3]) {
    //                NSData *data = [(NSDictionary *)[item value] objectForKey:@"data"];
    //                img = [UIImage imageWithData:data]  ;
    //            }
    //            _currentPlayingArtwork = img;
    //        }
    //    }
    
    
    BOOL prepareResult = [_audioPlayer prepareToPlay];
    NSLog(@"prepareToPlay result: %hhd",prepareResult);
    
    BOOL playResult = [_audioPlayer play];
    NSLog(@"play result: %hhd",playResult);
    
    return 0;
}














@end
