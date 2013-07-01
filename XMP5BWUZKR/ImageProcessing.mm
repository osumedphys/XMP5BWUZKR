//
//  ImageProcessing.m
//  XMP5BWUZKR
//
//  Created by Medical Physics Lab on 5/8/13.
//  Copyright (c) 2013 Oklahoma State University Medical Physics Lab. All rights reserved.
//

#import "ImageProcessing.h"
#import "CurveFit.h"
#import "SharedData.h"
#include "math.h"
#include <iostream>
using namespace std;

@implementation ImageProcessing
NSArray *labels;

NSMutableArray *redvalues;
NSMutableArray *greenvalues;
NSMutableArray *bluevalues;
NSMutableArray *alphavalues;

NSString *dataPath;
NSString *fileName;

CIFilter *monochrome;

double averageRed;
double averageGreen;
double averageBlue;

float widthscale;
float heightscale; 
int imageNumber;

int howmanypoints;
int donepoints;
int order;

double* redxs;
double* doseys;
double* coeffs;

CurveFit* myfit;

- (id)init{
    self = [super init];
    
    howmanypoints = 0;
    donepoints = 0;
    order = 0;
    
    redxs = 0;
    doseys = 0;
    coeffs = 0;
    
    labels = [[NSArray alloc]initWithObjects:@"Image #, ", @"Red, ", @"Green, ", @"Blue, ", @"Alpha\n", nil];
    
    redvalues = [[NSMutableArray alloc] init];
    greenvalues = [[NSMutableArray alloc] init];
    bluevalues = [[NSMutableArray alloc] init];
    alphavalues = [[NSMutableArray alloc] init];
    
    imageNumber = 0;
    dataPath = [[NSString alloc]init];
    fileName = @"userdata";
    monochrome = [CIFilter filterWithName:@"CIColorMonochrome"];
    [monochrome setValue:[CIColor colorWithRed:1 green:1 blue:1 alpha:1] forKey:@"inputColor"];
    
    averageRed = 0;
    averageGreen = 0;
    averageBlue = 0;
    
    /*
    NSArray* filters = [CIFilter filterNamesInCategories:nil];
    for (NSString* filterName in filters)
    {
        NSLog(@"Filter: %@", filterName);
        //NSLog(@"Parameters: %@", [[CIFilter filterWithName:filterName] attributes]);
    }
    */
    
    double* testDoses = new double[8];
    
    for(int i=1; i<=6; i++){
        testDoses[i-1] = 50*i;
    }
    
    testDoses[6] = 400;
    testDoses[7] = 500;
    
    doseys = testDoses;
    
    return self;
}

//Accessors

-(NSString*)getDataPath{
    return dataPath;
}

-(NSString*)getFileName{
    return fileName;
}

//Mutators

-(void)setFileName:(NSString*)newName{
    fileName = newName;
}

-(void)closeFile{
    imageNumber = 0;
    dataPath = [[NSString alloc]init];
    fileName = @"userdata";
}

-(CIImage *)grayPhoto:(CIImage *)img withAmount:(float)intensity
{
    [monochrome setValue:img forKey:kCIInputImageKey];
    [monochrome setValue:@(intensity) forKey:@"inputIntensity"];
    return monochrome.outputImage;
}

- (NSArray*)getPixelAverages:(UIImage*)mainImage{
    NSArray* imageValues;
    int numberofpixels = mainImage.size.width * mainImage.size.height;
    
    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(mainImage.CGImage));
    const UInt8* data = CFDataGetBytePtr(pixelData);
    
    double red = 0;
    double green = 0;
    double blue = 0;
    double alpha = 0;
    
    for (int i=0; i<(CFDataGetLength(pixelData)); i=i+4) {
        red = red + data[i];
        green = green + data[i+1];
        blue = blue + data[i+2];
        alpha = alpha + data[i+3];
    }
    
    red = red/numberofpixels;
    green = green/numberofpixels;
    blue = blue/numberofpixels;
    alpha = alpha/numberofpixels;
    
    //[self updateCSV];
    
    imageValues = [[NSArray alloc]initWithObjects:[NSNumber numberWithDouble:red], [NSNumber numberWithDouble:green], [NSNumber numberWithDouble:blue], [NSNumber numberWithDouble:alpha], nil];
    
    CFRelease(pixelData);
    return imageValues;
    
}

- (void)prepForCalibration{
    howmanypoints = [[SharedData sharedData]getNumberOfPoints];
    order = [[SharedData sharedData]getCurveOrder];
    myfit = new CurveFit(howmanypoints);
    imageNumber = 0;
}

- (int)newcalibrate:(UIImage*)input{
    NSArray* averages = [self getPixelAverages:input];
    double currentRed = [averages[0] doubleValue];
    [[SharedData sharedData]getxvalues][imageNumber] = currentRed;
    int displayedImageNumber = ++imageNumber;
    return displayedImageNumber;
}

- (void)getNewCoefficients{
    myfit->setxvalues([[SharedData sharedData]getxvalues]);
    myfit->setyvalues([[SharedData sharedData]getyvalues]);
    cout << "X VALUES" << endl;
    for(int i=0; i<howmanypoints; i++){
        cout << i << ": " << myfit->getxvalues()[i] << endl;
    }
    cout << "Y VALUES" << endl;
    for(int i=0; i<howmanypoints; i++){
        cout << i << ": " << myfit->getyvalues()[i] << endl;
    }
    myfit->fitCurve(order);
    coeffs = myfit->getcoefficients();
}

- (double)getDose:(UIImage *)input{
    double dose = 0;
    [self getPixelAverages:input];
    //double netred = averageRed - [[redvalues objectAtIndex:thisImageNumber] doubleValue];
    //double netred = [[redvalues objectAtIndex:thisImageNumber] doubleValue];
    //double netred = [[bluevalues objectAtIndex:thisImageNumber] doubleValue];
    
    NSArray* thisdata = [self getPixelAverages:input];
    
    double netred = [thisdata[0] doubleValue];
    
    NSLog(@"Image %d has averages: \nRed: %f", imageNumber, netred);
    
    for (int i=0; i<=order; i++) {
        dose += coeffs[i]*pow(netred, i);
    }
    
    return dose;
}

- (void)makeCSV:(NSString*)newName{
    fileName = newName;
    NSMutableArray *csvArray = [[NSMutableArray alloc]init];
    [csvArray addObjectsFromArray:labels];
    
    NSString *csv = [csvArray componentsJoinedByString:@""];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.csv", fileName]];
    
    dataPath = fullPath;
    
    [fileManager createFileAtPath:fullPath contents:[csv dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
}

- (void)updateCSV
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
    
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.csv", fileName]];
    
    dataPath = fullPath;
    
    [fileManager createFileAtPath:fullPath contents:[csv dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
}

@end
