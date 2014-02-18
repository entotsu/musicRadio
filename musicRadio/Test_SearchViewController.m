//
//  Test_SearchViewController.m
//  musicRadio
//
//  Created by Takuya Okamoto on 2014/02/13.
//  Copyright (c) 2014年 Takuya Okamoto. All rights reserved.
//

#import "Test_SearchViewController.h"
#import "MusicPlayerViewController.h"
#import "MRLastfmRequest.h"


@interface Test_SearchViewController ()
@end






@implementation Test_SearchViewController {
    UITextField *_textField;
    UILabel *_infoLabel;
    UITableView *_tableView;
    UIActivityIndicatorView *_indicator;
    
    NSString *_searchedArtist;
    MRLastfmRequest *_lastfmRequest;
    NSArray *_tableViewSource;
    BOOL _isReloading;
    NSString *_searchedWord;
}



//------------LifeCycle-------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initView];

    _lastfmRequest = [[MRLastfmRequest alloc] init];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}





//----------privateMethod-----------

- (void) initView {
    
    float statusBar_H = 20;
    float maxW = self.view.frame.size.width;
    float maxH = self.view.frame.size.height;
    
    float textField_H = 40;
    float indicator_WH = textField_H;
    
    _textField = [[UITextField alloc] init];
    _textField.frame = CGRectMake(0, statusBar_H, maxW, textField_H);
    _textField.borderStyle = UITextBorderStyleNone;
    _textField.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.2];
    _textField.delegate = self;
    [self.view addSubview:_textField];
    
    
    _tableView = [[UITableView alloc] init];
    _tableView.frame = CGRectMake(0, statusBar_H + textField_H, maxW, maxH-statusBar_H-textField_H);
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    
    _indicator = [[UIActivityIndicatorView alloc]init];
    _indicator.frame = CGRectMake(maxW-indicator_WH, statusBar_H, indicator_WH, indicator_WH);
    _indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.view addSubview:_indicator];
}




- (void) displayArists {
    //もし検索中だったら検索しない。
    if (!_isReloading) {
        [_indicator startAnimating];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            _isReloading = YES;
            sleep(0.4);
            [_indicator startAnimating];
            NSString *artistName = _textField.text;
            _searchedWord = [artistName copy];
            //テーブルの更新
            [self searchAndReloadTable:artistName];
        });
    }
}

- (void) searchAndReloadTable:(NSString*)artistName {
    _tableViewSource = [_lastfmRequest searchArtistByLastfmWithArtistName:artistName];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_indicator.isAnimating) [_indicator stopAnimating];
        [_tableView reloadData];
        //テーブル更新後に以前検索したワードと一致してなかったら検索する。
        [self checkSearchedWord];
    });
}

- (void) checkSearchedWord {
    if (![_textField.text isEqualToString:_searchedWord]) {
        NSLog(@"RESEARCH*********");
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            sleep(1);
            [self displayArists];
        });
    }
}


// ------------ <UITextFieldDelegate> -------------

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"shouldChangeCharactersInRange string: %@",string);
    
    [self displayArists];
    
    return YES;
}




// ------------ <UITableViewDataSource> -------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([_tableViewSource count] > 0) {
        NSLog(@"_tableSource count is %lu",(unsigned long)[_tableViewSource count]);
        return (NSInteger)[_tableViewSource count];
    }
    else {
        NSLog(@"_tableSource count is 0!");
        _isReloading = NO;
        return 0;
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"cellForRowAtIndexPath %ld",(long)indexPath.row);
    
    static NSString *CellIdentifier = @"ArtistCell";//再利用のID。これで量産される。
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        //ここにセルのカスタマイズをかく
    }
    
    
    NSDictionary *artist;
    NSString *artistName;
    NSString *artistImageURL;
    
    if (([_tableViewSource count]-1) >= indexPath.row ) {
        artist = _tableViewSource[indexPath.row];
//        if ([artist.allKeys containsObject:@"name"])
        artistName = artist[@"name"];
        artistImageURL = artist[@"image"][0][@"#text"];
    }
    cell.textLabel.text = artistName;

    cell.imageView.image = [UIImage imageNamed:@"empty34"];
    
    
    //画像URLからUIImageを生成 //ここひとつのスレッドにするべきだな。
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if ([artistImageURL isEqualToString:@""]) {
            NSLog(@"image is nothing!");
        }else {
            NSLog(@"image URL : %@",artistImageURL);
            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:artistImageURL]];
            UIImage *artistImage = [UIImage imageWithData:imgData];
            cell.imageView.image = artistImage;
        }
    });
     
    
    _isReloading = NO;
    return cell;
}






// ------------ <UITableViewDelegate> -------------

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        return 60.0;  // １番目のセクションの行の高さを30にする
    }else{
        return 60.0;  // それ以外の行の高さを50にする
    }
}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath");
    
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
    NSString *artistName = cell.textLabel.text;
    
    NSLog(@"artist Name is :%@",artistName);
    //空じゃなければ
    if (![artistName isEqualToString:@""]) {
        MusicPlayerViewController *musicView = [[MusicPlayerViewController alloc] init];
        musicView.artistName = artistName;
        [self presentViewController:musicView animated:YES completion:nil];
    }
}


@end
