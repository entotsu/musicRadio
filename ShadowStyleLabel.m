//
//  ShadowStyleLabel.m
//  musicRadio
//
//  Created by Takuya Okamoto on 2014/03/11.
//  Copyright (c) 2014年 Takuya Okamoto. All rights reserved.
//

#import "ShadowStyleLabel.h"


@implementation ShadowStyleLabel

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetShadow(context, CGSizeMake(4.0f, -4.0f), 6.0f);
    [super drawRect:rect];
    CGContextRestoreGState(context);
}

@end