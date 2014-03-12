//
//  SearchViewController.m
//  musicRadio
//
//  Created by Takuya Okamoto on 2014/03/07.
//  Copyright (c) 2014年 Takuya Okamoto. All rights reserved.
//

#import "SearchViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "FXBlurView.h"
#import "MRLastfmRequest.h"
#import "MusicPlayerViewController.h"

@implementation SearchViewController {
    MRLastfmRequest *_lastfmRequest;
    UIApplication *_application;
    
    NSArray *_resultViews;
    
    UITextField *_searchBar;
    BOOL _isReloading;
    BOOL _isNotFirstType;
    NSString *_searchedArtist;
    NSString *_searchedWord;
}
@synthesize musicPlayerView;


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self layoutSubViews];
    
    _lastfmRequest = [[MRLastfmRequest alloc] init];
    
    _application = [UIApplication sharedApplication];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark UITextFieldDelegate

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *nextString;
    if ([string isEqualToString:@""]) { //バックスペースのときは末尾を削除
        nextString = [textField.text substringToIndex:[textField.text length]-1];
    } else {
        nextString = [NSString stringWithFormat:@"%@%@", textField.text, string];
    }
    NSLog(@"textField changed : %@",nextString);

    //最初の数秒は検索しない
    if (!_isNotFirstType) {
        _isReloading = YES;
        _isNotFirstType = YES;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            sleep(1.5);
            _isReloading = NO;
        });
    }
    else {
        [self searchAndUpdateResult:nextString];
    }
    
    return YES;
}



#pragma mark Private Method (Search Artist)


- (void) searchAndUpdateResult: (NSString*) artistName {
    //検索中じゃない場合のみ検索
    if (!_isReloading) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            _isReloading = YES;
            _searchedWord = artistName;
            
            //数秒たったら再検索OKにして検索ワードをチェックする
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                sleep(2);
                _isReloading = NO;
                [self checkSearchedWordAndRedoSearch];
            });
            
            //検索
            _application.networkActivityIndicatorVisible = YES;
            NSArray *resultArtists = [_lastfmRequest searchArtistByLastfmWithArtistName:artistName];
            _application.networkActivityIndicatorVisible = NO;
            
            //検索結果のチェック
            if (!resultArtists) {
                NSLog(@"network error"); //Tweetbot みたいなアラートを表示する
                _isReloading = NO;
            }
            else if ([resultArtists count] == 0) {
                NSLog(@"artist count is 0!");
                _isReloading = NO;
            }
            else {  //もし結果に問題がなければ表示
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self refreshArtistResultViewsWithArray:resultArtists index:0];
                    NSLog(@"result: %@",resultArtists);
                    //更新後に以前検索したワードと一致してなかったら検索する。
                    [self checkSearchedWordAndRedoSearch];
                });
            }
            
        });
    }
}



- (void) checkSearchedWordAndRedoSearch {
    if (![_searchBar.text isEqualToString:_searchedWord]) {
        NSLog(@"REDO RESEARCH*********");
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self searchAndUpdateResult: _searchBar.text];
        });
    }
}


#pragma mark Action Method


- (void) onTapResultView:(UIGestureRecognizer*)sender {
    UIView *resultView = (UIView*)sender.view;
    UILabel *nameLabel = resultView.subviews[1];
    NSString *artistName = nameLabel.text;
    
    if (![artistName isEqualToString:@""]) {
        self.musicPlayerView = [[MusicPlayerViewController alloc] init];
        [self.musicPlayerView setSeedArtist:artistName];
        self.musicPlayerView.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:self.musicPlayerView animated:YES completion:nil];
    }
}

- (void) onTapBackButton {
    NSLog(@"on tap back button");
    if (self.musicPlayerView) {
        [self presentViewController:self.musicPlayerView animated:YES completion:nil];
    }
}




#pragma mark Private Method (View Control)

