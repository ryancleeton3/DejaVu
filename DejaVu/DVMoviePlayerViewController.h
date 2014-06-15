//
//  DVMoviePlayerViewController.h
//  DejaVu
//
//  Created by Ryan Cleeton on 6/14/14.
//  Copyright (c) 2014 Ryan Cleeton. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MediaPlayer/MediaPlayer.h>

#import "KalturaClient/KalturaClient/KalturaClient.h"

@interface DVMoviePlayerViewController : UIViewController

@property (nonatomic) UIButton* playButton;
@property (nonatomic) KalturaMediaEntry* mediaEntry;

- (void)startPlayingVideo:(id)video;

@end
