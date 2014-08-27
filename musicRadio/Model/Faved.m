//
//  Faved.m
//  musicRadio
//
//  Created by Takuya Okamoto on 2014/05/02.
//  Copyright (c) 2014年 Takuya Okamoto. All rights reserved.
//

#import "Faved.h"


@implementation Faved

@dynamic title;
@dynamic artist;
@dynamic videoId;
@dynamic id;
@dynamic duration;
@dynamic artwork;
@dynamic artworkUrl;
@dynamic cache;
@dynamic date;



//これでデフォで現在時刻がはいる
//http://d.hatena.ne.jp/KishikawaKatsumi/20120426/1335460134
- (void)awakeFromInsert {
    [super awakeFromInsert];
    self.date = [NSDate date];
}


@end
