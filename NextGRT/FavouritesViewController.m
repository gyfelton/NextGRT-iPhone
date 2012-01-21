//
//  FirstViewController.m
//  NextGRT
//
//  Created by Yuanfeng on 12-01-13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FavouritesViewController.h"

#import "FavouriteStopsCentralManager.h"

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
            _favStopsTableVC.customDelegate = self;
            [self.view addSubview:_favStopsTableVC.tableView];
            _favStopsTableVC.tableView.backgroundColor = UITableBackgroundColor;
            
            //now we need to register this VC as a observer to "FavStopArrayDidUpdate" notification to reload fav stops
            //favTableContainer_.hidden = NO;
        } else {
            _favStopsTableVC.stops = _favStops;
            [_favStopsTableVC.tableView reloadData];
        }
    } else {
        //favTableContainer_.hidden = YES;
        _favStopsTableVC.view.hidden = YES;
    }
}

- (void) busRoutesForAllStopsReceived
{
    [self performSelectorOnMainThread:@selector(updateView) withObject:nil waitUntilDone:NO];
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
        _mainTitle.hidden = YES;
        _secTitle.hidden = YES;
        
        NSMutableArray* stopIDs = [[NSMutableArray alloc] init];
        for( NSDictionary* dict in self.favStopsDict ) {
            [stopIDs addObject:[dict objectForKey:STOP_ID_KEY]];
        }
        
        [[GRTDatabaseManager sharedManager] queryStopIDs:stopIDs withDelegate:self groupByStopName:NO];
    }
}

#pragma mark - BarItem Target

- (void)initEditButton:(BOOL)animated
{
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonClicked:)];
    [self.navigationItem setLeftBarButtonItem:editItem animated:YES];
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
        [self.navigationItem setLeftBarButtonItem:doneButton animated:YES];
        [_favStopsTableVC foldAllStops];
        [_favStopsTableVC setEditing:YES animated:YES];
    }
}

#pragma mark - BusStopTableView Delegate
- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([[FavouriteStopsCentralManager sharedInstance] deleteFavoriteStopAtIndex:[indexPath row]] )
        {
            //need refractor!
            _favStopsTableVC.stops = self.favStopsDict; //should point directly to sharedManager instance
        }
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationMiddle];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [[FavouriteStopsCentralManager sharedInstance] swapStopAtIndex:sourceIndexPath.row withIndex:destinationIndexPath.row];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initEditButton:NO];
    self.view.backgroundColor = UITableBackgroundColor;
    
    self.navigationItem.leftBarButtonItem.enabled = NO;
	// Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadFavStopTable) name:kFavStopArrayDidUpdate object:nil];
    //now load the list of fav stops
    [self loadFavStopTable];
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
