//
//  Test_SearchViewController.m
//  musicRadio
//
//  Created by Takuya Okamoto on 2014/02/13.
//  Copyright (c) 2014年 Takuya Okamoto. All rights reserved.
//

#import "Test_SearchViewController.h"
#import "StartingRadioViewController.h"
#import "MRLastfmRequest.h"
#import "FXBlurView.h"
#import <QuartzCore/QuartzCore.h>


@interface Test_SearchViewController ()
@end






@implementation Test_SearchViewController {
    UITextField *_textField;
    UILabel *_infoLabel;
    UITableView *_tableView;
    UIActivityIndicatorView *_indicator;
    UISearchBar *_searchBar;
    
    NSString *_searchedArtist;
    NSString *_searchedWord;
    MRLastfmRequest *_lastfmRequest;
    NSArray *_tableViewSource;
    BOOL _isReloading;
    
    BOOL _isNotFirstType;
    
    UIApplication *_application;
}



//------------LifeCycle-------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initView];
    
    _lastfmRequest = [[MRLastfmRequest alloc] init];
    
    _application = [UIApplication sharedApplication];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}





//----------privateMethod-----------

- (void) initView {
    
    float statusBar_andNav_H = 20+44;
    float maxW = self.view.frame.size.width;
    float maxH = self.view.frame.size.height;
    
    float textField_H = 40;
    float indicator_WH = textField_H;
    
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CRSTL_BG"]];
    backgroundImage.frame = CGRectMake(0, 0, maxW, maxH);
    backgroundImage.backgroundColor = [UIColor colorWithRed:0.465117 green:0.792544 blue:1.0 alpha:1.0];
    [self.view addSubview:backgroundImage];
    
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.frame = CGRectMake(0, statusBar_andNav_H, maxW, textField_H);
    _searchBar.delegate = self;
    _searchBar.showsCancelButton = YES;
//    _searchBar.prompt = @"タイトル";
    _searchBar.placeholder = @"アーティストを検索";
    _searchBar.keyboardType = UIKeyboardTypeDefault;
    _searchBar.barStyle = UIBarStyleDefault;
    _searchBar.tintColor = [UIColor blackColor];
    [[[_searchBar subviews] objectAtIndex:0] setAlpha:0.87];
    _tableView.tableHeaderView = _searchBar;
    [self.view addSubview:_searchBar];
    
    _tableView = [[UITableView alloc] init];
    _tableView.frame = CGRectMake(0, statusBar_andNav_H + textField_H, maxW, maxH-statusBar_andNav_H-textField_H);
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];

//    _indicator = [[UIActivityIndicatorView alloc]init];
//    _indicator.frame = CGRectMake(maxW-indicator_WH, statusBar_H, indicator_WH, indicator_WH);
//    _indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
//    [self.view addSubview:_indicator];
    
    //きいてない
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.1];
}







- (void) displayArists: (NSString*) artistName {
    //もし検索中だったら検索しない。
    if (!_isReloading) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            _isReloading = YES;
            _searchedWord = _searchBar.text;
            [self searchAndReloadTable:artistName];
        });
    }
}


- (void) searchAndReloadTable:(NSString*)artistName {
    
    //数秒たったら再検索OKにして検索ワードをチェックする
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        sleep(2);
        _isReloading = NO;
        [self checkSearchedWord];
    });
    
    _application.networkActivityIndicatorVisible = YES;
    _tableViewSource = [_lastfmRequest searchArtistByLastfmWithArtistName:artistName];
    _application.networkActivityIndicatorVisible = NO;
    
    if (_tableViewSource) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
            //テーブル更新後に以前検索したワードと一致してなかったら検索する。
            [self checkSearchedWord];
        });
    } else {
        NSLog(@"network error"); //Tweetbot みたいなアラートを表示する
        _isReloading = NO;

    }
    
}


- (void) checkSearchedWord {
    if (![_searchBar.text isEqualToString:_searchedWord]) {
        NSLog(@"RESEARCH*********");
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self displayArists: _searchBar.text];
        });
    }
}



// ------------ <UISearchBarDelegate> -------------
-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)searchText
{
    NSLog(@"searchbar text did change");
    if (_isNotFirstType) {
        [self displayArists:searchText];
    }
    //最初の数秒は検索しない
    else {
        _isReloading = YES;
        _isNotFirstType = YES;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            sleep(1.5);
            _isReloading = NO;
        });
    }
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
        cell.backgroundColor = [UIColor clearColor];

//        FXBlurView *cellBlurBG = [[FXBlurView alloc] init];
//        cellBlurBG.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
//        cellBlurBG.blurRadius = 10;
//        cellBlurBG.backgroundColor = [UIColor clearColor];
//        cell.backgroundView = cellBlurBG;

        UIToolbar *translucentView = [[UIToolbar alloc] initWithFrame:CGRectZero];
        translucentView.tintColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.1];
        translucentView.alpha = 0.8f;
        cell.backgroundView = translucentView;
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if ([artistImageURL isEqualToString:@""]) {
            NSLog(@"image is nothing!");
        }else {
            NSLog(@"image URL : %@",artistImageURL);
//            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:artistImageURL]];
//            UIImage *artistImage = [UIImage imageWithData:imgData];
//            cell.imageView.image = artistImage;
        }
    });
     
    
    _isReloading = NO;
    return cell;
}






// ------------ <UITableViewDelegate> -------------

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0) {
        return 60.0;  // １番目のセクションの行の高さを30にする
    } else {
        return 40.0;  // それ以外の行の高さを50にする
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
        StartingRadioViewController *startView = [[StartingRadioViewController alloc] initWithArtistName:artistName];
        [self.navigationController pushViewController:startView animated:YES];
//        MusicPlayerViewController *musicView = [[MusicPlayerViewController alloc] init];
//        [musicView setSeedArtist:artistName];
//        [self.navigationController pushViewController:musicView animated:YES];
    }
}


@end
