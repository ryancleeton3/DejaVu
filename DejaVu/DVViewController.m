//
//  DVViewController.m
//  DejaVu
//
//  Created by Ryan Cleeton on 6/13/14.
//  Copyright (c) 2014 Ryan Cleeton. All rights reserved.
//

#import "DVViewController.h"

#import "DVResultsViewController.h"
#import "DVDejaVuServerClient.h"


#import "DVFirstView.h"

#import "DVLoginButton.h"
#import "DVKalturaLoginButton.h"
#import "DVTagView.h"

#import "DVKalturaServerClient.h"
#import <AFNetworking/AFNetworking.h>
#import "KalturaClient/KalturaClient/KalturaClient.h"
#import <Facebook-iOS-SDK/FacebookSDK/Facebook.h>

#define kSERVICE_URL (@"http://www.kaltura.com")
#define kADMIN_SECRET (@"4183bb5939a426cc31856acabab7bcb3")
#define kPARTNER_ID (1761331)
#define kUSER_ID (@"testUser")
#define kENTRY_ID (@"1_ziiv6fa7")

@interface DVViewController () <FBLoginViewDelegate, UIAlertViewDelegate, UITextFieldDelegate>

@property (nonatomic) NSMutableArray* searchTags;

@end

@implementation DVViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchTags = [NSMutableArray array];

    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dejavu-backgroun"]];
    [imageView setFrame:self.view.bounds];
    [self.view addSubview:imageView];
    
    DVFirstView* view = [DVFirstView new];
    [view setCenter:CGPointMake(self.view.center.x, 230)];
    [self.view addSubview:view];
    
    if ([self areBothLoggedIn]) {
        [[DVDejaVuServerClient sharedClient] uploadObjectWithID:@"" withType:@"fb_profile/"];

        [self presentSearchBar];
    } else {
        [self addFacebookLogin];
        [self addKalturaLogin];
    }
}

- (void)addFacebookLogin
{
    FBLoginView* loginView = [FBLoginView new];
    loginView.delegate = self;
    loginView.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    [loginView setCenter:CGPointMake(160, 280)];
    [self.view addSubview:loginView];
}

- (void)addKalturaLogin
{
    UIButton* loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginButton setFrame:CGRectMake(52, 310, 216, 44)];
    [loginButton setTitle:@"Log in to Kaltura" forState:UIControlStateNormal];
    [loginButton setBackgroundColor:[UIColor redColor]];
    [loginButton addTarget:self action:@selector(presentKalturaLoginAlert) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:loginButton];
    
//    UIButton* kalturaLogin = [DVKalturaLoginButton new];
//    [kalturaLogin setCenter:CGPointMake(160, 345)];
//    [kalturaLogin addTarget:self action:@selector(presentKalturaLoginAlert) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:kalturaLogin];
//    
    
}

- (void)presentKalturaLoginAlert
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Kaltura" message:@"Please log in to Kaltura" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Log in", nil];
    alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            break;
        case 1: {
            NSString* userName = [alertView textFieldAtIndex:0].text;
            NSString* password = [alertView textFieldAtIndex:1].text;
            
            [self loginWithName:userName password:password];
            
            break;
        }
        default:
            break;
    }
}

