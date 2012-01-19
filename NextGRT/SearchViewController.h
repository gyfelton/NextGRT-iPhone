//
//  SecondViewController.h
//  NextGRT
//
//  Created by Yuanfeng on 12-01-13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "BusStopsPullToRefreshTableViewController.h"
#import "GRTDatabaseManager.h"

@interface SearchViewController : UIViewController <CLLocationManagerDelegate, PullToRefreshTableDelegate, UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate>
{
    //IBOutlet UITableView* stopsList;
    IBOutlet UISearchBar* _searchBar;
    
    IBOutlet UIActivityIndicatorView* _loadingIndicator;
    IBOutlet UILabel* _mainTitle;
    IBOutlet UITextView* _quickSearch;
    
    IBOutlet UIView* _tableContainer;
    BusStopsPullToRefreshTableViewController* _stopTableVC;
    UISearchDisplayController* _searchDisplayVC;
    
    BOOL _searchTextReachCriteria;
    BOOL _searchResultsReturned;
    //used to disable load more button in search result view
    BOOL _areNearbyStops;
    
    CLLocationManager* _locationManager;
    CLLocation* _currLocation;
    double _currSearchRadiusFactor;
    IBOutlet UISwitch* _locationUpdateSwitch;
}

@property (nonatomic, strong) NSMutableArray* stops;
@property (nonatomic, strong) NSMutableArray* searchResults;

@end
