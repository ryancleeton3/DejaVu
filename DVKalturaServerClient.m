//
//  DVKalturaServerClient.m
//  DejaVu
//
//  Created by Ryan Cleeton on 6/14/14.
//  Copyright (c) 2014 Ryan Cleeton. All rights reserved.
//

#import "DVKalturaServerClient.h"

#import "DVDejaVuServerClient.h"

#import "DejaVu/KalturaClient/KalturaClient/KalturaClient.h"

static NSString * const kKalturaBaseURLString = @"http://www.kaltura.com";

@interface DVKalturaServerClient () <KalturaClientDelegate, ASIProgressDelegate>

@end

@implementation DVKalturaServerClient

+ (DVKalturaServerClient *)sharedClient
{
    static DVKalturaServerClient* _sharedClient;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[DVKalturaServerClient alloc] init];
    });
    
    return _sharedClient;
}

- (instancetype)init
{
    KalturaClientConfiguration* config = [KalturaClientConfiguration new];
    KalturaNSLogger* logger = [KalturaNSLogger new];
    config.logger = logger;
    config.serviceUrl = kKalturaBaseURLString;
    
    self.client = [[KalturaClient alloc] initWithConfig:config];
    
    KalturaUserService* service = [KalturaUserService new];
    service.client = self.client;
    
    NSString *userEmail = [[NSUserDefaults standardUserDefaults] objectForKey:@"userEmail"];
    NSString *userPassword = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPassword"];
    
    self.client.ks = [service loginByLoginIdWithLoginId:userEmail withPassword:userPassword];
    
    KalturaUserListResponse* response = [self.client.user list];
    
    for (KalturaUser* user in [response objects]) {
        self.partnerID = user.partnerId;
    }
    
    self.media = [NSMutableArray array];
    
    return self;
}

- (BOOL)login
{
    self.client = nil;
    
    KalturaClientConfiguration* config = [[KalturaClientConfiguration alloc] init];
    KalturaNSLogger* logger = [[KalturaNSLogger alloc] init];
    config.logger = logger;
    config.serviceUrl = kKalturaBaseURLString;
    
    self.client = [[KalturaClient alloc] initWithConfig:config];
    
    KalturaUserService *service = [[KalturaUserService alloc] init];
    service.client = self.client;
    
    
    NSString *userEmail = [[NSUserDefaults standardUserDefaults] objectForKey:@"userEmail"];
    NSString *userPassword = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPassword"];
    
    self.client.ks = [service loginByLoginIdWithLoginId:userEmail withPassword:userPassword];
    
    KalturaUserListResponse *response = [self.client.user list];
    
    for (KalturaUser *user in [response objects]) {
        self.partnerID = user.partnerId;
    }
        
    return ([self.client.ks length] > 0);
}

- (BOOL)isLoggedIn
{
    return ([self.client.ks length] > 0);
}

- (void)uploadProcess:(NSDictionary *)data withDelegate:(UIViewController *)delegateController {
    
//    uploadDelegateController = delegateController;
//    self.uploadFilePath = [data objectForKey:@"path"];
    
    self.client.delegate = nil;
    
    KalturaUploadToken* token = [[KalturaUploadToken alloc] init];
    token.fileName = @"video.m4v";
    token = [self.client.uploadToken addWithUploadToken:token];
    
    KalturaMediaEntry* entry = [[KalturaMediaEntry alloc] init];
    entry.name = [data objectForKey:@"title"];
    entry.mediaType = [KalturaMediaType VIDEO];
    entry.categories = [data objectForKey:@"category"];
    entry.description = [data objectForKey:@"description"];
    entry.tags = [data objectForKey:@"tags"];
    
    entry = [self.client.media addWithEntry:entry];
    
    KalturaUploadedFileTokenResource* resource = [[KalturaUploadedFileTokenResource alloc] init];
    resource.token = token.id;
    entry = [self.client.media addContentWithEntryId:entry.id withResource:resource];
    
    self.client.delegate = self;
    self.client.uploadProgressDelegate = self;
    
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[data objectForKey:@"path"] error:nil];
    
    NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
//    fileSize = [fileSizeNumber longLongValue];
//    uploadedSize = 0;
//    uploadTryCount = 0;
//    currentChunk = 0;
    
//    self.uploadFileTokenId = token.id;
    
    if ([fileSizeNumber longLongValue] < 1048576)
    {
        token = [self.client.uploadToken uploadWithUploadTokenId:token.id withFileData:[data objectForKey:@"path"]];
    }
    else
    {
        [self createBuffer:[data objectForKey:@"path"] offset:0];
        
        token = [self.client.uploadToken uploadWithUploadTokenId:token.id withFileData:[self getDocPath:@"buffer.tmp"] withResume:NO withFinalChunk:NO];
    }
    
    [[DVDejaVuServerClient sharedClient] uploadObjectWithID:entry.id withType:@"media/"];
}

- (NSString *)getDocPath:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
	NSString *docsDir = [paths objectAtIndex:0];
	
    [docsDir stringByAppendingPathComponent:fileName];
    
    return docsDir;
}

- (void)createBuffer:(NSString *)path offset:(long long)offset {
    
    [self deleteBufferFile];
    
    NSString *bufferPath = [self getDocPath:@"buffer.tmp"];
    
    NSFileHandle *fileHandleIn = [NSFileHandle fileHandleForReadingAtPath:path];
    [fileHandleIn seekToFileOffset:offset];
    
    NSData *data = [fileHandleIn readDataOfLength:1048576];
    
    [data writeToFile:bufferPath atomically:NO];
    [fileHandleIn closeFile];
}

- (void)deleteBufferFile {
    
    NSString *bufferPath = [self getDocPath:@"buffer.tmp"];
    
    NSFileManager *fManager = [NSFileManager defaultManager];
    if ([fManager fileExistsAtPath:bufferPath]) {
        NSError *error;
        [fManager removeItemAtPath:bufferPath error:&error];
    }
}

- (NSArray *)fetchMediaWithCategory:(KalturaCategory *)category
{
    if ([self.media count] == 0) {
        
        KalturaMediaEntryFilter *filter = [[KalturaMediaEntryFilter alloc] init];
        
        KalturaFilterPager *pager = [[KalturaFilterPager alloc] init];
        pager.pageSize = 0;
        
        KalturaMediaListResponse *response  = [self.client.media listWithFilter:filter withPager:pager];
        
        for (KalturaMediaEntry *mediaEntry in response.objects) {
            
            [self.media addObject:mediaEntry];
            
        }        
    }
    
    return self.media;
    
}

- (void)requestFailed:(KalturaClientBase *)aClient
{
    NSLog(@"failed kaltura %@", aClient.error.localizedDescription);
    [[[UIAlertView alloc] initWithTitle:@"Error" message:aClient.error.localizedDescription delegate:nil cancelButtonTitle:@"Dimiss" otherButtonTitles:nil] show];
}

- (void)requestFinished:(KalturaClientBase *)aClient withResult:(id)result
{
    NSLog(@"finished kaltura");
}

@end
