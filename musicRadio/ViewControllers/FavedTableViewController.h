//
//  FavedTableViewController.h
//  addCoreDataTest
//
//  Created by Takuya Okamoto on 2014/05/02.
//  Copyright (c) 2014年 Takuya Okamoto. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@interface FavedTableViewController : UITableViewController  <NSFetchedResultsControllerDelegate>


@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@end
