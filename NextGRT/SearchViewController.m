//
//  SecondViewController.m
//  NextGRT
//
//  Created by Yuanfeng on 12-01-13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SearchViewController.h"

#import "AppDelegate.h"

@implementation SearchViewController

@synthesize stops, searchResults;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
//        self.title = NSLocalizedString(@"Second", @"Second");
//        self.tabBarItem.image = [UIImage imageNamed:@"second"];
        self.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:2];
    }
    return self;
}
							
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Location delegate

- (void) didResumeFromBackground:(NSNotification*)notification
{
    [_locationManager startUpdatingLocation];
}

- (void) startLoadingGeoLocation {
    _hud.labelText = local(@"Searching neayby stops...");
    _hud.detailsLabelText = local(@"You can also search bus stops above");
    [_hud show:YES];
    
    //start updating gps location
    _currSearchRadiusFactor = 1;
    _locationManager = [AppDelegate sharedLocationManager];
    _locationManager.distanceFilter = 100;
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];   
}

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    //TODO no update of table if location does not change
    [manager stopUpdatingLocation];
    
    //if location change is significant
    if (!_areNearbyStops || !oldLocation || [newLocation distanceFromLocation:oldLocation]>100.0f) {
        _currLocation = [newLocation copy];
        
        //the stops we have later will be nearby stops, so load more button is needed
        _areNearbyStops = YES;
        
        [self performSelector:@selector(queryStops:) withObject:newLocation afterDelay:0];
        
        _hud.mode = MBProgressHUDModeIndeterminate;
        _hud.labelText = local(@"Processing...");
        _hud.detailsLabelText = @"";
//        _hud.dimBackground = YES;
        if (_hud.isHidden) {
            [_hud show:YES];
        } else
        {
            [_hud show:NO];
        }
    } else
    {
        [_stopTableVC reloadDataAndStopLoadingAnimation];
    }
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
//    _mainTitle.text = @"Cannot get your current location.";
//    _loadingIndicator.hidden = YES;
    _hintButton.hidden = NO;
    [_hintButton setTitle:local(@"Fail to locate your position\n click here to try again.\nOr search bus stops above") forState:UIControlStateNormal];
    [_hud hide:YES];
    //for debug purpose only
    //    NSLog(@"ATTENTION: geo location manual override!");
    //    CLLocation* newLocation = [[[CLLocation alloc] initWithLatitude:43.472617 longitude:-80.541059] autorelease];
    //    currLocation_ = [newLocation copy];
    //    [self performSelector:@selector(queryStops:) withObject:newLocation afterDelay:0]; 
}

#pragma mark - Query Stops

- (void) queryStops:(CLLocation *)newLocation {
    [[GRTDatabaseManager sharedManager] queryNearbyStops:newLocation withDelegate:self withSearchRadiusFactor:_currSearchRadiusFactor];   
}

#pragma mark - GRTDatabaseDelegate

- (void) nearbyStopsReceived:(NSMutableArray*)s {
    self.stops = s;
    //query for route info, it will go to busRoutesForAllStopsReceived
    [[GRTDatabaseManager sharedManager] queryBusRoutesForStops:self.stops withDelegate:self];  
}

- (void)reloadTable
{
    [_hud hide:YES];
    //put stop to the table
    if( !_stopTableVC ) {
        _stopTableVC = [[BusStopsPullToRefreshTableViewController alloc] initWithTableWidth:320 Height:367 Stops:self.stops andDelegate:self needLoadMoreStopsButton:_areNearbyStops];
        _stopTableVC.customDelegate = self;
        //Add table in animated way
        _stopTableVC.tableView.backgroundColor = UITableBackgroundColor;
        
        [_tableContainer addSubview:_stopTableVC.tableView];
        _stopTableVC.tableView.hidden = NO;
//        [_tableContainer setFrame:CGRectMake(_tableContainer.frame.origin.x, 500, _tableContainer.frame.size.width, _tableContainer.frame.size.height)];
        _stopTableVC.tableView.alpha = 0.6f;
        _stopTableVC.tableView.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDuration:0.3];
//        [_tableContainer setFrame:CGRectMake(_tableContainer.frame.origin.x, 44, _tableContainer.frame.size.width, _tableContainer.frame.size.height)];
        _stopTableVC.tableView.alpha = 1.0f;
        _stopTableVC.tableView.transform = CGAffineTransformIdentity;
        [UIView commitAnimations];

    } else {
        //enable/disable loadmorebutton accordingly
        _stopTableVC.needLoadMoreButton = _areNearbyStops;
        
        _stopTableVC.stops = nil;
        _stopTableVC.stops = self.stops;
        [_stopTableVC reloadDataAndStopLoadingAnimation];
    }

}

- (void) busRoutesForAllStopsReceived {
    [self performSelectorOnMainThread:@selector(reloadTable) withObject:nil waitUntilDone:NO];
}

- (void)stopInfoArrayReceived:(NSArray*)arr {
        _searchResultsReturned = YES;
        self.searchResults = [NSMutableArray arrayWithArray:arr];
        [_searchDisplayVC.searchResultsTableView reloadData];
}

#pragma mark - PullToRefreshLoadMoreDelegate

