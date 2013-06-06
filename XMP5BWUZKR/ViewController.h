//
//  ViewController.h
//  XMP5BWUZKR
//
//  Created by Medical Physics Lab on 4/16/13.
//  Copyright (c) 2013 Oklahoma State University Medical Physics Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController <UIPopoverControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)amountSliderValueChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UISlider *amountSlider;
- (IBAction)loadPhoto:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *ipadloadPhotoOutlet;
- (IBAction)savePhoto:(id)sender;
@property (strong, nonatomic) UIPopoverController *popoverController;
- (IBAction)takePicture:(id)sender;
- (IBAction)getPixelInfo:(id)sender;
- (IBAction)getThatArea:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *pointLabel;
- (IBAction)resetImage:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *saveLabel;
- (IBAction)newData:(id)sender;
- (IBAction)emailData:(id)sender;
- (IBAction)closeFile:(id)sender;
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)updateimage;
- (void)updateRect;
- (IBAction)setCalibration:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *doseLabel;
- (IBAction)getDose:(id)sender;



@end