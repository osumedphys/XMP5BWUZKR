//
//  CalibrationPointsController.m
//  XMP5BWUZKR
//
//  Created by Medical Physics Lab on 6/20/13.
//  Copyright (c) 2013 Oklahoma State University Medical Physics Lab. All rights reserved.
//

#import "CalibrationPointsController.h"
#import "SharedData.h"
#import "ViewController.h"

#define kPickerAnimationDuration 0.40

@interface CalibrationPointsController ()

@end

@implementation CalibrationPointsController

NSArray* items;
UIAlertView* inputView;
NSString* curveName;

int calibrationPoints;
int curveOrder;
int inputKey;

int defaultPoints = 7;
int defaultOrder = 6;
/*
 A NOTE ON INPUT KEY:
 
 The property inputKey is used to properly collect data from inputView.
 The default numbers are as follows:
 -1: calibrationPoints
 -2: curveOrder
 -3: changeCurveName
 
 Any other integer>=0 corresponds to the cell at that index in the data section (section #1)
 */

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    items = [[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"Number of Calibration Points: %d (Recommended)", defaultPoints], [NSString stringWithFormat:@"Curve Order: %d (Recommended)", defaultOrder], nil];
    calibrationPoints = [[SharedData sharedData]getNumberOfPoints];
    curveOrder = [[SharedData sharedData]getCurveOrder];
    
    self.navigationController.toolbarHidden = FALSE;
    
    curveName = @" ";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    switch (section) {
        case 0:
            return [items count];
        case 1:
            return calibrationPoints;
        case 2:
            return 1;
        default:
            return 0;
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return @"Welcome to the OSU Dose Analyzer!  Please select the number of calibration points and curve order desired, or select 'Load' from the bottom of the screen.";
        case 1:
            return @"Now, input the doses delivered to the calibration slides in monitor units or Grey.";
        case 2:
            return @"If you would like to save this calibration curve, please name it below:";
        default:
            return @"";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]init];
    int sectionNo = indexPath.section;
    int rowNo = indexPath.row;
    
    switch (sectionNo) {
        case 0:
            cell.textLabel.text = [items objectAtIndex:rowNo];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case 1:
            cell.textLabel.text = @" ";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        case 2:
            cell.textLabel.text = curveName;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        default:
            break;
    }
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int sectionNo = indexPath.section;
    int rowNo = indexPath.row;
        
    [self.tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    switch (sectionNo) {
        case 0:
            if (rowNo == 0) {
                inputKey = -1;
            }
            else inputKey = -2;
            inputView = [[UIAlertView alloc]initWithTitle:@"Enter a Number" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            inputView.alertViewStyle = UIAlertViewStylePlainTextInput;
            break;
        case 1:
            inputKey = rowNo;
            inputView = [[UIAlertView alloc]initWithTitle:@"Enter a Number" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            inputView.alertViewStyle = UIAlertViewStylePlainTextInput;
            break;
        case 2:
            inputKey = -3;
            inputView = [[UIAlertView alloc]initWithTitle:@"Enter a Name" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            inputView.alertViewStyle = UIAlertViewStylePlainTextInput;
            break;
        default:
            break;
    }
    [inputView show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == alertView.cancelButtonIndex || [[inputView textFieldAtIndex:0].text length] <= 0) {
        return;
    }
    else{
        NSString* inputText = [inputView textFieldAtIndex:0].text;
        int inputNumber = [inputText integerValue];
        switch (inputKey) {
            case -1:
                [self changePointNumber:inputNumber];
                break;
            case -2:
                [self changeCurveOrder:inputNumber];
                break;
            case -3:
                [self changeCurveName:inputText];
                break;
            default:
                [self changeRowValue:inputKey withValue:inputNumber];
                break;
        }
    }
    [alertView textFieldAtIndex:0].text = @"";
}

- (void)insertRows:(int)numberOfRows{
    NSMutableArray* rowsToInsert = [[NSMutableArray alloc]initWithCapacity:numberOfRows];
    for (int i=0; i<numberOfRows; i++) {
        [rowsToInsert insertObject:[NSIndexPath indexPathForRow:calibrationPoints+i inSection:1] atIndex:i];
    }
    calibrationPoints = calibrationPoints + numberOfRows;
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:rowsToInsert withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

- (void)deleteRows:(int)numberOfRows{
    NSMutableArray* rowsToDelete = [[NSMutableArray alloc]initWithCapacity:numberOfRows];
    for (int i=0; i<numberOfRows; i++) {
        [rowsToDelete insertObject:[NSIndexPath indexPathForRow:(calibrationPoints-1)-i inSection:1] atIndex:i];
    }
    calibrationPoints = calibrationPoints - numberOfRows;
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:rowsToDelete withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

- (void)changePointNumber:(int)newNoOfPoints{
    int arraySize = calibrationPoints - newNoOfPoints;
    
    if (arraySize > 0) {
        [self deleteRows:arraySize];
    }
    
    if (arraySize < 0) {
        [self insertRows:abs(arraySize)];
    }
    
    if (newNoOfPoints == defaultPoints) {
        [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].textLabel.text = [NSString stringWithFormat:@"Number of Calibration Points: %d (Recommended)", defaultPoints];
    }
    else{
        [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].textLabel.text = [NSString stringWithFormat:@"Number of Calibration Points: %d", newNoOfPoints];
    }
    
    [[SharedData sharedData]setNumberOfPoints:calibrationPoints];
}

- (void)changeCurveOrder:(int)newOrder{
    if (newOrder == defaultOrder) {
        [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]].textLabel.text = [NSString stringWithFormat: @"Curve Order: %d (Recommended)", defaultOrder];
        curveOrder = 5;
    }
    else{
        [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]].textLabel.text = [NSString stringWithFormat:@"Curve Order: %d", newOrder];
        curveOrder = newOrder;
    }
    
    [[SharedData sharedData]setCurveOrder:curveOrder];
}

- (void)changeRowValue:(int)rowNumber withValue:(int)value{
    [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:rowNumber inSection:1]].textLabel.text = [NSString stringWithFormat:@"%d", value];
    [[SharedData sharedData]setYValue:value atIndex:rowNumber];
}

- (void)changeCurveName:(NSString*)newName{
    curveName = newName;
    [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]].textLabel.text = curveName;
}

- (IBAction)setDefaults:(id)sender {
    [self changePointNumber:defaultPoints];
    [self changeCurveOrder:defaultOrder];
    [[SharedData sharedData]setNumberOfPoints:calibrationPoints];
    [[SharedData sharedData]setCurveOrder:curveOrder];
}
@end
