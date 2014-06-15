//
//  DVResultsViewController.m
//  DejaVu
//
//  Created by Ryan Cleeton on 6/14/14.
//  Copyright (c) 2014 Ryan Cleeton. All rights reserved.
//

#import "DVResultsViewController.h"

#import "KalturaClient/KalturaClient/KalturaClient.h"

#import "DVDejaVuServerClient.h"

#import "DVMoviePlayerViewController.h"

#import <Facebook-iOS-SDK/FacebookSDK/Facebook.h>

#import "DVKalturaServerClient.h"

#import "DVTagView.h"

#import "DVVideoPickerViewController.h"

@interface DVResultsViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate>

@property (nonatomic) UIButton* addSearchTagButton;
@property (nonatomic) UITextField* textField;
@property (nonatomic) MPMoviePlayerController* moviePlayerViewController;
@property (nonatomic) KalturaMediaEntry* currentlySelectedEntry;
@property (nonatomic) UIToolbar* toolbar;

@end

@implementation DVResultsViewController

- (id)init
{
    self = [super initWithCollectionViewLayout:[self flowLayout]];
    if (self) {
        _results = [NSMutableArray arrayWithArray:[[DVKalturaServerClient sharedClient] fetchMediaWithCategory:nil]];
        _searchTags = [NSMutableArray new];
        _addSearchTagButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        _addSearchTagButton.frame = CGRectMake(280, 20, 30, 30);
        _addSearchTagButton.layer.cornerRadius = 30.0f;
        [_addSearchTagButton setTintColor:[UIColor whiteColor]];
        _addSearchTagButton.backgroundColor = [UIColor orangeColor];
        [_addSearchTagButton addTarget:self action:@selector(addSearchTerm) forControlEvents:UIControlEventTouchUpInside];
        
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 280, 44)];
        CALayer *bottomBorder = [CALayer layer];
        bottomBorder.frame = CGRectMake(0.0f, 43.0f, _textField.frame.size.width, 1.0f);
        bottomBorder.backgroundColor = [UIColor orangeColor].CGColor;
        [_textField.layer addSublayer:bottomBorder];
        [_textField setTintColor:[UIColor orangeColor]];
        _textField.delegate = self;
        [_textField setTextColor:[UIColor whiteColor]];
        _textField.hidden = YES;
    }
    return self;
}

- (void)addSearchTerm
{
    _textField.hidden = NO;
    CGRect frame = self.collectionView.frame;
    
    [_textField setCenter:CGPointMake(self.view.center.x, self.addSearchTagButton.center.y + 30)];
    [_textField becomeFirstResponder];
    
    frame.origin.y = _textField.frame.origin.y + _textField.frame.size.height;
    [self.collectionView setFrame:frame];
    
}

- (void)createSearchTagWithName:(NSString *)name
{
    CGFloat originX = 10;
    CGFloat originY = 10 + (self.searchTags.count * 35);
    
    DVTagView* tagView = [[DVTagView alloc] initWithFrame:CGRectMake(originX, originY, 0, 0)];
    tagView.text = name;
    [self.searchTags addObject:tagView];
    [self.view addSubview:tagView];
    
    [tagView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteSelf:)]];
    
    [self updateMedia];
}


- (void)deleteSelf:(UITapGestureRecognizer *)sender
{
    [self.searchTags removeObject:sender.view];
    
    NSInteger index = [self.view.subviews indexOfObject:sender.view];
    if (index != NSNotFound) {
        [[self.view.subviews objectAtIndex:index] removeFromSuperview];
    }
    
    [self updateMedia];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateTags];
    [self.view addSubview:_addSearchTagButton];
    [self.view addSubview:_textField];
}

- (void)updateTags
{
    NSArray* searchTagButtons = [NSArray arrayWithArray:self.searchTags];
    __block NSMutableArray* stringTitles = [NSMutableArray array];
    [searchTagButtons enumerateObjectsUsingBlock:^(UIView* obj, NSUInteger idx, BOOL *stop) {
        NSString* title = [(DVTagView *)self.searchTags[idx] text];
        [stringTitles addObject:title];
    }];
    
    self.searchTags = [NSMutableArray array];
    
    [stringTitles enumerateObjectsUsingBlock:^(NSString* obj, NSUInteger idx, BOOL *stop) {
        [self createSearchTagWithName:obj];
    }];

    [self updateMedia];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    CGRect frame = [[UIScreen mainScreen] bounds];

    if (self.searchTags.count == 0) {
        frame.origin.y = 66;
        frame.size.height -= 110;
    } else {
        frame.origin.y = 100;
        frame.size.height -= 144;
    }

    [self.collectionView setFrame:frame];
    [self.collectionView setBackgroundColor:[UIColor lightGrayColor]];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    self.collectionView.delegate = self;

    UIBarButtonItem* uploadVideoItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(uploadVideo)];
