//
//  SharedData.h
//  XMP5BWUZKR
//
//  Created by Medical Physics Lab on 6/13/13.
//  Copyright (c) 2013 Oklahoma State University Medical Physics Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedData : NSObject

+(SharedData*) sharedData;
-(int)getNumberOfPoints;
-(int)getCurveOrder;

-(void)setxvalues:(double*)newxs;
-(void)setyvalues:(double*)newys;

-(void)setYValue:(double)y atIndex:(int)index;

-(double*)getxvalues;
-(double*)getyvalues;

-(void)setNumberOfPoints:(int)newNumberOfPoints;
-(void)setCurveOrder:(int)newCurveOrder;

@end
