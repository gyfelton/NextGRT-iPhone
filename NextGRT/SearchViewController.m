//
//  SecondViewController.m
//  NextGRT
//
//  Created by Yuanfeng on 12-01-13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SearchViewController.h"
#import "UIImage+RenderViewToImage.h"
#import "AppDelegate.h"

#define CENTER_OFFSET_FOR_SELECTED_ANNOTATION 80

@implementation SearchViewController

@synthesize stops, searchResults;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
//        self.title = NSLocalizedString(@"Second", @"Second");
//        self.tabBarItem.image = [UIImage imageNamed:@"second"];
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:local(@"Search") image:[UIImage imageNamed:@"tabbar_radar"] tag:2];
        
        if (SHOW_MAP) {
            _arrowUp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"route_detail_arrow_shadow"]];
        }
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
    //don't do this for now
//    [_locationManager startUpdatingLocation];
    [_hud show:NO];
    [_hud hide:NO afterDelay:0.5f];
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
        CGFloat height = 367;
        //TODO change to user currentResolution
        if (_tableContainer.frame.size.height > 367) {
            height = 367+88;
        }
        
        _stopTableVC = [[BusStopsPullToRefreshTableViewController alloc] initWithTableWidth:320 Height:height Stops:self.stops andDelegate:self needLoadMoreStopsButton:_areNearbyStops];
        _stopTableVC.customDelegate = self;
        
        if (SHOW_MAP) {
            _stopTableVC.tableView.tableHeaderView = _mapTogglerBaseForList;
        }
        
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

        //add msg to guide user to open the stop during first launch
        NSString *alreadySeenKey = [NSString stringWithFormat:@"ALREADY_SHOW_CLICK_CELL_EXPAND_HINT_KEY_FOR_%@", [NSString stringWithFormat:@"Version_%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
        
        BOOL hasShown = [[NSUserDefaults standardUserDefaults] boolForKey:alreadySeenKey];
        if (!hasShown) {
            StatusBarMsgAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
            [appDelegate showMessageAtStatusBarWithText:local(@"Tap any stop below to reveal list of buses") duration:3.3f animated:YES];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:alreadySeenKey];
        }
    } else {
        //enable/disable loadmorebutton accordingly
        _stopTableVC.needLoadMoreButton = _areNearbyStops;
        
        _stopTableVC.stops = nil;
        _stopTableVC.stops = self.stops;
        [_stopTableVC reloadDataAndStopLoadingAnimation];
    }

    //Add the shadow to the top
    _table_top_shadow= [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_horizontal_down_shadow"]];
    _table_top_shadow.frame = CGRectMake(0, 0, 320, 10);
    [_tableContainer addSubview:_table_top_shadow];
//    top_shadow.backgroundColor = [UIColor redColor];
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
    if (!_stopTableVC.isAskingForManualLocation) {
        //expand search radius
        [GRTDatabaseManager sharedManager].isAskingForManualLocation = YES;
        _currSearchRadiusFactor+=0.5;
    }
    
    //clear out current stops for new result
    self.stops = nil;
    [[GRTDatabaseManager sharedManager] queryNearbyStops:_currLocation withDelegate:self withSearchRadiusFactor:_currSearchRadiusFactor];
}

#pragma mark - SearchDisplayController Delegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    if( [searchString length] > 1 ) {
        self.searchResults = nil;
        //pre-process the string to determine search by ID or search by name
        if ([searchString intValue] > 9) {
            //its a number, search by ID
            [[GRTDatabaseManager sharedManager] queryStopIDs:[[NSArray alloc] initWithObjects:searchString, nil] withDelegate:self groupByStopName:YES];
        } else
        {
            //search by name
            [[GRTDatabaseManager sharedManager] queryStopIDsUsingName:searchString withDelegate:self groupByStopName:YES];
        }
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
    
    [self.view bringSubviewToFront:_searchBar];
    controller.searchBar.prompt = local(@"Enter stop name, road name or bus stop ID");
    
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
    controller.searchBar.prompt = @"";
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

//- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    if (tableView == _stopTableVC.tableView) {
//        if (SHOW_MAP && section == 0) {
//            return _mapToggler;
//        }
//    }
//    return nil;
//}

//- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
//{
//    if (tableView == _stopTableVC.tableView) {
//        if (SHOW_MAP && section == 0) {
//            return _mapToggler.frame.size.height;
//        }
//    }
//    return 0;
//}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([searchResults count] != 0) {
        return local(@"Search Result");
    }
    return nil;
}

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
            cell.textLabel.text = local(@"Type road name or 4-digit bus stop ID");
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
        _searchDisplayVC.searchBar.prompt = @"";
        [_searchDisplayVC setActive:NO animated:YES];
        
        //remind user that pull to reload current location
        AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [delegate showMessageAtStatusBarWithText:local(@"Tip: Pull down to reload nearby stops") duration:2.6 animated:YES];
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
//    [_searchDisplayVC performSelector:@selector(setSearchBar:)withObject:_searchBar];
    _searchDisplayVC.delegate = self;
    _searchDisplayVC.searchResultsDataSource = self;
    _searchDisplayVC.searchResultsDelegate = self;
    
    _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    
    //[_searchBar setTintColor:[UIColor colorWithRed:0.427f green:0.514f blue:0.637 alpha:1.0f]];
    _searchTextReachCriteria = NO;
    _searchResultsReturned = NO;
    
    //as we search stop number only by now
    _searchDisplayVC.searchBar.keyboardType = UIKeyboardTypeDefault;
    
    _currLocation = nil;
    
    _hintButton.hidden = YES;
    _hintButton.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    _hintButton.titleLabel.textAlignment = UITextAlignmentCenter;
    _hintButton.titleLabel.numberOfLines = 3;
    [_hintButton addTarget:self action:@selector(hintButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:kFavStopArrayDidUpdateNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didResumeFromBackground:) name:kNewDayArrivedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didResumeFromBackground:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self startLoadingGeoLocation];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFavStopArrayDidUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNewDayArrivedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    _table_top_shadow = nil;
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

#pragma mark - UIView Animation Stop Action
- (void)removeAllAddedViews
{
    _mapView.userInteractionEnabled = YES;
    [_arrowUp removeFromSuperview];
    [_mapViewTopBtn removeFromSuperview];
    [_routeDetailTableVC.tableView removeFromSuperview];
    [_lowerPartImageView removeFromSuperview];
    [_topShadow removeFromSuperview];
    [_bottomShadow removeFromSuperview];
    MKAnnotationView *temp = _currentAnnotationView;
    _currentAnnotationView = nil;
    [_mapView deselectAnnotation:temp.annotation animated:YES];
}


- (void)switchToMapViewAnimationDidFinish
{
    if (_mapView.superview) { //mapview is in place
        //Put annotations to to it
        [_mapView addAnnotations:self.stops];
        //for debug purpose
        if (debug) {
            [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(43.472617, -80.541059)];
        }
    }
}

#pragma mark - UISegmentControl
- (IBAction)segmentControlValueChanged:(UISegmentedControl*)segmentControl
{
    if (segmentControl.selectedSegmentIndex ==  0) {
        segmentControl.selectedSegmentIndex = 1; //need to revert back
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(removeAllAddedViews)];
        [UIView setAnimationDuration:0.6f];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
        [_mapBaseView removeFromSuperview];
        [UIView commitAnimations];
    } else if (segmentControl.selectedSegmentIndex == 1) {
        segmentControl.selectedSegmentIndex = 0;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(switchToMapViewAnimationDidFinish)];
        [UIView setAnimationDuration:0.6f];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
        
        MKCoordinateRegion region;
        region.center = _mapView.userLocation.coordinate;  
        
        MKCoordinateSpan span; 
        span.latitudeDelta  = 0.01; // Change these values to change the zoom
        span.longitudeDelta = 0.01; 
        region.span = span;

        [_mapView setRegion:region];
        
        [self.view addSubview:_mapBaseView];
        
        [UIView commitAnimations];
    }
}

#pragma mark - MapView Delegate
- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
{

}