//    UIBarButtonItem* shareItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareVideo:)];

    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIImageView* toolbarLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"small-dejavu-logo"]];
    [toolbarLogo setFrame:CGRectMake(0, 0, 80, 30)];
    
    UIBarButtonItem* logoItem = [[UIBarButtonItem alloc] initWithCustomView:toolbarLogo];

    CGRect toolbarFrame = CGRectMake(0, 0, 320, 44);
    toolbarFrame.origin.y = [[UIScreen mainScreen] bounds].size.height - 44;
    _toolbar =[[UIToolbar alloc] initWithFrame:toolbarFrame];
    [_toolbar setItems:[NSArray arrayWithObjects:logoItem, flexibleSpace, uploadVideoItem, nil]];
    _toolbar.opaque = NO;
    [_toolbar setTranslucent:YES];
    _toolbar.barTintColor = [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:210.0/255.0f alpha:1.0f];
    [self.view addSubview:_toolbar];

    [[UIBarButtonItem appearance] setTintColor:[UIColor orangeColor]];
    
    [self reloadView];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    KalturaMediaEntry* mediaEntry = [self.results objectAtIndex:indexPath.row];
    
    UIImage* image = [UIImage imageWithData:[self getThumb:mediaEntry]];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setFrame:cell.bounds];
    cell.backgroundColor = [UIColor blueColor];
    [cell addSubview:imageView];
    
    
    UIView* timeBackground = [[UIView alloc] initWithFrame:CGRectMake(0, cell.bounds.size.height-20, cell.bounds.size.width, 20)];
    timeBackground.backgroundColor = [UIColor darkGrayColor];
    timeBackground.alpha = 0.7f;
    [cell addSubview:timeBackground];
    
    UILabel* createdDateLabel = [UILabel new];
    [createdDateLabel setFrame:CGRectMake(3, cell.bounds.size.height-20, cell.bounds.size.width/2, 20)];
    createdDateLabel.textColor = [UIColor whiteColor];

    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    NSString* dateString = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:mediaEntry.createdAt]];
    createdDateLabel.text = [NSString stringWithFormat:@"%@", dateString];
    [createdDateLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [cell addSubview:createdDateLabel];
    
    UILabel* durationLabel = [UILabel new];
    durationLabel.frame = CGRectMake(cell.bounds.size.width/2, cell.bounds.size.height-20, cell.bounds.size.width/2-3, 20);
    [durationLabel setTextAlignment:NSTextAlignmentRight];
    durationLabel.textColor = [UIColor whiteColor];
    
    int minutes = mediaEntry.duration / 60;
    int seconds = mediaEntry.duration % 60;
    
    [durationLabel setText:[NSString stringWithFormat:@"%02d:%02d", minutes, seconds]];
    [durationLabel setFont:[UIFont systemFontOfSize:12.0f]];
    
    
    [cell addSubview:durationLabel];
    
    return cell;
}




- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.results.count;
}

- (NSData *)getThumb:(KalturaMediaEntry *)mediaEntry {
    
    NSString *thumbPath = [self getThumbPath:mediaEntry.id];
    if (![[NSFileManager defaultManager] fileExistsAtPath:thumbPath]) {
        
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:mediaEntry.thumbnailUrl]];
        [data writeToFile:thumbPath atomically:NO];
        
        return data;
    }
    
    return [NSData dataWithContentsOfFile:thumbPath];
}

- (NSString *)getThumbPath:(NSString *)fileName {
    
    NSError *error;
    
	NSString *thumbPath = [self getDocPath:@"Thumbs"];
	if (![[NSFileManager defaultManager] fileExistsAtPath:thumbPath])
		[[NSFileManager defaultManager] createDirectoryAtPath:thumbPath withIntermediateDirectories:NO attributes:nil error:&error]; //
    
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
	NSString *docsDir = [paths objectAtIndex:0];
	docsDir = [docsDir stringByAppendingFormat:@"/Thumbs"];
	
	return [docsDir stringByAppendingPathComponent:fileName];
}

- (NSString *)getDocPath:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
	NSString *docsDir = [paths objectAtIndex:0];
	
    [docsDir stringByAppendingPathComponent:fileName];
    
    return docsDir;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];

    self.currentlySelectedEntry = [self.results objectAtIndex:indexPath.row];
    
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"What would you like to do with this video" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Play", @"Share", nil];
    
    actionSheet.tag = 12;
    
    [actionSheet showInView:self.collectionView];
}


- (UICollectionViewFlowLayout *)flowLayout
{
    UICollectionViewFlowLayout* flowLayout = [UICollectionViewFlowLayout new];
    flowLayout.minimumInteritemSpacing = 5.0f;
    flowLayout.minimumLineSpacing = 5.0f;
    flowLayout.itemSize = CGSizeMake(151.0f, 104.0f);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
    return flowLayout;
}



