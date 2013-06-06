//
//  ImageProcessing.m
//  XMP5BWUZKR
//
//  Created by Medical Physics Lab on 5/8/13.
//  Copyright (c) 2013 Oklahoma State University Medical Physics Lab. All rights reserved.
//

#import "ImageProcessing.h"
#import "CurveFit.h"
#include "math.h"
#include <iostream>
using namespace std;

@implementation ImageProcessing

CIContext *context;
CIImage *beginImage;
CIImage *currentImage;

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

int howmanypoints = 5;
int donepoints = 0;
int order = 5;

CurveFit* myfit = new CurveFit();
double* redxs = new double[howmanypoints];
double* doseys = new double[howmanypoints];
double* coeffs = new double[order+1];

- (id)init{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"IMG_0005" ofType:@"jpg"];
    NSURL *fileNameAndPath = [NSURL fileURLWithPath:filePath];
    
    beginImage = [CIImage imageWithContentsOfURL:fileNameAndPath];
    
    context = [CIContext contextWithOptions:nil];
    
    CIImage *outputImage = beginImage;
    
    currentImage = outputImage;
    
    labels = [[NSArray alloc]initWithObjects:@"Image #, ", @"Red, ", @"Green, ", @"Blue, ", @"Alpha\n", nil];
    
    redvalues = [[NSMutableArray alloc] init];
    greenvalues = [[NSMutableArray alloc] init];
    bluevalues = [[NSMutableArray alloc] init];
    alphavalues = [[NSMutableArray alloc] init];
    
    imageNumber = 1;
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
    
    for(int i=1; i<=howmanypoints; i++){
        doseys[i-1] = 50*i;
    }
    
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
    imageNumber = 1;
    dataPath = [[NSString alloc]init];
    fileName = @"userdata";
}

-(CIImage *)grayPhoto:(CIImage *)img withAmount:(float)intensity
{
    [monochrome setValue:img forKey:kCIInputImageKey];
    [monochrome setValue:@(intensity) forKey:@"inputIntensity"];
    return monochrome.outputImage;
}

- (NSString*)getPixelAverages:(UIImage*)mainImage{
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
    
    [redvalues addObject:[NSNumber numberWithDouble:red]];
    [greenvalues addObject:[NSNumber numberWithDouble:green]];
    [bluevalues addObject:[NSNumber numberWithDouble:blue]];
    [alphavalues addObject:[NSNumber numberWithDouble:alpha]];
    
    [self updateCSV];
    
    CFRelease(pixelData);
    
    NSString *labeltext = [NSString stringWithFormat:@"Image %d has averages: \nRed: %f\nGreen: %f\nBlue: %f\nAlpha: %f", imageNumber, red, green, blue, alpha];
    
    imageNumber++;
    return labeltext;
    
}

- (void)calibrate:(UIImage*)input{
    [self getPixelAverages:input];
    int thisImageNumber = imageNumber-2;
    averageRed = [[redvalues objectAtIndex:thisImageNumber] doubleValue];
    NSLog(@"Image %d has averages: \nRed: %f", imageNumber, averageRed);
    redxs[donepoints] = averageRed;
    //averageGreen = [[greenvalues objectAtIndex:thisImageNumber] doubleValue];
    //averageBlue = [[bluevalues objectAtIndex:thisImageNumber] doubleValue];
    donepoints++;
    
    if (donepoints == howmanypoints) {
        myfit->setnumberofpoints(howmanypoints);
        cout << "X VALUES" << endl;
        myfit->setxvalues(redxs);
        for(int i=0; i<howmanypoints; i++){
            cout << i << ": " << myfit->getxvalues()[i] << endl;
        }
        myfit->setyvalues(doseys);
        cout << "Y VALUES" << endl;
        for(int i=0; i<howmanypoints; i++){
            cout << i << ": " << myfit->getyvalues()[i] << endl;
        }
        myfit->fitCurve(order);
        coeffs = myfit->getcoefficients();
    }
}

- (double)getDose:(UIImage *)input{
    double dose = 0;
    [self getPixelAverages:input];
    int thisImageNumber = imageNumber-2;
    //double netred = averageRed - [[redvalues objectAtIndex:thisImageNumber] doubleValue];
    double netred = [[redvalues objectAtIndex:thisImageNumber] doubleValue];
    NSLog(@"Image %d has averages: \nRed: %f", imageNumber, netred);
    //dose = -85.93420733 + 8.08522231*netred - 0.27978893*pow(netred, 2) +  6.46083385*pow(10, -3)*pow(netred, 3)  - 6.69401931*pow(10, -5)*pow(netred, 4) +  2.66219494*pow(10, -7)*pow(netred, 5);
    
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
