//
//  DVResultsHeaderView.m
//  DejaVu
//
//  Created by Ryan Cleeton on 6/14/14.
//  Copyright (c) 2014 Ryan Cleeton. All rights reserved.
//

#import "DVResultsHeaderView.h"

@interface DVResultsHeaderView ()

@property (nonatomic) UILabel* countLabel;

@end

@implementation DVResultsHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 44)];
        [self addSubview:[self countLabel]];
    }
    return self;
}


- (void)setCountOfVideos:(NSString *)count
{
    self.countLabel.text = count;
}

@end
