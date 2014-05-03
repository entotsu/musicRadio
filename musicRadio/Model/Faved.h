//
//  Faved.h
//  musicRadio
//
//  Created by Takuya Okamoto on 2014/05/02.
//  Copyright (c) 2014年 Takuya Okamoto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Faved : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * artist;
@property (nonatomic, retain) NSString * videoId;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSData * artwork;
@property (nonatomic, retain) NSString * artworkUrl;
@property (nonatomic, retain) NSData * cache;
@property (nonatomic, retain) NSDate * date;

@end
