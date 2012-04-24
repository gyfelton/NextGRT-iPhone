//
//  SecondViewController.h
//  NextGRT
//
//  Created by Yuanfeng on 12-01-13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>
#import "BusStopsPullToRefreshTableViewController.h"
#import "GRTDatabaseManager.h"
#import "MBProgressHUD.h"
#import "RouteDetailTableViewController.h"

@interface SearchViewController : UIViewController <CLLocationManagerDelegate, PullToRefreshTableDelegate, UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate, GRTDatabaseManagerDelegate, BusStopBaseTabeViewDelegate, MKMapViewDelegate>
{
    //IBOutlet UITableView* stopsList;
    IBOutlet UISearchBar* _searchBar;
    
    IBOutlet UIView* _tableContainer;
    BusStopsPullToRefreshTableViewController* _stopTableVC;
    UISearchDisplayController* _searchDisplayVC;
    
    IBOutlet UIButton *_hintButton;
    
    BOOL _searchTextReachCriteria;
    BOOL _searchResultsReturned;
    //used to disable load more button in search result view
    BOOL _areNearbyStops;
    
    MBProgressHUD *_hud;
    
    CLLocationManager* _locationManager;
    CLLocation* _currLocation;
    double _currSearchRadiusFactor;
    
    //--------------
    //The following is for map mode only
    //--------------
    IBOutlet UIToolbar *_mapTogglerBaseForList;
    IBOutlet UIToolbar *_mapTogglerBaseForMap;
    IBOutlet UISegmentedControl *_segmentControl;
    IBOutlet UIView *_mapBaseView;
    
    IBOutlet MKMapView *_mapView;
    
    UIButton *_mapViewTopBtn;
    UIImageView *_arrowUp;
    UIImageView *_lowerPartImageView;
    UIImageView *_topShadow;
    UIImageView *_bottomShadow;
    RouteDetailTableViewController *_routeDetailTableVC;
    
    BOOL _isShowingDetailTable;
    
    MKAnnotationView *_currentAnnotationView;
    
    float _routeDetailTableHeightOffset;
}

- (IBAction)segmentControlValueChanged:(UISegmentedControl*)segmentControl;
@property (nonatomic, strong) NSMutableArray* stops;
@property (nonatomic, strong) NSMutableArray* searchResults;

@end
