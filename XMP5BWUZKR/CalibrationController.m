//
//  CalibrationController.m
//  XMP5BWUZKR
//
//  Created by Medical Physics Lab on 6/12/13.
//  Copyright (c) 2013 Oklahoma State University Medical Physics Lab. All rights reserved.
//

#import "CalibrationController.h"
#import "SharedData.h"

@interface CalibrationController (){
    int numberOfPoints;
    int orderNumber;
}
@end

@implementation CalibrationController

@synthesize sampleTableView;

NSMutableArray* items;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    numberOfPoints = [[SharedData sharedData]getNumberOfPoints];
    self.calibrationPointStepper.value = numberOfPoints;
    [self changePointNumber:nil];
    orderNumber = [[SharedData sharedData]getCurveOrder];
    self.curveOrderStepper.value = orderNumber;
    [self changeOrder:nil];
    //self.gymuLabel.hidden = TRUE;
    //self.gymuInput.hidden = TRUE;
    
    items = [[NSMutableArray alloc] initWithObjects:@"Item No. 1", @"Item No. 2", @"Item No. 3", @"Item No. 4", @"Item No. 5", @"Item No. 6", nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    // Usually the number of items in your array (the one that holds your list)
    return [items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //Where we configure the cell in each row
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell... setting the text of our cell's label
    cell.textLabel.text = [items objectAtIndex:indexPath.row];
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    // If you want to push another view upon tapping one of the cells on your table.
    
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (IBAction)changePointNumber:(id)sender {
    numberOfPoints =  self.calibrationPointStepper.value;
    
    if (numberOfPoints == 8) {
        self.calibrationPointLabel.text = @"8 (Recommended)";
    }
    else{
        self.calibrationPointLabel.text = [NSString stringWithFormat:@"%d", numberOfPoints];
    }
}

- (IBAction)changeOrder:(id)sender {
    orderNumber = self.curveOrderStepper.value;
    
    if (orderNumber == 5) {
        self.curveOrderLabel.text = @"5 (Recommended)";
    }
    else{
        self.curveOrderLabel.text = [NSString stringWithFormat:@"%d", orderNumber];
    }
}

/*
- (IBAction)displayGy:(id)sender {
    [self updateDisplayforGy];
}
*/

- (IBAction)saveValues:(id)sender {
    [[SharedData sharedData]setNumberOfPoints:numberOfPoints];
    [[SharedData sharedData]setCurveOrder:orderNumber];
}

- (IBAction)resetToDefaults:(id)sender {
    [[SharedData sharedData]setNumberOfPoints:8];
    [[SharedData sharedData]setCurveOrder:5];
    [self viewDidLoad];
}

- (IBAction)closeView:(id)sender {
    NSLog(@"View closed!");
}

/*
- (void)updateDisplayforGy{
    if (self.gyToggle.on) {
        self.gymuLabel.hidden = FALSE;
        self.gymuInput.hidden = FALSE;
    }
    else{
        self.gymuLabel.hidden = TRUE;
        self.gymuInput.hidden = TRUE;
    }
}

 */
@end
