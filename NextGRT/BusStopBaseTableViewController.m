//
//  BusStopBaseTableViewController.m
//  GRTEasyGo
//
//  Created by Yuanfeng on 11-07-15.
//  Copyright 2011 Elton(Yuanfeng) Gao. All rights reserved.
//

#import "BusStopBaseTableViewController.h"
#import "Stop.h"
#import "BusRoute.h"
#import "OpenedBusStopCell.h"
#import "UnopenedBusStopCell.h"

#define REFRESH_INTERVAL_IN_SECONDS 30

@implementation BusStopBaseTableViewController

@synthesize stops, customDelegate, forFavStopVC;

#pragma mark - View lifecycle

- (id)initWithTableWidth:(CGFloat)width Height:(CGFloat)height Stops:(NSMutableArray*)s{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.tableView.frame = CGRectMake(0, 0, width, height);
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.showsVerticalScrollIndicator = NO;
        self.forFavStopVC = NO;
        self.stops = s;
    }
    
    selectedCellIndexPath_ = nil;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTime) name:UIApplicationDidBecomeActiveNotification object:nil];
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

- (void)foldAllStops
{
    NSIndexPath *selectedIndexPathCopy = [selectedCellIndexPath_ copy];
    selectedCellIndexPath_ = nil;
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:selectedIndexPathCopy, nil] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

#pragma mark - Table View DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.stops count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if( (selectedCellIndexPath_ && [selectedCellIndexPath_ compare:indexPath] == NSOrderedSame) ) {
        //calculate height of opened cell based on number of routes
        //if 0 route: just the base
        //else : base + INTERNAL_CELL_HEIGHT * #routes
        int numRoutes = [[[self.stops objectAtIndex:[indexPath row]] busRoutes] count];
        
        if (numRoutes==0) {
            return UNOPENED_CELL_HEIGHT;
        }
        
        return OPENED_CELL_HEIGHT_BASE + numRoutes * OPENED_CELL_INTERNAL_CELL_HEIGHT;
    } else {
        return UNOPENED_CELL_HEIGHT;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //refresh timer if needed
    //TODO need to exe this after table finish loading
    UITableViewCell* cell = nil;
    if( !gotTimer ) {
        timer_ = [NSTimer scheduledTimerWithTimeInterval:REFRESH_INTERVAL_IN_SECONDS target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
        gotTimer = YES;
    }
    
    if( (!selectedCellIndexPath_ || [selectedCellIndexPath_ compare:indexPath] != NSOrderedSame) )//&& [stops count] > 2 ) {
    {
        //if there are only two cells, just open all of them
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"unopenedStop"];
        if( !cell ) {
            cell = [[UnopenedBusStopCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"unopenedStop"];
        }
        
        Stop* aStop = [self.stops objectAtIndex:[indexPath row]];
        
        [((UnopenedBusStopCell*)cell) initCellInfoWithStop:aStop];
        
    } else{
        
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"openedStop"];
        if( !cell ) {
            cell = [[OpenedBusStopCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"openedStop"];
        }
        
        Stop* aStop = [self.stops objectAtIndex:[indexPath row]];
        
        [((OpenedBusStopCell*)cell) initCellInfoWithStop:aStop];
    }
    
    if (self.forFavStopVC) {
        ((BusStopCellBaseClass*)cell).cellType = cellForFavVC;
    }

    cell.showsReorderControl = YES;
    cell.shouldIndentWhileEditing = NO;

    assert(cell);
    return cell;
}

#pragma mark - UITable Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //strongly check whether selectedCellIndexPath is valid or not
    if( ![self.tableView cellForRowAtIndexPath:selectedCellIndexPath_] ) {
        selectedCellIndexPath_ = nil;
    }
    
    NSMutableArray *indexPathsToReload = [[NSMutableArray alloc] init];
    
    if( selectedCellIndexPath_ && [selectedCellIndexPath_ compare:indexPath] == NSOrderedSame ) {
        selectedCellIndexPath_ = nil;
        //TODO animation not nice enough
    } else if( selectedCellIndexPath_ ) {
        NSIndexPath* temp = [selectedCellIndexPath_ copy];
        selectedCellIndexPath_ = nil;
        [indexPathsToReload addObject:temp];
        selectedCellIndexPath_ = [indexPath copy]; 
    } else {
        selectedCellIndexPath_ = [indexPath copy];
    }

    [self.tableView beginUpdates];
    //ready to animate the selected row (expand or shrink)
    [indexPathsToReload addObject:indexPath];
    [self.tableView reloadRowsAtIndexPaths:indexPathsToReload withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    if( selectedCellIndexPath_ ) {
        //this one only scroll if needed
        //TODO bug: sometimes this scrolling does not work as expected
        [self.tableView scrollToRowAtIndexPath:selectedCellIndexPath_ atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
//        [self.tableView scrollRectToVisible:[[self.tableView cellForRowAtIndexPath:selectedCellIndexPath_] frame] animated:YES];
        //this one always scroll the row to the top, very irritating
        //[self.tableView scrollToRowAtIndexPath: selectedCellIndexPath_ atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (customDelegate && [customDelegate respondsToSelector:@selector(tableView:canEditRowAtIndexPath:)]) {
        return [customDelegate tableView:tableView canEditRowAtIndexPath:indexPath];
    }
    return YES;
}

//
//// Override to support editing the table view.
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        //add code here for when you hit delete
//    }    
//}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (customDelegate && [customDelegate respondsToSelector:@selector(tableView:commitEditingStyle:forRowAtIndexPath:)]) {
        [customDelegate tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if (customDelegate && [customDelegate respondsToSelector:@selector(tableView:moveRowAtIndexPath:toIndexPath:)]) {
        [customDelegate tableView:tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - Timer

- (void) updateTime {
    //this just send a REFRESH_INTERVAL_IN_SECONDS signal to all routes telling them REFRESH_INTERVAL_IN_SECONDS has passed
    //TODO when scrolling, don't update data! use scroll delegate to enable/disable
    NSArray* visibleCells = [self.tableView indexPathsForVisibleRows];
    for( NSIndexPath *indexPath in visibleCells ) {
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
        //TODO delay in refresh of time?
        if( [cell isKindOfClass:[BusStopCellBaseClass class]] )
           [((BusStopCellBaseClass*)cell) refreshRoutesInCellWithSeconds:REFRESH_INTERVAL_IN_SECONDS];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

#pragma mark - Memory Management

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [timer_ invalidate];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.stops = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

@end
