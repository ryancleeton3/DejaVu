//
//  DVAppDelegate.m
//  DejaVu
//
//  Created by Ryan Cleeton on 6/13/14.
//  Copyright (c) 2014 Ryan Cleeton. All rights reserved.
//

#import "DVAppDelegate.h"

#import <AFNetworking/AFNetworkActivityIndicatorManager.h>

#import <AFNetworking/AFNetworking.h>

#import <Facebook-iOS-SDK/FacebookSDK/Facebook.h>

#import "DVViewController.h"

#import "DVResultsViewController.h"

@implementation DVAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [DVViewController new];
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL handled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    return handled;
}



















- (void)firstTest
{
    NSString* url = @"http://10.99.0.94:8080";
    NSURL* realURL = [NSURL URLWithString:url];
    NSURLRequest* request = [NSURLRequest requestWithURL:realURL];
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"finished: %@", NSStringFromClass([responseObject class]));
        NSLog(@"%@", responseObject);
        id object = responseObject[@"medias"];
        NSLog(@"object: %@", object);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failed: %@", error.localizedDescription);
    }];
    
    [operation start];
    
    
//    AFHTTPSessionManager* manager = [[AFHTTPSessionManager alloc] initWithBaseURL:realURL];
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//    [manager GET:@"medias" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//        NSLog(@"success");
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        NSLog(@"failed: %@", error.localizedDescription);
//    }];
    
}


@end
