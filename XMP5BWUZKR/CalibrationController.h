//
//  CalibrationController.h
//  XMP5BWUZKR
//
//  Created by Medical Physics Lab on 6/12/13.
//  Copyright (c) 2013 Oklahoma State University Medical Physics Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CalibrationController;

@interface CalibrationController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *calibrationPointLabel;
@property (weak, nonatomic) IBOutlet UIStepper *calibrationPointStepper;
@property (weak, nonatomic) IBOutlet UILabel *curveOrderLabel;
@property (weak, nonatomic) IBOutlet UIStepper *curveOrderStepper;

@property (nonatomic, strong) IBOutlet UITableView *sampleTableView; 


//@property (weak, nonatomic) IBOutlet UISwitch *gyToggle;
//@property (weak, nonatomic) IBOutlet UILabel *gymuLabel;
//@property (weak, nonatomic) IBOutlet UITextField *gymuInput;

- (IBAction)changePointNumber:(id)sender;
- (IBAction)changeOrder:(id)sender;
//- (IBAction)displayGy:(id)sender;
- (IBAction)saveValues:(id)sender;
- (IBAction)resetToDefaults:(id)sender;
- (IBAction)closeView:(id)sender;



@end
