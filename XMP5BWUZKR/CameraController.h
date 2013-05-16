//
//  CameraController.h
//  XMP5BWUZKR
//
//  Created by Medical Physics Lab on 5/14/13.
//  Copyright (c) 2013 Oklahoma State University Medical Physics Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CaptureSessionManager.h"

@interface CameraController : UIViewController

@property (retain) CaptureSessionManager *captureManager;
- (IBAction)captureImage:(id)sender;
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
- (IBAction)doneCamera:(id)sender;

@end
