//
//  CalibrationPointsController.h
//  XMP5BWUZKR
//
//  Created by Medical Physics Lab on 6/20/13.
//  Copyright (c) 2013 Oklahoma State University Medical Physics Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalibrationPointsController : UITableViewController <UIAlertViewDelegate>

- (IBAction)setDefaults:(id)sender;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

- (void)changePointNumber:(int)newNoOfPoints;
- (void)changeCurveOrder:(int)newOrder;
- (void)changeRowValue:(int)rowNumber withValue:(int)value;
- (void)insertRows:(int)numberOfRows;
- (void)deleteRows:(int)numberOfRows;
- (void)changeCurveName:(NSString*)newName;

@end
