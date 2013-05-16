//
//  ImageProcessing.m
//  XMP5BWUZKR
//
//  Created by Medical Physics Lab on 5/8/13.
//  Copyright (c) 2013 Oklahoma State University Medical Physics Lab. All rights reserved.
//

#import "ImageProcessing.h"

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

float widthscale; 
float heightscale; 
int imageNumber;

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

- (NSString*)getPixelAverages:(UIImageView*)mainImage{
    widthscale = mainImage.image.size.width/484;
    heightscale = mainImage.image.size.height/648;
    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(mainImage.image.CGImage));
    const UInt8* data = CFDataGetBytePtr(pixelData);
    
    int red = 0;
    int green = 0;
    int blue = 0;
    int alpha = 0;
    
    int pixelno = 0;
    
    for (int i=0; i<=(mainImage.image.size.height*heightscale+mainImage.image.size.width*widthscale); i=i+4) {
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
    
    [redvalues addObject:[NSNumber numberWithInt:red]];
    [greenvalues addObject:[NSNumber numberWithInt:green]];
    [bluevalues addObject:[NSNumber numberWithInt:blue]];
    [alphavalues addObject:[NSNumber numberWithInt:alpha]];
    
    [self updateCSV];
    
    CFRelease(pixelData);
    
    NSString *labeltext = [NSString stringWithFormat:@"Image %d has averages: \nRed: %d\nGreen: %d\nBlue: %d\nAlpha: %d", imageNumber, red, green, blue, alpha];
    
    imageNumber++;
    
    return labeltext;
    
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
