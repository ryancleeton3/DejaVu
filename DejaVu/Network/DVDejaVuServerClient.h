//
//  DVNetworkQueue.h
//  DejaVu
//
//  Created by Ryan Cleeton on 6/14/14.
//  Copyright (c) 2014 Ryan Cleeton. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AFNetworking/AFNetworking.h>

@protocol DVDejaVuServerClientDelegate;

@interface DVDejaVuServerClient : AFHTTPSessionManager

@property (nonatomic) id<DVDejaVuServerClientDelegate> delegate;

+ (DVDejaVuServerClient *)sharedClient;

- (instancetype)initWithBaseURL:(NSURL *)url;
- (void)retreiveObjectsWithTags:(NSArray *)tags ofType:(NSString *)type;
- (void)uploadObjectWithID:(NSString *)identifier withType:(NSString *)type;
@end

@protocol DVDejaVuServerClientDelegate <NSObject>

- (void)dVSClient:(DVDejaVuServerClient *)client didUpdateWithObject:(id)object;
- (void)dVSClient:(DVDejaVuServerClient *)client successfullyUploadedObject:(id)object;
- (void)dVSClient:(DVDejaVuServerClient *)client didFailWithError:(NSError *)error;



@end
