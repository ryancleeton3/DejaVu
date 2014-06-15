//
//  DVNetworkQueue.m
//  DejaVu
//
//  Created by Ryan Cleeton on 6/14/14.
//  Copyright (c) 2014 Ryan Cleeton. All rights reserved.
//

#import "DVDejaVuServerClient.h"

#import "DVKalturaServerClient.h"

#import <Facebook-iOS-SDK/FacebookSDK/Facebook.h>

static NSString * const kDejaVuAPIKey = @"";
static NSString * const kDejaVuBaseURLString = @"http://104.130.3.99:80";

@interface DVDejaVuServerClient ()

@end

@implementation DVDejaVuServerClient

+ (DVDejaVuServerClient *)sharedClient
{
    static DVDejaVuServerClient* _sharedClient;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kDejaVuBaseURLString]];
    });
    
    return _sharedClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    return self;
}

- (void)retreiveObjectsWithTags:(NSArray *)tags ofType:(NSString *)type
{
    NSDictionary* parameters = @{@"tags": tags};
    
    [self GET:type parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([self.delegate respondsToSelector:@selector(dVSClient:didUpdateWithObject:)]) {
            [self.delegate dVSClient:self didUpdateWithObject:responseObject];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(dVSClient:didFailWithError:)]) {
            [self.delegate dVSClient:self didFailWithError:error];
        }
    }];
}

- (void)uploadObjectWithID:(NSString *)identifier withType:(NSString *)type
{
    NSDictionary* parameters = @{@"id" : identifier,
                                 @"access_token" : [[[FBSession activeSession] accessTokenData] accessToken]};
    
    [self POST:type parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([self.delegate respondsToSelector:@selector(dVSClient:successfullyUploadedObject:)]) {
            [self.delegate dVSClient:self successfullyUploadedObject:responseObject];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(dVSClient:didFailWithError:)]) {
            [self.delegate dVSClient:self didFailWithError:error];
        }
    }];
}

@end
