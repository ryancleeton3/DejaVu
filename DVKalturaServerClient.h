//
//  DVKalturaServerClient.h
//  DejaVu
//
//  Created by Ryan Cleeton on 6/14/14.
//  Copyright (c) 2014 Ryan Cleeton. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DejaVu/KalturaClient/KalturaClient/KalturaClient.h"


@interface DVKalturaServerClient : NSObject

@property (nonatomic) KalturaClient* client;

@property (nonatomic) int partnerID;

@property (nonatomic, getter = isLoggedIn) BOOL loggedIn;

@property (nonatomic) NSMutableArray* media;

+ (DVKalturaServerClient *)sharedClient;

- (BOOL)login;
- (void)uploadProcess:(NSDictionary *)data withDelegate:(UIViewController *)delegateController;
- (NSArray *)fetchMediaWithCategory:(KalturaCategory *)category;
//- (BOOL)loginWithEmail:(NSString *)email password:(NSString *)password;


@end
