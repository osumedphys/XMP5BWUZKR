//
//  ViewController.m
//  XMP5BWUZKR
//
//  Created by Medical Physics Lab on 4/16/13.
//  Copyright (c) 2013 Oklahoma State University Medical Physics Lab. All rights reserved.
//

#import "ViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>

@interface ViewController () < UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@end

@implementation ViewController
CIContext *context;
CIFilter *filter;
CIImage *beginImage;
CIImage *currentImage;
UIImageOrientation orientation;
@synthesize popoverController;
UIPickerView *catergoryPicker;
UIToolbar *pickerToolBar;
CGRect selectionRect;
NSMutableArray *points;
float heightscale;
float widthscale;
float currentslidervalue;
int measurecounter;
NSArray *labels;
NSMutableArray *redvalues;
NSMutableArray *greenvalues;
NSMutableArray *bluevalues;
NSMutableArray *alphavalues;
CAShapeLayer *rectLayer;


-(void)logAllFilters {
    NSArray *properties = [CIFilter filterNamesInCategory:
                           kCICategoryBuiltIn];
    NSLog(@"%@", properties);
    for (NSString *filterName in properties) {
        CIFilter *fltr = [CIFilter filterWithName:filterName];
        NSLog(@"%@", [fltr attributes]);
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //NSString *filePath = [[NSBundle mainBundle] pathForResource:@"image" ofType:@"png"];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"IMG_0005" ofType:@"jpg"];
    NSURL *fileNameAndPath = [NSURL fileURLWithPath:filePath];
    
    beginImage = [CIImage imageWithContentsOfURL:fileNameAndPath];
    
    context = [CIContext contextWithOptions:nil];
    
    CIFilter *monochrome = [CIFilter filterWithName:@"CIColorMonochrome"];
    [monochrome setValue:beginImage forKey:kCIInputImageKey];
    [monochrome setValue:[CIColor colorWithRed:1 green:1 blue:1 alpha:1] forKey:@"inputColor"];
    [monochrome setValue:@(0) forKey:@"inputIntensity"];
    
    CIImage *outputImage = [monochrome outputImage];
    
    CGImageRef cgimg =
    [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *newImage = [UIImage imageWithCGImage:cgimg];
    currentImage = outputImage;
    self.imageView.image = newImage;
    
    CGImageRelease(cgimg);
    
    self.imageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapRecognizer:)];
    [singleTapGesture setNumberOfTapsRequired:1];
    [singleTapGesture setNumberOfTouchesRequired:1];
    [self.imageView addGestureRecognizer:singleTapGesture];
    
    [self initializePointArray:points];
    
    widthscale = self.imageView.image.size.width/484;
    heightscale = self.imageView.image.size.height/648;
    measurecounter = 1;
    
    labels = [[NSArray alloc]initWithObjects:@"Image #, ", @"Red, ", @"Green, ", @"Blue, ", @"Alpha\n", nil];
    
    redvalues = [[NSMutableArray alloc] init];
    greenvalues = [[NSMutableArray alloc] init];
    bluevalues = [[NSMutableArray alloc] init];
    alphavalues = [[NSMutableArray alloc] init];
    
    rectLayer = [CAShapeLayer layer];
    [rectLayer setBounds:CGRectMake(0.0f, 0.0f, [self.imageView bounds].size.width,
                                    [self.imageView bounds].size.height)];
    
    self.saveLabel.hidden = TRUE;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializePointArray:(NSMutableArray *)thearray
{
    points = nil;
    
    thearray = [NSMutableArray arrayWithCapacity:2];
    
    for(NSUInteger i=0; i<2; i++){
        [thearray insertObject:[NSValue valueWithCGPoint:CGPointMake(-1, -1)] atIndex:i];
    }
    
    points = thearray;
    
    NSString *thepoint = [NSString stringWithFormat:@"Points: %@\n            %@", NSStringFromCGPoint([[points objectAtIndex:0] CGPointValue]), NSStringFromCGPoint([[points objectAtIndex:1] CGPointValue])];
    [[self pointLabel]setText:thepoint];
}

- (IBAction)amountSliderValueChanged:(UISlider *)slider
{
    float slideValue = slider.value;
    
    CIImage *outputImage = [self grayPhoto:currentImage withAmount:slideValue];
    
    CGImageRef cgimg = [context createCGImage:outputImage
                                     fromRect:[outputImage extent]];
    
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
}

- (IBAction)savePhoto:(id)sender
{
    
    self.saveLabel.hidden = FALSE;
    
    // 1
    
    CIImage *saveToSave = [self grayPhoto:currentImage withAmount:currentslidervalue];
    
    // 2
    CIContext *softwareContext = [CIContext
                                  contextWithOptions:@{kCIContextUseSoftwareRenderer : @(YES)} ];
    // 3
    CGImageRef cgImg = [softwareContext createCGImage:saveToSave
                                             fromRect:[saveToSave extent]];
    // 4
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:cgImg
                                 metadata:[saveToSave properties]
                          completionBlock:^(NSURL *assetURL, NSError *error) {
                              // 5
                              CGImageRelease(cgImg);
                          }];
    
    self.saveLabel.text = [NSString stringWithFormat:@"Saved!"];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage *gotImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    CIImage *theci = [CIImage imageWithCGImage:gotImage.CGImage];
    if (gotImage.imageOrientation == UIImageOrientationRight) {
        beginImage = [theci imageByApplyingTransform:CGAffineTransformMakeRotation(-M_PI/2)];
    } else {
        beginImage = theci;
    }
    currentImage = beginImage;
    [filter setValue:beginImage forKey:kCIInputImageKey];
    [self amountSliderValueChanged:self.amountSlider];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [popoverController dismissPopoverAnimated:YES];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(CIImage *)grayPhoto:(CIImage *)img withAmount:(float)intensity
{
    
    // 1
    CIFilter *monochrome = [CIFilter filterWithName:@"CIColorMonochrome"];
    [monochrome setValue:img forKey:kCIInputImageKey];
    [monochrome setValue:[CIColor colorWithRed:1 green:1 blue:1 alpha:1] forKey:@"inputColor"];
    [monochrome setValue:@(intensity) forKey:@"inputIntensity"];
    
    // 7
    return monochrome.outputImage;
}

- (IBAction)takePicture:(id)sender
{
    UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    else{
        return;
    }
}

- (IBAction)getPixelInfo:(id)sender
{
    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(self.imageView.image.CGImage));
    const UInt8* data = CFDataGetBytePtr(pixelData);
    
    //int pixelInfo = ((self.imageView.image.size.width  * 50) + 50 ) * 4; // The image is png
    
    int red = 0;
    int green = 0;
    int blue = 0;
    int alpha = 0;
    
    int pixelno = 0;
    
    for (int i=0; i<=(self.imageView.image.size.height*heightscale+self.imageView.image.size.width*widthscale); i=i+4) {
        pixelno++;
        red = red + data[i];
        green = green + data[i+1];
        blue = blue + data[i+2];
        alpha = alpha + data[i+3];
    }
    
    red = red/pixelno;
    green = green/pixelno;
    blue = blue/pixelno;
    alpha = alpha/pixelno;
    
    NSString *labeltext = [NSString stringWithFormat:@"Image %d has averages: \nRed: %d\nBlue: %d\nGreen: %d\nAlpha: %d", measurecounter, red, green, blue, alpha];
    
    self.infoLabel.text = labeltext;
    
    [redvalues addObject:[NSNumber numberWithInt:red]];
    [greenvalues addObject:[NSNumber numberWithInt:green]];
    [bluevalues addObject:[NSNumber numberWithInt:blue]];
    [alphavalues addObject:[NSNumber numberWithInt:alpha]];
    
    [self updatecsv];
    
    CFRelease(pixelData);
    
    measurecounter++;
}

