//
//  SharedData.m
//  XMP5BWUZKR
//
//  Created by Medical Physics Lab on 6/13/13.
//  Copyright (c) 2013 Oklahoma State University Medical Physics Lab. All rights reserved.
//

#import "SharedData.h"

@implementation SharedData

int numberOfPoints = 8;
int orderNumber = 5;

double* xvalues;
double* yvalues;

+(SharedData*)sharedData{
    static SharedData* sharedName = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedName = [[SharedData alloc] init];
    });
    return sharedName;
}

-(int)getNumberOfPoints{
    return numberOfPoints;
}

-(int)getCurveOrder{
    return orderNumber;
}

-(void)setxvalues:(double*)newxs{
    xvalues = newxs;
}

-(void)setyvalues:(double*)newys{
    yvalues = newys;
}

-(double*)getxvalues{
    return xvalues;
}

-(double*)getyvalues{
    return yvalues;
}

-(void)setNumberOfPoints:(int)newNumberOfPoints{
    numberOfPoints = newNumberOfPoints;
    xvalues = new double[numberOfPoints];
    yvalues = new double[numberOfPoints];
}

-(void)setCurveOrder:(int)newCurveOrder{
    orderNumber = newCurveOrder;
}

@end