- (MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    if ([annotation isKindOfClass:[Stop class]]) {
        static NSString* busStopReuseID = @"BusStopAnnotationView_ID";
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)
        [mapView dequeueReusableAnnotationViewWithIdentifier:busStopReuseID];
        if (!pinView) {
            // if an existing pin view was not available, create one
            MKPinAnnotationView* customPinView = [[MKPinAnnotationView alloc]
                                                   initWithAnnotation:annotation reuseIdentifier:busStopReuseID];
            customPinView.pinColor = MKPinAnnotationColorGreen;
            customPinView.animatesDrop = YES;
            customPinView.canShowCallout = YES;
            
            // add a detail disclosure button to the callout which will open a new view controller page
            //
            // note: you can assign a specific call out accessory view, or as MKMapViewDelegate you can implement:
            //  - (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;
            //
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            customPinView.rightCalloutAccessoryView = rightButton;
            rightButton.tag = 1;
            UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
            leftButton.frame = CGRectMake(0, 0, 32, 32);
            leftButton.showsTouchWhenHighlighted = YES;
            leftButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 3, 0);
            leftButton.tag = 0;
            [leftButton setImage:[UIImage imageNamed:@"star_empty_big"] forState:UIControlStateNormal];
            [leftButton setImage:[UIImage imageNamed:@"star_full_big"] forState:UIControlStateHighlighted];
            [leftButton setImage:[UIImage imageNamed:@"star_full_big"] forState:UIControlStateSelected];
            customPinView.leftCalloutAccessoryView = leftButton;
            
            pinView = customPinView;
        } else
        {
            pinView.annotation = annotation;
            //TODO set fav state
        }
        return pinView;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if (control.tag == 1) { //right button
        _currentAnnotationView = view;
        //Not use this for now: this triggers didDeselectAnnotationView
        //[mapView deselectAnnotation:view.annotation animated:YES];
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([view.annotation coordinate].latitude, [view.annotation coordinate].longitude);
        CGPoint tempPoint = [mapView convertCoordinate:coord toPointToView:mapView];
        tempPoint = CGPointMake(tempPoint.x, tempPoint.y+CENTER_OFFSET_FOR_SELECTED_ANNOTATION);
        coord = [mapView convertPoint:tempPoint toCoordinateFromView:mapView];
        [mapView setCenterCoordinate:coord animated:YES];
    }
}

