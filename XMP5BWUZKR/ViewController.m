//
//  ViewController.m
//  XMP5BWUZKR
//
//  Created by Medical Physics Lab on 4/16/13.
//  Copyright (c) 2013 Oklahoma State University Medical Physics Lab. All rights reserved.
//

#import "ViewController.h"
#import "ImageProcessing.h"
#import "SharedData.h"

@interface ViewController () < UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation ViewController
CIContext *context;
CIImage *beginImage;
CIImage *currentImage;
CGRect selectionRect;
NSMutableArray *points;
float widthscale;
float heightscale;
float currentslidervalue;
CAShapeLayer *rectLayer;
UIAlertView* newFileDialog;
UIImagePickerController* imagePicker;
@synthesize popoverController;

double currentDose;
bool fileCreated;
bool isPreppedForCalibration;

//Declare Custom Tools
ImageProcessing* imageProcessor;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.toolbarHidden = TRUE;
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Logo" ofType:@"jpg"];
    NSURL *fileNameAndPath = [NSURL fileURLWithPath:filePath];
    
    beginImage = [CIImage imageWithContentsOfURL:fileNameAndPath];
    
    context = [CIContext contextWithOptions:nil];
    
    CIImage *outputImage = beginImage;
    
    CGImageRef cgimg =
    [context createCGImage:outputImage fromRect:[outputImage extent]];

    currentImage = outputImage;
    self.imageView.image = [UIImage imageWithCGImage:cgimg];
    
    CGImageRelease(cgimg);
    
    self.imageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapRecognizer:)];
    [singleTapGesture setNumberOfTapsRequired:1];
    [singleTapGesture setNumberOfTouchesRequired:1];
    [self.imageView addGestureRecognizer:singleTapGesture];
    
    [self initializePointArray];
    
    widthscale = self.imageView.image.size.width/484;
    heightscale = self.imageView.image.size.height/648;
    
    rectLayer = [CAShapeLayer layer];
    [rectLayer setBounds:CGRectMake(0.0f, 0.0f, [self.imageView bounds].size.width, [self.imageView bounds].size.height)];
    
    self.saveLabel.hidden = TRUE;
    
    newFileDialog = [[UIAlertView alloc]initWithTitle:@"Save As..." message:@"Default name is userdata" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    newFileDialog.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    fileCreated = FALSE;
    
    imagePicker = [[UIImagePickerController alloc] init];
    
    currentDose = 0;
    
    self.navigationController.toolbarHidden = FALSE;
    isPreppedForCalibration = FALSE;
    
    self.calibrationLabel.text = [NSString stringWithFormat:@"Select Point %d", (int)[[SharedData sharedData]getYatIndex:0]];
    
    //Initialize Custom Tools
    imageProcessor = [[ImageProcessing alloc]init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializePointArray
{
    points = nil;
    
    NSMutableArray* tempearray = [[NSMutableArray alloc] initWithCapacity:2];
    
    for(NSUInteger i=0; i<2; i++){
        [tempearray insertObject:[NSValue valueWithCGPoint:CGPointMake(-1, -1)] atIndex:i];
    }
    
    points = tempearray;
    
    NSString *thepoint = [NSString stringWithFormat:@"Points: %@\n            %@", NSStringFromCGPoint([[points objectAtIndex:0] CGPointValue]), NSStringFromCGPoint([[points objectAtIndex:1] CGPointValue])];
    [[self pointLabel]setText:thepoint];
}

- (IBAction)amountSliderValueChanged:(UISlider *)slider
{
    float slideValue = slider.value;
    
    //CIImage *outputImage = [imageProcessor grayPhoto:currentImage withAmount:slideValue];
    
    //CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    //self.imageView.image = [UIImage imageWithCGImage:cgimg];
    
    CIFilter *monochrome = [CIFilter filterWithName:@"CIColorMonochrome"];
    [monochrome setValue:[CIColor colorWithRed:1 green:1 blue:1 alpha:1] forKey:@"inputColor"];
    [monochrome setValue:currentImage forKey:kCIInputImageKey];
    [monochrome setValue:@(slideValue) forKey:@"inputIntensity"];
    CIImage *outputImage = monochrome.outputImage;
    
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    self.imageView.image = [UIImage imageWithCGImage:cgimg];
    
    currentslidervalue = slideValue;
    
    CGImageRelease(cgimg);
}

- (IBAction)loadPhoto:(id)sender
{
    UIImagePickerController *pickerC = [[UIImagePickerController alloc] init];
    pickerC.delegate = self;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        popoverController=[[UIPopoverController alloc]
                           initWithContentViewController:pickerC];
        [popoverController presentPopoverFromRect:((UIButton *)sender).frame
                                           inView:self.view
                         permittedArrowDirections:UIPopoverArrowDirectionAny
                                         animated:YES];
    }
    else{
        [self presentViewController:pickerC animated:YES completion:nil];
    }
    [self initializePointArray];
    [self updateRect];
}

- (IBAction)savePhoto:(id)sender
{
    
    self.saveLabel.hidden = FALSE;
    CIImage *saveToSave = [imageProcessor grayPhoto:currentImage withAmount:currentslidervalue];
    CIContext *softwareContext = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(YES)}];
    CGImageRef cgImg = [softwareContext createCGImage:saveToSave fromRect:[saveToSave extent]];
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:cgImg metadata:[saveToSave properties] completionBlock:^(NSURL *assetURL, NSError *error) {CGImageRelease(cgImg);}];
    
    self.saveLabel.text = [NSString stringWithFormat:@"Saved!"];
    [self performSelector:@selector(hideLabel:) withObject:self.saveLabel afterDelay:2];
}

