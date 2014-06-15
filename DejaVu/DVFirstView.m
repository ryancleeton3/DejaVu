//
//  DVFirstView.m
//  DejaVu
//
//  Created by Ryan Cleeton on 6/14/14.
//  Copyright (c) 2014 Ryan Cleeton. All rights reserved.
//

#import "DVFirstView.h"

#import <Facebook-iOS-SDK/FacebookSDK/Facebook.h>

#import "DVDejaVuServerClient.h"
#import "DVKalturaServerClient.h"

@interface DVFirstView () <UIAlertViewDelegate, FBLoginViewDelegate>

@end

@implementation DVFirstView

- (id)init
{
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"DVFirstView" owner:self options:nil];
    UIView *mainView = [subviewArray objectAtIndex:0];
    
    self = [super initWithFrame:mainView.bounds];
    if (self) {
        [self addSubview:mainView];
    }
    return self;
}





@end
