//
//  DVResultsViewController.h
//  DejaVu
//
//  Created by Ryan Cleeton on 6/14/14.
//  Copyright (c) 2014 Ryan Cleeton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DVResultsViewController : UICollectionViewController

@property (nonatomic) NSArray* results;
@property (nonatomic) NSMutableArray* searchTags;

@end