- (void)uploadVideo
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose or take a video to upload" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Pick from Library", @"Take a video", nil];
    [actionSheet showInView:self.collectionView];
}

- (void)shareVideo:(KalturaMediaEntry *)barButtonItem
{
    NSString* identifier = barButtonItem.id;
    
    UIActivityViewController* controller = [[UIActivityViewController alloc] initWithActivityItems:@[identifier] applicationActivities:nil];
    [self presentViewController:controller animated:YES completion:nil];

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag ==12) {
        switch (buttonIndex) {
            case 0: {
                KalturaMediaEntry* entry = self.currentlySelectedEntry;
                [self startPlayingVideo:entry];
            }
                break;
            case 1:
                
                [self shareVideo:self.currentlySelectedEntry];
                
                break;
            default:
                break;
        }
    } else {
        switch (buttonIndex) {
            case 0:
                [self actionPick:nil];
                break;
            case 1:
                [self actionRecord:nil];
                break;
            default:
                break;
        }
    }
}



- (IBAction)actionRecord:(UIButton *)button {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
	{
        UIImagePickerController *videoRecorder = [[UIImagePickerController alloc] init];
        videoRecorder.sourceType = UIImagePickerControllerSourceTypeCamera;
        videoRecorder.delegate = self;
        
        NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        NSArray *videoMediaTypesOnly = [mediaTypes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(SELF contains %@)", @"movie"]];
        
        if ([videoMediaTypesOnly count] == 0)		//Is movie output possible?
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Sorry but your device does not support video recording"
                                                                     delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:nil];
            [actionSheet showInView:[[self view] window]];
        }
        else
        {
            //Select front facing camera if possible
            if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront])
                videoRecorder.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            
            videoRecorder.mediaTypes = videoMediaTypesOnly;
            videoRecorder.videoQuality = UIImagePickerControllerQualityTypeMedium;
            videoRecorder.videoMaximumDuration = 180;			//Specify in seconds (600 is default)
            
            [self presentViewController:videoRecorder animated:YES completion:nil];
        }
    }
}

- (IBAction)actionPick:(UIButton *)button {
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    imagePicker.allowsEditing = NO;
    imagePicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSURL *url =  [info objectForKey:UIImagePickerControllerMediaURL];
    
    [self performSelector:@selector(operateVideo:) withObject:url afterDelay:0.5];
}

- (void)operateVideo:(NSURL *)url {
    
    NSString* uploadFilePath = [url path];
    
    NSString* labelCategoryName = @"";
    NSString* textVTitle = @"";
    NSString* textDescription = @"";
    NSString* textTags = @"";
    
    NSDictionary* data = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:labelCategoryName,
                                                              textVTitle,
                                                              textDescription,
                                                              textTags, uploadFilePath, nil]
                          
                                                     forKeys:[NSArray arrayWithObjects:@"category", @"title", @"description", @"tags", @"path", nil]];
    
    [[DVKalturaServerClient sharedClient] uploadProcess:data withDelegate:self];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateMedia
{
    
    if (self.searchTags.count == 0) {
        self.results = [[DVKalturaServerClient sharedClient] fetchMediaWithCategory:nil];
    } else {
        
    __block NSMutableArray* sortedResults = [NSMutableArray array];
        [sortedResults removeAllObjects];
        
        __block NSMutableArray* tempArray = [NSMutableArray array];
    [self.searchTags enumerateObjectsUsingBlock:^(DVTagView* obj, NSUInteger idx, BOOL *stop) {

    
        NSString* filter = [NSString stringWithString:obj.text];
        BOOL isNotEmpty = (filter != nil && ![filter isEqualToString:@""]);
        NSString *pattern = (isNotEmpty ? [NSString stringWithFormat:@"(%@)+|(\\s%@)+", filter, filter] : @".*");

        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
        
        [self.results enumerateObjectsUsingBlock:^(KalturaMediaEntry *obj, NSUInteger idx, BOOL *stop) {
            if([regex numberOfMatchesInString:obj.name options:NSMatchingReportCompletion range:[obj.name rangeOfString:obj.name]]) {
                if (![sortedResults containsObject:obj]) {
                    [sortedResults addObject:obj];
                }
            } else {
                if ([sortedResults containsObject:obj]) {
                    [sortedResults removeObject:obj];
                }
            }
        }];
        }];

//        [self.results enumerateObjectsUsingBlock:^(KalturaMediaEntry* entry, NSUInteger idx, BOOL *stop) {
//            [self.searchTags enumerateObjectsUsingBlock:^(DVTagView* tag, NSUInteger idx, BOOL *stop) {
//                NSString* filter = [NSString stringWithString:tag.text];
//                BOOL isNotEmpty = (filter != nil && ![filter isEqualToString:@""]);
//                NSString *pattern = (isNotEmpty ? [NSString stringWithFormat:@"(%@)+|(\\s%@)+", filter, filter] : @".*");
//                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
//                if ([regex numberOfMatchesInString:entry.name options:NSMatchingReportCompletion range:[entry.name rangeOfString:entry.name]]) {
//                    [tempArray addObject:entry];
//                }
//            }];
//            
//            [sortedResults addObject:tempArray];
//        }];
//        
//        __block NSMutableArray* theResults = [NSMutableArray array];
//        theResults = [NSMutableArray arrayWithArray:[sortedResults firstObject]];
//        [sortedResults enumerateObjectsUsingBlock:^(NSArray* obj, NSUInteger idx, BOOL *stop) {
//            
//        }];
        
    self.results = [NSArray arrayWithArray:sortedResults];
        
    }
    [self reloadView];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length > 0) {
        [self createSearchTagWithName:textField.text];
        textField.text = @"";
    }
    
    [textField resignFirstResponder];
    _textField.hidden = YES;
    [self updateMedia];
    return YES;
}


