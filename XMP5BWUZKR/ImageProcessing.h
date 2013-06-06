//
//  ImageProcessing.h
//  XMP5BWUZKR
//
//  Created by Medical Physics Lab on 5/8/13.
//  Copyright (c) 2013 Oklahoma State University Medical Physics Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageProcessing : NSObject

//getDataPath: void -> NSString*
//Returns the full path of where userdata.csv is stored
- (NSString*)getDataPath;

//getFileName: void -> NSString*
//Returns the name of the saved file
- (NSString*)getFileName;

//setFileName: NSString* -> void
//Sets the file name to the given name
- (void)setFileName:(NSString*)newName;

//closeFile: void -> void
//Closes the file and resets the fileName to the default userdata
- (void)closeFile;

//grayPhoto: CIImage -> CIImage
//Grayscales a given photo with an intensity between 0 and 1
-(CIImage*)grayPhoto:(CIImage *)img withAmount:(float)intensity;

//getPixelAverages: CIImage* -> NSString*
//Takes the current image from the view controller, calculates RGBA averages, and returns a string with the information
- (NSString*)getPixelAverages:(UIImage*)mainImage;

- (void)calibrate:(UIImage*)input;

- (double)getDose:(UIImage*)input;

//makeCSV: NSString* -> void
//Initializes the CSV with the given filename
- (void)makeCSV:(NSString*)newName;

//updateCSV: void -> void
//Writes the data for the RGBA values currently stored to a comma-seperated value file named userdata.csv
- (void)updateCSV;

@end