- (void) requestForNewGeoLocation {
    [self startLoadingGeoLocation];
}

- (void) requestForMoreStops {
    //expand search radius
    _currSearchRadiusFactor+=0.5;
    
    //clear out current stops for new result
    self.stops = nil;
    [[GRTDatabaseManager sharedManager] queryNearbyStops:_currLocation withDelegate:self withSearchRadiusFactor:_currSearchRadiusFactor];
}

#pragma mark - SearchDisplayController Delegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    if( [searchString length] > 1 ) {
        self.searchResults = nil;
        [[GRTDatabaseManager sharedManager] queryStopIDs:[[NSArray alloc] initWithObjects:searchString, nil] withDelegate:self groupByStopName:YES];
        _searchTextReachCriteria  = YES;
        _searchResultsReturned = YES;
    } else {
        self.searchResults = nil;
        _searchResultsReturned = NO;
        _searchTextReachCriteria = NO;
    }
    return YES;
}

- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    //controller.searchBar.placeholder = @"4-digit stop number (e.g. 2675)";
    
    //stop geolocation updating
    [_locationManager stopUpdatingLocation];
    
    //update main title, tips and show switch
    _hintButton.hidden = NO;
    [_hintButton setTitle:local(@"click here to resume \n locating your position") forState:UIControlStateNormal];
//    _mainTitle.text = @"Location updating stopped";
//    _loadingIndicator.hidden = YES;
//    _quickSearch.text = @"Slide to start updating again:";
//    _locationUpdateSwitch.on = NO;
//    _locationUpdateSwitch.hidden = NO;
    [_hud hide:YES];
}


- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    //controller.searchBar.placeholder = @"Bus Stop Quick Search";
    searchResults = nil;
}

#pragma mark - UIButton IBAction
- (void)hintButtonClicked:(UIButton*)btn
{
    if (true) {
        [self startLoadingGeoLocation];
        _hintButton.hidden = YES;
    }
}

//- (IBAction) locationUpdateSwitchToggled:(id)sender {
//    NSLog(@"start update position again...");
//    
////    _mainTitle.text = @"Searching nearby stops...";
////    _quickSearch.text = @"You can also do quick search in the search bar above";
////    _locationUpdateSwitch.hidden = YES;
////    _loadingIndicator.hidden = YES;
//    
//    [self startLoadingGeoLocation];
//}

#pragma mark - SearchResultTable Date Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if( [searchResults count] == 0 ) {
        return 1;
    } else {
        return [searchResults count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
	if( tableView == _searchDisplayVC.searchResultsTableView ) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"searchResult"];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchResult"];
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
        }
        
        if( [searchResults count] != 0 ) {
            cell.textLabel.text = [((Stop*)[searchResults objectAtIndex:[indexPath row]]) stopName];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            
        } else if (_searchResultsReturned ) {
            cell.textLabel.text = local(@"No result found");
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        } else if (_searchTextReachCriteria) {
            cell.textLabel.text = local(@"Loading...");
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        } else {
            cell.textLabel.text = local(@"Type a 4-digit Bus Stop Number");
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }
        
    }
    return cell;
}

#pragma mark - UITableView Delegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _stopTableVC.tableView) {
        return NO;
    }
    return YES;
}

//this is for search results
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if( [searchResults count] != 0 && _searchTextReachCriteria ) {
        //release old stops
        self.stops = nil;
        
        //TODO optimization: shouldn't overwrite nearby stops, neaby stops should not be reload if location does not change
        self.stops  = [[GRTDatabaseManager sharedManager] queryAllStopsWithStopName:[[searchResults objectAtIndex:[indexPath row]] stopName]];
        
        //release search results
        self.searchResults = nil;
        
        _areNearbyStops = NO; //indicate whether results in self.stops are nearyby stops
        [[GRTDatabaseManager sharedManager] queryBusRoutesForStops:self.stops withDelegate:self];
        
        //dismiss the search display VC
        [_searchDisplayVC setActive:NO animated:YES];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tableContainer.hidden = NO;
    _tableContainer.backgroundColor = UITableBackgroundColor;    
    _hud = [[MBProgressHUD alloc] initWithView:_tableContainer];
    _hud.animationType = MBProgressHUDAnimationZoom;
//    _hud.dimBackground = YES;
    [_tableContainer addSubview:_hud];
    
	// Do any additional setup after loading the view, typically from a nib.
    //init the search bar and its controller
    _searchDisplayVC = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    
    _searchDisplayVC.delegate = self;
    _searchDisplayVC.searchResultsDataSource = self;
    _searchDisplayVC.searchResultsDelegate = self;
    _searchTextReachCriteria = NO;
    _searchResultsReturned = NO;
    
    //as we search stop number only by now
    _searchDisplayVC.searchBar.keyboardType = UIKeyboardTypeNumberPad;
    
    _currLocation = nil;
    
    _hintButton.hidden = YES;
    _hintButton.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    _hintButton.titleLabel.textAlignment = UITextAlignmentCenter;
    _hintButton.titleLabel.numberOfLines = 3;
    [_hintButton addTarget:self action:@selector(hintButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:kFavStopArrayDidUpdate object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didResumeFromBackground:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self startLoadingGeoLocation];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFavStopArrayDidUpdate object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
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
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
