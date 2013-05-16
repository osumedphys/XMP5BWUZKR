//
//  CameraController.m
//  XMP5BWUZKR
//
//  Created by Medical Physics Lab on 5/14/13.
//  Copyright (c) 2013 Oklahoma State University Medical Physics Lab. All rights reserved.
//

#import "CameraController.h"

@interface CameraController ()

@end

@implementation CameraController

@synthesize captureManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self setCaptureManager:[[[CaptureSessionManager alloc] init] autorelease]];
    
	[[self captureManager] addVideoInput];
    
	[[self captureManager] addVideoPreviewLayer];
	CGRect layerRect = [[[self view] layer] bounds];
	[[[self captureManager] previewLayer] setBounds:layerRect];
	[[[self captureManager] previewLayer] setPosition:CGPointMake(CGRectGetMidX(layerRect),
                                                                  CGRectGetMidY(layerRect))];
    
    [[[self view] layer] insertSublayer:[[self captureManager]previewLayer] atIndex:1];
    
    [[[self view]layer] insertSublayer:[[self captureManager]previewLayer] atIndex:0];
    
	[[captureManager captureSession] startRunning];
    
    [[self captureManager] addStillImageOutput];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveImageToPhotoAlbum) name:kImageCapturedSuccessfully object:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveImageToPhotoAlbum
{
    UIImageWriteToSavedPhotosAlbum([[self captureManager] stillImage], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error != NULL) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Image couldn't be saved" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        [alert release]; 
    }
    else {
        //[[self scanningLabel] setHidden:YES];
    }
}

- (IBAction)doneCamera:(id)sender {
    
}

- (IBAction)captureImage:(id)sender {
    [[self captureManager] captureStillImage];
}

@end
