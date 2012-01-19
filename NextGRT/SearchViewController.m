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

- (void) startLoadingGeoLocation {
    //the stops we have later will be nearby stops, so load more button is needed
    _areNearbyStops = YES;
    
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
    if (!oldLocation || [newLocation distanceFromLocation:oldLocation]>100.0f) {
        //change main title and hide quick search tip
        _mainTitle.text = @"Processing stops and routes...";
        _quickSearch.hidden = YES;
        
        _currLocation = [newLocation copy];
        
        [self performSelector:@selector(queryStops:) withObject:newLocation afterDelay:0];
    } else
    {
        [_stopTableVC reloadDataAndStopLoadingAnimation];
    }
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    _mainTitle.text = @"Cannot get your current location.";
    _loadingIndicator.hidden = YES;
    
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

#pragma mark - GRTDatabaseDelegate Notification Selector

- (void) nearbyStopsReceived:(NSNotification*)notification {
    //self.stops = nil; //release old stops
    id delegate = [[notification userInfo] valueForKey:@"delegate"];
    if (self == delegate) {
        self.stops = [notification object];
        
        //query for route info, it will go to busRoutesForAllStopsReceived
        [[GRTDatabaseManager sharedManager] queryBusRoutesForStops:self.stops withDelegate:self];  
    }
}

- (void)reloadTable
{
    //put stop to the table
    if( !_stopTableVC ) {
        _stopTableVC = [[BusStopsPullToRefreshTableViewController alloc] initWithTableWidth:320 Height:367 Stops:self.stops andDelegate:self needLoadMoreStopsButton:_areNearbyStops];
        //Add table in animated way
        [_tableContainer addSubview:_stopTableVC.tableView];
        _tableContainer.hidden = NO;
        _stopTableVC.tableView.hidden = NO;
        [_tableContainer setFrame:CGRectMake(_tableContainer.frame.origin.x, 500, _tableContainer.frame.size.width, _tableContainer.frame.size.height)];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDuration:0.6];
        [_tableContainer setFrame:CGRectMake(_tableContainer.frame.origin.x, 44, _tableContainer.frame.size.width, _tableContainer.frame.size.height)];
        [UIView commitAnimations];
        _mainTitle.hidden = YES;
        _quickSearch.hidden = YES;
        _loadingIndicator.hidden = YES;
    } else {
        //enable/disable loadmorebutton accordingly
        _stopTableVC.needLoadMoreButton = _areNearbyStops;
        
        _stopTableVC.stops = nil;
        _stopTableVC.stops = self.stops;
        [_stopTableVC reloadDataAndStopLoadingAnimation];
    }

}

- (void) busRoutesForAllStopsReceived:(NSNotification*)notification {
    id delegate = [[notification userInfo] valueForKey:@"delegate"];
    if (self == delegate) {
        [self performSelectorOnMainThread:@selector(reloadTable) withObject:nil waitUntilDone:YES];
    }
}

- (void)stopInfoArrayReceived:(NSNotification*)notification {
    //used only for search result
    id delegate = [[notification userInfo] valueForKey:@"delegate"];
    if (delegate == self) {
        NSArray *s = [notification object];
        _searchResultsReturned = YES;
        self.searchResults = [NSMutableArray arrayWithArray:s];
        [_searchDisplayVC.searchResultsTableView reloadData];
    }
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
    _mainTitle.text = @"Location updating stopped";
    _loadingIndicator.hidden = YES;
    _quickSearch.text = @"Slide to start updating again:";
    _locationUpdateSwitch.on = NO;
    _locationUpdateSwitch.hidden = NO;
    
}


- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    //controller.searchBar.placeholder = @"Bus Stop Quick Search";
    searchResults = nil;
}

#pragma mark - Switch toggle IBAction

- (IBAction) locationUpdateSwitchToggled:(id)sender {
    NSLog(@"start update position again...");
    
    _mainTitle.text = @"Searching nearby stops...";
    _quickSearch.text = @"You can also do quick search in the search bar above";
    _locationUpdateSwitch.hidden = YES;
    _loadingIndicator.hidden = YES;
    
    [self startLoadingGeoLocation];
}

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
            cell.textLabel.text = @"No result found";
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        } else if (_searchTextReachCriteria) {
            cell.textLabel.text = @"Loading...";
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        } else {
            cell.textLabel.text = @"Type a 4-digit Bus Stop Number";
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }
        
    }
    return cell;
}

#pragma mark - UITableView Delegate

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nearbyStopsReceived:) name:kQueryNearbyStopsDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(busRoutesForAllStopsReceived:) name:kBusRoutesForAllStopsReceivedNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopInfoArrayReceived:) name:kStopInfoReceivedNotificationName object:nil];
    [self startLoadingGeoLocation];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kQueryNearbyStopsDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kBusRoutesForAllStopsReceivedNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kStopInfoReceivedNotificationName object:nil];
    
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