- (void)hideLabel:(UILabel *)label {
	[label setHidden:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *gotImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    CIImage *theci = [CIImage imageWithCGImage:gotImage.CGImage];
    if (gotImage.imageOrientation == UIImageOrientationRight) {
        beginImage = [theci imageByApplyingTransform:CGAffineTransformMakeRotation(-M_PI/2)];
    } else {
        beginImage = theci;
    } 
    currentImage = beginImage;
    [self amountSliderValueChanged:self.amountSlider];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [popoverController dismissPopoverAnimated:YES];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)takePicture:(id)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    else{
        return;
    }
     
    [self initializePointArray];
    [self updateRect];
}

/*
- (IBAction)getPixelInfo:(id)sender
{
    if (fileCreated == FALSE) {
        [newFileDialog show];
        fileCreated = TRUE;
    }
    self.infoLabel.text = [imageProcessor getPixelAverages:self.imageView.image];
}
*/
 
- (IBAction)getThatArea:(id)sender
{
    widthscale = self.imageView.image.size.width/484;
    heightscale = self.imageView.image.size.height/648;
    CGPoint topleft;
    NSValue *value1 = [points objectAtIndex:0];
    CGPoint point1 = value1.CGPointValue;
    NSValue *value2 = [points objectAtIndex:1];
    CGPoint point2 = value2.CGPointValue;
    if (point1.x < point2.x) {
        topleft = point1;
    } else {
        topleft = point2;
    }
    CGRect myrect = CGRectMake((topleft.x)*widthscale, (topleft.y)*heightscale, (abs(point1.x - point2.x))*widthscale, (abs(point1.y - point2.y))*heightscale);
    CGImageRef imageRef = CGImageCreateWithImageInRect([self.imageView.image CGImage], myrect);
    currentImage = [CIImage imageWithCGImage:imageRef];
    [self updateimage];
    CGImageRelease(imageRef);
    
    [self initializePointArray];
    [self updateRect];
}

- (void)singleTapRecognizer:(UITapGestureRecognizer*)paramSender
{
    NSUInteger touchCounter = 0;
    for (touchCounter = 0; touchCounter < paramSender.numberOfTouchesRequired; touchCounter++)
    {
        CGPoint touchPoint = [paramSender locationOfTouch:touchCounter inView:paramSender.view];
        [points exchangeObjectAtIndex:0 withObjectAtIndex:1];
        [points replaceObjectAtIndex:1 withObject:[NSValue valueWithCGPoint:touchPoint]];
        NSString *thepoint = [NSString stringWithFormat:@"Points: %@\n            %@", NSStringFromCGPoint([[points objectAtIndex:0] CGPointValue]), NSStringFromCGPoint([[points objectAtIndex:1] CGPointValue])];
        [[self pointLabel]setText:thepoint];
    }
    
    [self updateRect];
}

