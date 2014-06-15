//
//  DVVideoPickerViewController.m
//  DejaVu
//
//  Created by Ryan Cleeton on 6/14/14.
//  Copyright (c) 2014 Ryan Cleeton. All rights reserved.
//

#import "DVVideoPickerViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "DVKalturaServerClient.h"

@interface DVVideoPickerViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic) NSString* labelCategoryName;
@property (nonatomic) NSString* textVTitle;
@property (nonatomic) NSString* textDescription;
@property (nonatomic) NSString* textTags;



@end

@implementation DVVideoPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor purpleColor]];
    
    UIButton* pickVideoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [pickVideoButton setTitle:@"Take a video" forState:UIControlStateNormal];
    [pickVideoButton setFrame:CGRectMake(20, 100, 280, 44)];
    [pickVideoButton addTarget:self action:@selector(actionRecord:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pickVideoButton];
    
    UIButton* galleryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [galleryButton setTitle:@"Pick a video from library" forState:UIControlStateNormal];
    [galleryButton setFrame:CGRectMake(20, 200, 280, 44)];
    [galleryButton addTarget:self action:@selector(actionPick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:galleryButton];
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
    } else {
        
    }
    
}

- (IBAction)actionPick:(UIButton *)button {
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    imagePicker.allowsEditing = NO;
    imagePicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
    imagePicker.delegate = self;
    
    [self presentModalViewController:imagePicker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissModalViewControllerAnimated:YES];
    
    NSURL *url =  [info objectForKey:UIImagePickerControllerMediaURL];
    
    [self performSelector:@selector(operateVideo:) withObject:url afterDelay:0.5];
}

- (void)operateVideo:(NSURL *)url {
    
    NSString* uploadFilePath = [url path];
    
    self.labelCategoryName = @"";
    self.textVTitle = @"";
    self.textDescription = @"";
    self.textTags = @"";
    
    NSDictionary* data = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:self.labelCategoryName,
                                                              self.textVTitle,
                                                              self.textDescription,
                                                              self.textTags, uploadFilePath, nil]
                          
                                                     forKeys:[NSArray arrayWithObjects:@"category", @"title", @"description", @"tags", @"path", nil]];
    
    [[DVKalturaServerClient sharedClient] uploadProcess:data withDelegate:self];
    
//    UploadInfoViewController_iPhone *controller = [[UploadInfoViewController_iPhone alloc] initWithNibName:@"UploadInfoViewController_iPhone" bundle:nil];
//    controller.path = uploadFilePath;
//    [app.navigation pushViewController:controller animated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [self dismissModalViewControllerAnimated:YES];
    
}

@end