- (void)startPlayingVideo:(KalturaMediaEntry *)video
{
    NSString* flavorId = @"wv";
    int partnerId = [[DVKalturaServerClient sharedClient] partnerID];
    NSString* urlString = [NSString stringWithFormat:@"http://cdnapi.kaltura.com/p/%d/sp/%d00/playManifest/entryId/%@/flavorIds/%@/format/applehttp/protocol/http/a.mp4", partnerId, partnerId, video.id, flavorId];
    
    if (self.moviePlayerViewController != nil) {
        [self stopPlayingVideo:nil];
    }
    
    self.moviePlayerViewController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:urlString]];
    
    if (self.moviePlayerViewController != nil) {
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(videoHasFinishedPlaying:)
         name:MPMoviePlayerPlaybackStateDidChangeNotification
         object:self.moviePlayerViewController];
        
        self.moviePlayerViewController.scalingMode = MPMovieScalingModeAspectFit;
        
        [self.view addSubview:self.moviePlayerViewController.view];
        [self.moviePlayerViewController prepareToPlay];
        [self.moviePlayerViewController setFullscreen:YES animated:NO];
        [self.moviePlayerViewController play];
    }
}

- (void)stopPlayingVideo:(id)paramSender
{
    
    if (self.moviePlayerViewController != nil){
        
        [[NSNotificationCenter defaultCenter]
         removeObserver:self
         name:MPMoviePlayerPlaybackDidFinishNotification
         object:self.moviePlayerViewController];
        
        [self.moviePlayerViewController stop];
    }
    
}

- (void)videoHasFinishedPlaying:(NSNotification *)paramNotification
{
    
    /* Find out what the reason was for the player to stop */
    NSNumber *reason =
    paramNotification.userInfo
    [MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    
    if (reason != nil){
        NSInteger reasonAsInteger = [reason integerValue];
        
        switch (reasonAsInteger){
            case MPMovieFinishReasonPlaybackEnded:{
                /* The movie ended normally */
                break;
            }
            case MPMovieFinishReasonPlaybackError:{
                /* An error happened and the movie ended */
                break;
            }
            case MPMovieFinishReasonUserExited:{
                /* The user exited the player */
                break;
            }
        }
        
        NSLog(@"Finish Reason = %ld", (long)reasonAsInteger);
        [self stopPlayingVideo:nil];
    }
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

- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)reloadView
{
    
    __block CGRect frame = self.collectionView.frame;
    
    [UIView animateWithDuration:0.3 animations:^{
        if ([self lowestTagYOrigin] > 0) {
            frame.origin.y = [self lowestTagYOrigin] + 40;
        } else {
            frame.origin.y = 40;
        }
        frame.size.height = self.view.bounds.size.height - frame.origin.y - self.toolbar.frame.size.height;

        [self.collectionView setFrame:frame];
    }];
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect searchFrame = self.addSearchTagButton.frame;
        searchFrame.origin.y = self.collectionView.frame.origin.y - 35;
        [self.addSearchTagButton setFrame:searchFrame];
    }];
    
    CGPoint center = self.textField.center;
    center.y = self.addSearchTagButton.center.y;
    self.textField.center = center;
    
    [self.collectionView reloadData];
}

- (CGFloat)lowestTagYOrigin
{
    __block DVTagView* lowestSoFar = nil;
    [self.searchTags enumerateObjectsUsingBlock:^(DVTagView* obj, NSUInteger idx, BOOL *stop) {
        if (lowestSoFar.frame.origin.y < obj.frame.origin.y) {
            lowestSoFar = obj;
        }
    }];
    
    return lowestSoFar.frame.origin.y;
}

@end
