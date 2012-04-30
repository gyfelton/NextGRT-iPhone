//  BusStopsPullToRefreshLoadMoreTableViewController.h
//
//  Created by Jesse Collis on 1/07/10.
//  Copyright 2010 JC Multimedia Design. All rights reserved.
//
//  source: https://github.com/jessedc/EGOTableViewPullRefresh
//
//  Modified by Elton(Yuanfeng) Gao. All rihgts reserved
//  Does not inherit from original class as objective-C does not support multiple inheritance
//  Support pull down to reload location

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "BusStopBaseTableViewController.h"

#define NEED_MORE_BUTTON_HEIGHT 60

@protocol PullToRefreshTableDelegate <NSObject>

@optional
- (void) requestForNewGeoLocation;
- (void) requestForMoreStops;

@end

/**
 * This is a subclass of BusStopBaseTableViewController to add Pull-to-refresh ability
 * because multiple inheritance is not allowed in Obj-C
 */
@interface BusStopsPullToRefreshTableViewController : BusStopBaseTableViewController {
	EGORefreshTableHeaderView *refreshHeaderView;

	BOOL _reloading;
}

/**
 * init a new UITableViewController with the following parameters
 * @param CGFloat width/height
 * @param NSMutableArray s      Array of Stops to show, allow empty array
 * @param id delegate           Delegate for PullToRefreshTableDelegate
 * @param BOOL needMore         Indicate whether "load more" button is needed at the end of table
 * @return A newly init BusStopsPullToRefreshTableViewController
 */
 
- (id)initWithTableWidth:(CGFloat)width Height:(CGFloat)height 
                   Stops:(NSMutableArray*)s andDelegate:(id)object
                   needLoadMoreStopsButton:(BOOL) needMore;

@property(assign,getter=isReloading) BOOL reloading;
@property(nonatomic,readonly) EGORefreshTableHeaderView *refreshHeaderView;
@property (nonatomic, assign) id<PullToRefreshTableDelegate> delegate;

@property BOOL needLoadMoreButton;
@property BOOL isAskingForManualLocation;
/** 
 * require to reload data and hide the loading screen
 */
- (void)reloadDataAndStopLoadingAnimation;

/**
 * user informs that he requires table data
 */
- (void)reloadTableViewDataSource;

/**
 * Datasource tells table that it has finished getting data
 */
- (void)dataSourceDidFinishLoadingNewData;

@end
