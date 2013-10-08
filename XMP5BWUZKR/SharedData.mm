//
//  SharedData.m
//  XMP5BWUZKR
//
//  Created by Medical Physics Lab on 6/13/13.
//  Copyright (c) 2013 Oklahoma State University Medical Physics Lab. All rights reserved.
//

#import "SharedData.h"

@implementation SharedData

int numberOfPoints = 7;
int orderNumber = 6;

double* xvalues;
double* yvalues;

+(SharedData*)sharedData{
    static SharedData* sharedName = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedName = [[SharedData alloc] init];
        [sharedName setNumberOfPoints:numberOfPoints];
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

-(void)setYValue:(double)y atIndex:(int)index{
    yvalues[index] = y;
}

-(double*)getxvalues{
    return xvalues;
}

-(double*)getyvalues{
    return yvalues;
}

-(double)getYatIndex:(int)index{
    return yvalues[index];
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