- (void) layoutSubViews {
    float maxW = self.view.frame.size.width;
    float maxH = self.view.frame.size.height;
    const CGFloat statusBar_and_nav_H = 20+44;

    // ※ MはMarginの略
    float textField_H = 40;
    float textField_M = 40;
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CRSTL_BG"]];
    backgroundImage.frame = CGRectMake(0, 0, maxW, maxH);
    backgroundImage.backgroundColor = [UIColor colorWithRed:0.465117 green:0.792544 blue:1.0 alpha:1.0];
    [self.view addSubview:backgroundImage];
    FXBlurView *blurBG = [[FXBlurView alloc] initWithFrame:backgroundImage.frame];
    [self.view addSubview:blurBG];

    UIToolbar *navigationBar = [[UIToolbar alloc] init];
    navigationBar.frame = CGRectMake(0, 0, maxW, statusBar_and_nav_H);
    navigationBar.barStyle = UIBarStyleBlack;
    //    navigationBar.barTintColor = [[UIColor clearColor] colorWithAlphaComponent:0.01];
    [self.view addSubview:navigationBar];
    UILabel *navigationBarLabel = [[UILabel alloc] init];
    navigationBarLabel.frame = CGRectMake(0, 0, maxW-100, statusBar_and_nav_H);
    navigationBarLabel.center = CGPointMake(maxW/2, statusBar_and_nav_H/2);
    [navigationBarLabel setTextColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5]];
    [navigationBarLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:18.0f]];
    [navigationBarLabel setTextAlignment:NSTextAlignmentCenter];
    navigationBarLabel.adjustsFontSizeToFitWidth = YES;
    navigationBarLabel.adjustsLetterSpacingToFitWidth = YES;
    [self setKernedText:@"artist walk" toUILabel:navigationBarLabel];
    [navigationBar addSubview:navigationBarLabel];
    UIButton *backButton = [[UIButton alloc] init];
    backButton.frame = CGRectMake(0, 0, 40, 40);
    backButton.center = CGPointMake(maxW - statusBar_and_nav_H/2, statusBar_and_nav_H/2);
    backButton.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.2];
    [backButton addTarget:self action:@selector(onTapBackButton) forControlEvents:UIControlEventTouchUpInside];
    [navigationBar addSubview:backButton];

    
    _searchBar = [[UITextField alloc] init];
    _searchBar.frame = CGRectMake(0, 0, maxW-textField_M * 2, textField_H);
    _searchBar.center = CGPointMake(maxW/2, maxH/2);
    _searchBar.placeholder = @"Search Artist";
    _searchBar.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    _searchBar.delegate = self;
    _searchBar.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:_searchBar];
    //TODO 左にアイコン表示
    
    //下線
    UIView *underLineView = [[UIView alloc] init];
    underLineView.frame = CGRectMake(0, 0, _searchBar.frame.size.width, 1);
    underLineView.center = CGPointMake(_searchBar.center.x, _searchBar.center.y + textField_H/2);
    underLineView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    [self.view addSubview:underLineView];
 
    
    float result1_size = 70;
    float result2_size = result1_size/1.25;
    //リザルトの数で座標を計算でだすようにする。
    UIView *resultView1 = [self makeResultViewWithSize:result1_size andCenter:CGPointMake(130, 195) isMain:YES];
    UIView *resultView2 = [self makeResultViewWithSize:result2_size andCenter:CGPointMake(55, 110) isMain:NO];
    UIView *resultView3 = [self makeResultViewWithSize:result2_size andCenter:CGPointMake(220, 110) isMain:NO];
    UIView *resultView4 = [self makeResultViewWithSize:result2_size andCenter:CGPointMake(250, 215) isMain:NO];
    [self.view addSubview:resultView1];
    [self.view addSubview:resultView2];
    [self.view addSubview:resultView3];
    [self.view addSubview:resultView4];
    
    _resultViews = @[resultView1, resultView2, resultView3, resultView4];
}


