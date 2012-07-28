//
//  RouteDetailTableViewController.m
//  NextGRT
//
//  Created by Yuanfeng on 12-04-24.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RouteDetailTableViewController.h"
#import "RouteDetailCell.h"
#import "BusRoute.h"
#import "BusStopBaseTableViewController.h"

@implementation RouteDetailTableViewController
@synthesize parentTableViewController;
@synthesize userTouchEventDelegate;
@synthesize detailCellTimerOverlay = _detailCellTimerOverlay;
@synthesize stop = _stop;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _detailCellTimerOverlay = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITable DataSource

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    NSLog(@"heighFor gets called %d", section);
//    int distance = [stop_ distanceFromCurrPositionInMeter];
//    if( distance != -1 ) {
//        return -1;
//    } else {
//        return 0;
//    }
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return OPENED_CELL_INTERNAL_CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //    int distance = [stop_ distanceFromCurrPositionInMeter];
    //    if( distance != -1 ) {
    //        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.height, 30)];
    //        label.text = [NSString stringWithFormat:@"Distance from here: %dm", distance];
    //        return label;
    //    } else {
    //        return nil;
    //    }
    return nil;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //NSLog(@"%d", [stop_.busRoutes count]);
    return [_stop.busRoutes count];//>3?3:[stop_.busRoutes count];
}

- (NSString*)generateTextForTime:(NSInteger)index busRoute:(BusRoute*)route
{
    BOOL showCountDown = [[[[NSUserDefaults standardUserDefaults] dictionaryForKey:USER_DEFAULT_KEY_COUNTDOWN] objectForKey:@"bool"] boolValue];
    BOOL showActualTime = [[[[NSUserDefaults standardUserDefaults] dictionaryForKey:USER_DEFAULT_KEY_ACTUAL_TIME] objectForKey:@"bool"] boolValue];
    if (!showActualTime) {
        showCountDown = YES;
    }
    
    NSString *actualTimeStr = nil;
    if (showActualTime) {
        if (index==1) {
            actualTimeStr = [route getFirstArrivalActualTime];
        } else
        {
            actualTimeStr = [route getSecondArrivalActualTime];
        }
    }
    if (!actualTimeStr || [actualTimeStr isEqualToString:@""]) {
        showActualTime = NO;
        showCountDown = YES;
        actualTimeStr = nil;
    }
    
    NSString *countDownStr = nil;
    if (index==1) {
        countDownStr = [route getFirstArrivalTime];
    } else
    {
        countDownStr = [route getSecondArrivalTime];
    }
    
    NSString *formattedStr = nil;
    if (showCountDown && !showActualTime) {
        formattedStr = countDownStr;
    } else if (showCountDown && showActualTime) {
        formattedStr = [NSString stringWithFormat:@"%@ (%@)", countDownStr, actualTimeStr];
    } else
    {
        formattedStr = actualTimeStr;
    }
    return formattedStr;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"detailCell"];
    if( !cell ) {
        cell = [[RouteDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"detailCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    BusRoute* route = [_stop.busRoutes objectAtIndex:[indexPath row]];
    
    ((RouteDetailCell*)cell).routeNumber.text = route.shortRouteNumber;
    
    [((RouteDetailCell*)cell).routeDetail setText:[NSString stringWithFormat:@"%@", [route getNextBusDirection]]];
    
    if ([((RouteDetailCell*)cell).routeDetail.text  length] <= 0 || [((RouteDetailCell*)cell).routeDetail.text  isEqualToString:@""]) {
        NSLog(@"ERROR! empty name!!!");
    }
    
    ((RouteDetailCell*)cell).firstTime.text = [self generateTextForTime:1 busRoute:route];//[route getFirstArrivalTime];
    NSString *secondText = [self generateTextForTime:2 busRoute:route];//[route getSecondArrivalTime];
    
    // show red text when no more service
    if ( [secondText isEqualToString:local(@"No more service")] ) {
        ((RouteDetailCell*)cell).secondTime.textColor = [UIColor blueColor];//not red for now
    } else
    {
        ((RouteDetailCell*)cell).secondTime.textColor = [UIColor blackColor];
    }
    
    ((RouteDetailCell*)cell).secondTime.text = secondText;
    //((RouteDetailCell*)cell).nextBusDirection.text = [NSString stringWithFormat:@"To: %@", [route getNextBusDirection]];
    
    if (ENABLE_NEW_FEATURES) {
        //get or alloc timer overlay
        UserTouchCaptureView *view = nil;
        if (indexPath.row < _detailCellTimerOverlay.count) {
            view = [_detailCellTimerOverlay objectAtIndex:indexPath.row];
            [view removeFromSuperview];
        } else
        {
            view = [[UserTouchCaptureView alloc] initWithFrame:CGRectMake(12,7, 55, 55)];
            view.backgroundColor = [UIColor redColor];
            [_detailCellTimerOverlay addObject:view];
            view.customDelegate = self.userTouchEventDelegate; //indicate which delegate should it goes to
        }
        
        //calcuate the position to put the overlay, since the table is shown fully, does not scroll, the position is static
        CGFloat yOrigin = 85 + OPENED_CELL_INTERNAL_CELL_HEIGHT*indexPath.row;
        view.frame = CGRectMake(view.frame.origin.x, yOrigin, view.frame.size.width, view.frame.size.height);
        [self.view.superview addSubview:view]; //Must add to super view
    }
    
    return cell;
}

- (void)removeAllTimerOverlayFromSuperView
{
    for (UserTouchCaptureView *view in _detailCellTimerOverlay) {
        [view removeFromSuperview];
    }
}


@end
