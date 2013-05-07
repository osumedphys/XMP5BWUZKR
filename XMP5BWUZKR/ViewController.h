//
//  ViewController.h
//  XMP5BWUZKR
//
//  Created by Medical Physics Lab on 4/16/13.
//  Copyright (c) 2013 Oklahoma State University Medical Physics Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIPopoverControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
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
- (void)updateimage;
- (void)updatecsv;
- (void)updateRect;

@end