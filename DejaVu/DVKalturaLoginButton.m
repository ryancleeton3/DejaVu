//
//  DVKalturaLoginButton.m
//  DejaVu
//
//  Created by Ryan Cleeton on 6/14/14.
//  Copyright (c) 2014 Ryan Cleeton. All rights reserved.
//

#import "DVKalturaLoginButton.h"

@implementation DVKalturaLoginButton

- (id)init
{
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"KalturaLoginView" owner:self options:nil];
    UIView *mainView = [subviewArray objectAtIndex:0];
    
    self = [UIButton buttonWithType:UIButtonTypeCustom];
    if (self) {
        [self setFrame:mainView.frame];
        [self addSubview:mainView];
        
        [self.layer setCornerRadius:5.0f];
    }
    return self;
}

@end