- (UIView*) makeResultViewWithSize:(float)size andCenter:(CGPoint)center isMain:(BOOL)isMain {
    float result1_size = size;
    float result1_label_M = result1_size/20;
    
    float result1_label_H;
    if (isMain)
        result1_label_H = result1_size/4;
    else
        result1_label_H = result1_size/2.5;
    
    float result1_label_W = result1_size*1.75;
    
    float result1_fontSize;
    if (isMain)
        result1_fontSize = 16.0;
    else
        result1_fontSize = 12;
    
    //とりあえずは場所固定の検索結果でいこう
    UIView *resultView1 = [[UIView alloc] init];
    resultView1.frame = CGRectMake(0, 0, result1_size, result1_size);
    resultView1.center = center;
    resultView1.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.0];
    //タッチイベントの追加
    resultView1.userInteractionEnabled = YES;
    [resultView1 addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapResultView:)]];
    
    UIImageView *imageView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"test_image_androp"]];
    imageView1.frame = CGRectMake(0, 0, result1_size, result1_size);
    imageView1.clipsToBounds = YES;
    imageView1.layer.cornerRadius = result1_size/2;
    [resultView1 addSubview:imageView1];
    
    UILabel *_titleLabel1 = [[UILabel alloc] init];
    _titleLabel1.frame = CGRectMake(0, 0, result1_label_W, result1_label_H);
    _titleLabel1.center = CGPointMake(result1_size/2, result1_size + result1_label_M + result1_label_H/2);
    _titleLabel1.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.0];
    _titleLabel1.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:result1_fontSize];
    _titleLabel1.textAlignment = NSTextAlignmentCenter;
    _titleLabel1.adjustsFontSizeToFitWidth = YES;
    _titleLabel1.adjustsLetterSpacingToFitWidth = YES;
    [self setKernedText:@"androp" toUILabel:_titleLabel1];
    [resultView1 addSubview:_titleLabel1];
    
    return resultView1;
}



//結果の配列を受け取って表示を更新する
- (void) refreshArtistResultViewsWithArray:(NSArray*)results index:(int)index{
    
    __block int i = index;
    
    int resultLength = (int)[results count];
    
    NSDictionary *artist = results[i];
    NSString *artistName = artist[@"name"];
    NSString *imageURL = artist[@"image"][1][@"#text"];
    
    UIView *resultView = _resultViews[i];
    UIImageView *imageView = resultView.subviews[0];
    UILabel *nameLabel = resultView.subviews[1];

    //もし名前が違えば内容を更新する
    if (! [nameLabel.text isEqualToString:artistName]) {
        resultView.alpha = 0;
        
        [self setKernedText:artistName toUILabel:nameLabel];
        imageView.image = [UIImage imageNamed:@"music2_400"];
        
        //画像URLからイメージを取得
        if ([imageURL isEqualToString:@""]) {
            NSLog(@"image is nothing!");
        }else {
            NSLog(@"image URL : %@",imageURL);
            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
            imageView.image = [UIImage imageWithData:imgData];
        }
        
        //アニメーション
        [UIView animateWithDuration:1.0f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             resultView.alpha = 1.0f;
                         }
                         completion:^(BOOL finished) {
                         }];
    }
    
    //次のviewを更新する。
    [NSTimer scheduledTimerWithTimeInterval:0.25f target:[NSBlockOperation blockOperationWithBlock:^{
        i++;
        if (i < resultLength && i < 4) [self refreshArtistResultViewsWithArray:results index:i];
    }] selector:@selector(main) userInfo:nil repeats:NO];

}





//カーニングしたテキストをラベルに設定する
- (void) setKernedText:(NSString*)text toUILabel:(UILabel*)label{
    CGFloat customLetterSpacing = 6.0f;
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedText addAttribute:NSKernAttributeName
                           value:[NSNumber numberWithFloat:customLetterSpacing]
                           range:NSMakeRange(0, attributedText.length)];
    [label setAttributedText:attributedText];
}



@end