/* Not use this for now
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    if (_currentAnnotationView) {
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([view.annotation coordinate].latitude, [view.annotation coordinate].longitude);
        CGPoint tempPoint = [mapView convertCoordinate:coord toPointToView:mapView];
        tempPoint = CGPointMake(tempPoint.x, tempPoint.y+CENTER_OFFSET_FOR_SELECTED_ANNOTATION);
        coord = [mapView convertPoint:tempPoint toCoordinateFromView:mapView];
        [mapView setCenterCoordinate:coord animated:YES];
    }
}*/

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    NSLog(@"Region changed");
    if (_currentAnnotationView) {
        [mapView selectAnnotation:_currentAnnotationView.annotation animated:YES];
        
        _mapView.userInteractionEnabled = NO;
        
        //crop the image out 
        CGFloat arrowHeight = _arrowUp.frame.size.height;
        CGPoint annotationsPoint = [mapView convertCoordinate:[_currentAnnotationView.annotation coordinate] toPointToView:mapView];
        CGRect cropRect = CGRectMake(0, annotationsPoint.y+arrowHeight, mapView.bounds.size.width, mapView.bounds.size.height-annotationsPoint.y - arrowHeight);
        UIImage *mapViewImage = [UIImage renderViewToImage:mapView fromViewFrame:cropRect];
        _lowerPartImageView = [[UIImageView alloc] initWithFrame:cropRect]; //Should not use initWithImage directly!
        _lowerPartImageView.image = mapViewImage;
        _lowerPartImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        //Add Arrow
        _arrowUp.center = CGPointMake(cropRect.origin.x+cropRect.size.width/2.0f, cropRect.origin.y);
        _arrowUp.frame = CGRectMake((cropRect.origin.x+cropRect.size.width)/2-_arrowUp.frame.size.width/2.0f, cropRect.origin.y-_arrowUp.frame.size.height,_arrowUp.frame.size.width, _arrowUp.frame.size.height);
        [_mapView addSubview:_arrowUp];

        //Add Detail table view
        _routeDetailTableVC = [[RouteDetailTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
        _routeDetailTableVC.userTouchEventDelegate = self; //TODO
        //assign the data
        Stop* stop = _currentAnnotationView.annotation;
        if ([stop isKindOfClass:[Stop class]]) {
            _routeDetailTableVC.stop = stop;
            //TODO add button for lower image
            _routeDetailTableHeightOffset = [stop.busRoutes count] < 4? (-1*36.0f-(3-[stop.busRoutes count])*OPENED_CELL_INTERNAL_CELL_HEIGHT) : -1*33.0f;
        } else
        {
            [NSException raise:@"RouteDetailTableVC Exception: No support of this annocation Class" format:@""];
        }
        
        //TODO reuse tableVC
        _routeDetailTableVC.tableView.frame = CGRectIncreaseHeight(cropRect, _routeDetailTableHeightOffset);
        //As we add it to mapBaseView subview, we need to calculate the position of it relative to mapBaseView, not mapView
        UITableView *table = _routeDetailTableVC.tableView;
        table.frame = CGRectMake(table.frame.origin.x, table.frame.origin.y+_mapView.frame.origin.y, table.frame.size.width, table.frame.size.height);
        
        table.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        UIImage *bgImg = [UIImage imageNamed:@"route_detail_bg"];
        bgImg = [bgImg stretchableImageWithLeftCapWidth:0 topCapHeight:0];
        table.backgroundView = [[UIImageView alloc] initWithImage:bgImg];
        
        [_mapBaseView addSubview:table];
        
        //Add the shadows on top and bottom
        _topShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_horizontal_down_shadow"]];
        _topShadow.frame = CGRectMake(table.frame.origin.x, table.frame.origin.y, table.frame.size.width, _topShadow.frame.size.height);
        [_mapBaseView addSubview:_topShadow];
        _bottomShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_horizontal_up_shadow"]];
        _bottomShadow.frame = CGRectMake(table.frame.origin.x, table.frame.origin.y+table.frame.size.height-_bottomShadow.frame.size.height, table.frame.size.width, _bottomShadow.frame.size.height);
        [_mapBaseView addSubview:_bottomShadow];

        
        //Add a transparent button on the top portion
        if (!_mapViewTopBtn) {
            _mapViewTopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            _mapViewTopBtn.frame = CGRectMake(mapView.frame.origin.x,mapView.frame.origin.y,mapView.frame.size.width,mapView.frame.size.height-cropRect.size.height);
            _mapViewTopBtn.backgroundColor = [UIColor clearColor];
            [_mapViewTopBtn addTarget:self action:@selector(onMapTopButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        [_mapBaseView addSubview:_mapViewTopBtn];
        [_mapBaseView bringSubviewToFront:_mapViewTopBtn];
        
        //Add lower image and animate transition
        //As we need to add to mapBaseView, need to recalculate frame
        _lowerPartImageView.frame = CGRectMake(_lowerPartImageView.frame.origin.x, _lowerPartImageView.frame.origin.y+_mapView.frame.origin.y, _lowerPartImageView.frame.size.width, _lowerPartImageView.frame.size.height);
        [_mapBaseView addSubview:_lowerPartImageView];

        [UIView beginAnimations:@"translation" context:NULL];
        [UIView setAnimationDuration:0.5f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        _lowerPartImageView.frame = CGRectOffset(_lowerPartImageView.frame, 0, _lowerPartImageView.frame.size.height+_routeDetailTableHeightOffset);
        [UIView commitAnimations];
    }
}

- (void)onMapTopButtonClicked:(id)sedner
{
    [UIView beginAnimations:@"translation" context:NULL];
    [UIView setAnimationDuration:0.5f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeAllAddedViews)];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    _lowerPartImageView.frame = CGRectOffset(_lowerPartImageView.frame, 0, -1*_lowerPartImageView.frame.size.height-_routeDetailTableHeightOffset);
    [UIView commitAnimations];
}

@end