- (IBAction)resetImage:(id)sender
{
    self.amountSlider.value = 0;
    currentImage = beginImage;
    [self updateimage];
    [self initializePointArray];
    [self updateRect];
}

- (IBAction)newData:(id)sender {
    [newFileDialog show];
}

- (IBAction)emailData:(id)sender {
    NSString *emailTitle = @"Dosimetry Data";
    NSString *messageBody = @"Your dosimetry data is attached!";
    NSArray *toRecipents = [NSArray arrayWithObject:@"osumedphys@gmail.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    if ([MFMailComposeViewController canSendMail]) {
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:NO];
        [mc setToRecipients:toRecipents];
        NSData* sendData = [[NSData alloc]initWithContentsOfFile:imageProcessor.getDataPath];
        [mc addAttachmentData:sendData mimeType:@"text/csv" fileName:[NSString stringWithFormat:@"%@.csv", imageProcessor.getFileName]];
        [self presentViewController:mc animated:YES completion:NULL];
    }
    else return;
}

- (IBAction)closeFile:(id)sender {
    [imageProcessor closeFile];
    //self.infoLabel.text = @"File Closed!";
    fileCreated = FALSE;
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == alertView.cancelButtonIndex || [[newFileDialog textFieldAtIndex:0].text length] <= 0) {
        return;
    }
    else{
        [imageProcessor makeCSV:[newFileDialog textFieldAtIndex:0].text];
    }
}

- (void)updateimage
{
    CGImageRef cgimg =
    [context createCGImage:currentImage fromRect:[currentImage extent]];
    
    self.imageView.image =[UIImage imageWithCGImage:cgimg];
    
    CGImageRelease(cgimg);
}

- (void)updateRect
{
    [rectLayer setPosition:CGPointMake(self.imageView.frame.origin.x+100, self.imageView.frame.origin.y+250)];
    NSValue *value1 = [points objectAtIndex:0];
    CGPoint point1 = value1.CGPointValue;
    NSValue *value2 = [points objectAtIndex:1];
    CGPoint point2 = value2.CGPointValue;
    if (point1.x < point2.x) {
        selectionRect = CGRectMake((point1.x), (point1.y), (abs(point1.x - point2.x)), (abs(point1.y - point2.y)));
    }
    else {
        selectionRect = CGRectMake((point2.x), (point2.y), (abs(point1.x - point2.x)), (abs(point1.y - point2.y)));
    }
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:selectionRect];

    [rectLayer setPath:[path CGPath]];

    [rectLayer setStrokeColor:[[UIColor redColor] CGColor]];

    [rectLayer setLineWidth:1.0f];
    
    [rectLayer setFillColor:nil];
    
    [[self.imageView layer] addSublayer:rectLayer];
}

- (IBAction)setCalibration:(id)sender {
    if(isPreppedForCalibration == FALSE){
        [imageProcessor prepForCalibration];
        isPreppedForCalibration = TRUE;
    }
    int displaynumber = [imageProcessor newcalibrate:self.imageView.image] + 1;
    
    /*
     if(displaynumber <= [[SharedData sharedData]getNumberOfPoints]){
        self.calibrationLabel.text = [NSString stringWithFormat:@"Select Point %d", displaynumber];
    } */
    
    if(displaynumber <= [[SharedData sharedData]getNumberOfPoints]){
        self.calibrationLabel.text = [NSString stringWithFormat:@"Select Point %d", (int)[[SharedData sharedData]getYatIndex:displaynumber-1]];
    }
    
    else{
        self.calibrationLabel.text = @"Calibration Complete!";
        self.calibrationButton.hidden = TRUE;
        [imageProcessor getNewCoefficients];
        isPreppedForCalibration = FALSE;
    }
}

- (IBAction)getDose:(id)sender {
    currentDose = [imageProcessor getDose:self.imageView.image];
    self.doseLabel.text = [NSString stringWithFormat:@"Dose: %f", currentDose];
}

- (IBAction)newCurve:(id)sender {
    [imageProcessor prepForCalibration];
    self.calibrationLabel.hidden = TRUE;
    self.calibrationLabel.text = @"Select Point 1";
    self.calibrationButton.hidden = TRUE;
}
@end