- (IBAction)getThatArea:(id)sender
{
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
    
    [self initializePointArray:points];
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
    
    [rectLayer setPosition:CGPointMake(0, 0)];
    
    [self updateRect];

}

- (IBAction)resetImage:(id)sender
{
    self.amountSlider.value = 0;
    currentImage = beginImage;
    [self updateimage];
    [self initializePointArray:points];
    [self updateRect];
}

- (void)updateimage
{
    CGImageRef cgimg =
    [context createCGImage:currentImage fromRect:[currentImage extent]];
    
    self.imageView.image =[UIImage imageWithCGImage:cgimg];
    
    CGImageRelease(cgimg);
}

- (void)updatecsv
{
    NSMutableArray *csvArray = [[NSMutableArray alloc]init];
    NSUInteger count = [redvalues count];
    [csvArray addObjectsFromArray:labels];
    for (NSUInteger i=0; i<count; i++ ) {
        [csvArray addObject:[NSString stringWithFormat: @"%d", i+1]];
        [csvArray addObject:@","];
        [csvArray addObject:[[redvalues objectAtIndex:i] stringValue]];
        [csvArray addObject:@","];
        [csvArray addObject:[[greenvalues objectAtIndex:i] stringValue]];
        [csvArray addObject:@","];
        [csvArray addObject:[[bluevalues objectAtIndex:i] stringValue]];
        [csvArray addObject:@","];
        [csvArray addObject:[[alphavalues objectAtIndex:i] stringValue]];
        [csvArray addObject:@"\n"];
    }
    
    NSString *csv = [csvArray componentsJoinedByString:@""];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.csv", @"userdata"]];
    [fileManager createFileAtPath:fullPath contents:[csv dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
}

- (void)updateRect
{
    [rectLayer setPosition:CGPointMake(0, 0)];
    
    NSValue *value1 = [points objectAtIndex:0];
    CGPoint point1 = value1.CGPointValue;
    NSValue *value2 = [points objectAtIndex:1];
    CGPoint point2 = value2.CGPointValue;
    if (point1.x < point2.x) {
        selectionRect = CGRectMake((point1.x), (point1.y), (abs(point1.x - point2.x)), (abs(point1.y - point2.y)));
    } else {
        selectionRect = CGRectMake((point2.x), (point2.y), (abs(point1.x - point2.x)), (abs(point1.y - point2.y)));
    }
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:selectionRect];

    [rectLayer setPath:[path CGPath]];

    [rectLayer setStrokeColor:[[UIColor redColor] CGColor]];

    [rectLayer setLineWidth:1.0f];
    
    [rectLayer setFillColor:nil];
    
    [[self.imageView layer] addSublayer:rectLayer];
}

@end