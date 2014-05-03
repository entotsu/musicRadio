//
//  FavedCell.m
//  addCoreDataTest
//
//  Created by Takuya Okamoto on 2014/05/02.
//  Copyright (c) 2014年 Takuya Okamoto. All rights reserved.
//

#import "FavedCell.h"

@implementation FavedCell

@synthesize titleLabel = _titleLabel;
@synthesize artistLabel = _artistLabel;
@synthesize artworkView = _artworkView;


static const double padding = 10;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {

        //ドキュメントによると、self.contentViewに追加するのが正しいとコメントいただきました。
        //http://qiita.com/edo_m18/items/68cea6ab32de22153de6
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding*2 + 100, padding, 240, 40)];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _titleLabel.font = [UIFont systemFontOfSize:17];
        _titleLabel.numberOfLines = 1;
        [self.contentView addSubview:_titleLabel];
        
        
        _artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding + 200, padding, 240, 40)];
        _artistLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _artistLabel.font = [UIFont systemFontOfSize:12];
        _artistLabel.numberOfLines = 1;
        [self.contentView addSubview:_artistLabel];
    
        _artworkView = [[UIImageView alloc] init];
        _artworkView.frame = CGRectMake(padding, padding, 100, 100);
        _artworkView.backgroundColor = [[UIColor brownColor] colorWithAlphaComponent:0.3];
        [self.contentView addSubview:_artworkView];
        
    }
    
    return self;
}




- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
