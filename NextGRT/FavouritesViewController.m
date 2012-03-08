//
//  FirstViewController.m
//  NextGRT
//
//  Created by Yuanfeng on 12-01-13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#import "FavouritesViewController.h"

#import "FavouriteStopsCentralManager.h"

#import "AppDelegate.h"

@implementation FavouritesViewController

@synthesize favStopsDict;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
//        self.title = NSLocalizedString(@"First", @"First");
//        self.tabBarItem.image = [UIImage imageNamed:@"first"];
        self.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:1];
        self.title = @"Next GRT";
        
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
    }
    return self;
}
							
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Notification selector
- (void) updateView
{
    if([_favStops count] != 0 ) {
        self.navigationItem.leftBarButtonItem.enabled = YES;
        if( !_favStopsTableVC ) {
            _favStopsTableVC = [[BusStopBaseTableViewController alloc] initWithTableWidth:self.view.frame.size.width Height:self.view.frame.size.height Stops:_favStops];
            _favStopsTableVC.forFavStopVC = YES;
            _favStopsTableVC.customDelegate = self;
            [self.view addSubview:_favStopsTableVC.tableView];
            
            _favStopsTableVC.tableView.hidden = YES;
            CATransition *fade = [CATransition animation];
            [fade setDuration:0.6f];
            [fade setType:kCATransitionReveal];
            //[fade setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
            [_favStopsTableVC.tableView.layer addAnimation:fade forKey:@"fadeAnimation"];
            _favStopsTableVC.tableView.hidden = NO;
            
            _favStopsTableVC.tableView.backgroundColor = UITableBackgroundColor;
            
            //now we need to register this VC as a observer to "FavStopArrayDidUpdate" notification to reload fav stops
            //favTableContainer_.hidden = NO;
        } else {
            _favStopsTableVC.stops = _favStops;
            [_favStopsTableVC.tableView reloadData];
        }
    } else {
        _favStopsTableVC.view.hidden = YES;
        _welcomeHint.hidden = NO;
    }
}

- (void) busRoutesForAllStopsReceived
{
    [self updateView];
}

- (void) stopInfoArrayReceived:(NSMutableArray*)stops {
    _favStops = stops;
    if( [_favStops count] != 0 ) 
    {
        [[GRTDatabaseManager sharedManager] queryBusRoutesForStops:_favStops withDelegate:self];
    }
}

- (void) loadFavStopTable {
    //TODO mem management issue when it comes to ordering of the cells
    self.favStopsDict = [[FavouriteStopsCentralManager sharedInstance] getFavoriteStopDict];
    if ([self.favStopsDict count]>0) {
        _welcomeHint.hidden = YES;
        _favStopsTableVC.tableView.hidden = NO;
        NSMutableArray* stopIDs = [[NSMutableArray alloc] init];
        for( NSDictionary* dict in self.favStopsDict ) {
            [stopIDs addObject:[dict objectForKey:STOP_ID_KEY]];
        }
        
        [[GRTDatabaseManager sharedManager] queryStopIDs:stopIDs withDelegate:self groupByStopName:NO];
    } else
    {
        _welcomeHint.hidden = NO;
        [_favStops removeAllObjects];
        _favStopsTableVC.stops = _favStops;
        _favStopsTableVC.tableView.hidden = YES;
        [_favStopsTableVC.tableView reloadData];
    }
}

#pragma mark - BarItem Target
- (void)openMap:(UIButton*)btn
{
    NSString *defaultLatLong = @"43.472737,-80.541206";//UW Davis
    CLLocation *currLocation = [AppDelegate sharedLocationManager].location;
    if (currLocation) {
        defaultLatLong = [NSString stringWithFormat:@"%f,%f", currLocation.coordinate.latitude, currLocation.coordinate.longitude];
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://maps.google.com/maps?ll=%@", defaultLatLong]]];
}

- (void)initEditButton:(BOOL)animated
{
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonClicked:)];
    [self.navigationItem setRightBarButtonItem:editItem animated:animated];
    
    //add a open map item
    /*
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"map2"] forState:UIControlStateNormal];
    [button setImageEdgeInsets:UIEdgeInsetsMake(1, 4, 0, 0)];
    button.showsTouchWhenHighlighted = YES;
    button.frame = CGRectMake(0, 0, 35, 32);
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button]; 
    [button addTarget:self action:@selector(openMap:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:item animated:animated];
     */
}

- (void)doneButtonClicked:(id)sender
{
    [self initEditButton:YES];  
    [[FavouriteStopsCentralManager sharedInstance] saveFavStops];
    [_favStopsTableVC setEditing:NO animated:YES];
}

- (void)editButtonClicked:(id)sender
{
    if (_favStopsTableVC) {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonClicked:)];
        [self.navigationItem setRightBarButtonItem:doneButton animated:YES];
        [_favStopsTableVC foldAllStops];
        [_favStopsTableVC setEditing:YES animated:YES];
    }
    StatusBarMsgAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate showMessageAtStatusBarWithText:local(@"Tab a stop to change nickname") duration:3.3f animated:YES];
}

#pragma mark - BusStopTableView Delegate
- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[FavouriteStopsCentralManager sharedInstance] deleteFavoriteStopAtIndex:[indexPath row]];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [[FavouriteStopsCentralManager sharedInstance] moveStopAtIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
}

#pragma mark - View lifecycle
- (void)scheduleLocalNotification
{
    /* Here we cancel all previously scheduled notifications */
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
    //    NSLog(@"Notification will be shown on: %@",localNotification.fireDate);
    
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.alertBody = [NSString stringWithFormat:
                                   @"Your notification message"];
    localNotification.hasAction = YES;
    localNotification.alertAction = NSLocalizedString(@"View details", nil);
    
    /* Here we set notification sound and badge on the app's icon "-1" 
     means that number indicator on the badge will be decreased by one 
     - so there will be no badge on the icon */
    
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = UITableBackgroundColor;
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
	// Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadFavStopTable) name:kFavStopArrayDidUpdate object:nil];
    //now load the list of fav stops
    [self loadFavStopTable];
    
    //[self scheduleLocalNotification];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFavStopArrayDidUpdate object:nil];
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
    if (!_favStopsTableVC.isEditing) {
        [self initEditButton:YES]; //TODO: shouldn't show edit when no entry
    }
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
