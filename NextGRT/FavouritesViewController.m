//
//  FirstViewController.m
//  NextGRT
//
//  Created by Yuanfeng on 12-01-13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FavouritesViewController.h"

#import "FavouriteStopsCentralManager.h"

#import "GRTDatabaseManager.h"

@implementation FavouritesViewController

@synthesize favStopsDict;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"First", @"First");
//        self.tabBarItem.image = [UIImage imageNamed:@"first"];
        self.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:1];
        self.title = @"Next GRT";
    }
    return self;
}
							
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Notification selector
- (void) loadFavStopTable {
    //TODO mem management issue when it comes to ordering of the cells
    self.favStopsDict = [[FavouriteStopsCentralManager sharedInstance] getFavoriteStopDict];
    NSMutableArray* stopIDs = [[NSMutableArray alloc] init];
    for( NSDictionary* dict in self.favStopsDict ) {
        [stopIDs addObject:[dict objectForKey:STOP_ID_KEY]];
    }
    [[GRTDatabaseManager sharedManager] queryStopIDs:stopIDs withDelegate:self groupByStopName:NO];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadFavStopTable) name:kFavStopArrayDidUpdate object:nil];
    //now load the list of fav stops
    [self loadFavStopTable];
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
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