- (IBAction)loginWithName:(NSString *)name password:(NSString *)password
{
    
    if ([name length] > 0 && [password length] > 0) {
        
        [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"userEmail"];
        [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"userPassword"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if ([[DVKalturaServerClient sharedClient] login]) {
            [self checkIfBothFacebookAndKalturaLoggedIn];
        } else {
            
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userEmail"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userPassword"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incorrect user name or password" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
    }
    
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error
{
    [[[UIAlertView alloc] initWithTitle:@"Facebook Failed" message:[NSString stringWithFormat: @"Failed to sign in to facebook with error: %@", error.localizedDescription] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
}

-(void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
    [self checkIfBothFacebookAndKalturaLoggedIn];
}

-(void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {}
-(void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    [[[UIAlertView alloc] initWithTitle:@"Facebook" message:@"You have successfully logged out of Facebook." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
}


- (void)pushToResultsViewController
{
    DVResultsViewController* resultsController = [DVResultsViewController new];
    
    if (self.searchTags.count > 0) {
        resultsController.searchTags = self.searchTags;
    }
    
    [resultsController.view setBackgroundColor:[UIColor lightGrayColor]];
    
    [UIView animateWithDuration:1.0
                     animations:^{
                         self.view.alpha = 0.5;
                         [self presentViewController:resultsController animated:YES completion:nil];
                     } completion:^(BOOL finished) {
                         self.view.alpha = 0.0;
                     }];
    
}

- (BOOL)areBothLoggedIn
{
    return (([FBSession activeSession].state == FBSessionStateOpen || [FBSession activeSession].state == FBSessionStateOpenTokenExtended || [FBSession activeSession].state == FBSessionStateCreated || [FBSession activeSession].state == FBSessionStateCreatedOpening || [FBSession activeSession].state == FBSessionStateCreatedTokenLoaded || [FBSession activeSession].state == FBSessionStateOpenTokenExtended) && [[DVKalturaServerClient sharedClient] isLoggedIn]);
}

- (void)checkIfBothFacebookAndKalturaLoggedIn
{
    if ([self areBothLoggedIn]) {
        [[DVDejaVuServerClient sharedClient] uploadObjectWithID:@"" withType:@"fb_profile/"];
        
        [self removeSignInButtons];
    }
}

- (void)removeSignInButtons
{
    __block NSMutableArray* indexes = [NSMutableArray array];
    [self.view.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIButton class]] || [obj isKindOfClass:[FBLoginView class]]) {
            [indexes addObject:obj];
        }
    }];
    
    NSArray* array = [NSArray arrayWithArray:indexes];

    
    [UIView animateWithDuration:0.5 animations:^{
        for (int i = 0; i < array.count; i++) {
            [(UIView *)array[i] setAlpha:0.8];
        }
    } completion:^(BOOL finished) {
        if (finished) {
            for (int i = 0; i < array.count; i++) {
                [(UIView *)array[i] setAlpha:0.0];
                [array[i] removeFromSuperview];

                [self presentSearchBar];
            }
        }
    }];
    

}

- (void)presentSearchBar
{
    UIButton* searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [searchButton setFrame:CGRectMake(200, 375, 100, 44)];
    [searchButton setBackgroundColor:[UIColor orangeColor]];
    [searchButton setTitle:@"SEARCH" forState:UIControlStateNormal];
    [searchButton.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
    [searchButton addTarget:self action:@selector(pushToResultsViewController) forControlEvents:UIControlEventTouchUpInside];
    [searchButton.layer setCornerRadius:5.0f];
    searchButton.alpha = 0.0;
    
    [self.view addSubview:searchButton];
    
    UITextField* textField = [[UITextField alloc] initWithFrame:CGRectMake(20, self.view.center.y, 280, 44)];
    CALayer *bottomBorder = [CALayer layer];
    textField.alpha = 0.0;
    bottomBorder.frame = CGRectMake(0.0f, 43.0f, textField.frame.size.width, 1.0f);
    bottomBorder.backgroundColor = [UIColor orangeColor].CGColor;
    [textField.layer addSublayer:bottomBorder];
    [textField setTintColor:[UIColor orangeColor]];
    textField.delegate = self;
    [textField setTextColor:[UIColor whiteColor]];
    
    [self.view addSubview:textField];
    
    [UIView animateWithDuration:0.15
                     animations:^{
                         searchButton.alpha = 0.3;
                         textField.alpha = 0.3;
                     } completion:^(BOOL finished) {
//                         searchButton.alpha = 1;
//                         textField.alpha = 1;
                         
                         [UIView animateWithDuration:0.15
                                          animations:^{
                                              searchButton.alpha = 0.7;
                                              textField.alpha = 0.7;
                                          } completion:^(BOOL finished) {
                                              searchButton.alpha = 1;
                                              textField.alpha = 1;
                                          }];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length > 0) {
        [self createSearchTagWithName:textField.text];
        textField.text = @"";
    }
    
    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@""]) {
        return YES;
    }
    
    if (textField.text.length > 25) {
        return NO;
    }
    
    return YES;
}


- (void)createSearchTagWithName:(NSString *)name
{
    CGFloat originX = 10;
    CGFloat originY = 200 + (self.searchTags.count * 35);
    
    DVTagView* tagView = [[DVTagView alloc] initWithFrame:CGRectMake(originX, originY, 0, 0)];
    tagView.text = name;
    [self.searchTags addObject:tagView];
    [self.view addSubview:tagView];
    
    [tagView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteSelf:)]];

}

- (void)deleteSelf:(UITapGestureRecognizer *)sender
{
    [sender.view removeFromSuperview];
    [self.searchTags removeObject:sender.view];
}


























- (void)sampleWithEntryID:(NSString *)entryID
{
    KalturaClientConfiguration* config = [KalturaClientConfiguration new];
    config.serviceUrl = kSERVICE_URL;
    config.logger = [KalturaNSLogger new];
    config.partnerId = kPARTNER_ID;
    
    KalturaClient* client = [[KalturaClient alloc] initWithConfig:config];
    client.ks = [KalturaClient generateSessionWithSecret:kADMIN_SECRET withUserId:kUSER_ID withType:[KalturaSessionType ADMIN] withPartnerId:kPARTNER_ID withExpiry:86400 withPrivileges:@""];
    
    KalturaMediaEntry* mediaEntry = [client.media getWithEntryId:entryID];
    if (client.error != nil) {
        NSLog(@"Failed to get entry, domain=%@ code=%ld", client.error.domain, (long)client.error.code);
    } else {
        [self performSelector:@selector(pushToResultsViewController) withObject:@[mediaEntry] afterDelay:0.0];
    }
}

@end
