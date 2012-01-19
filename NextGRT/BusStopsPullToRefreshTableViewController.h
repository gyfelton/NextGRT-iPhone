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

@interface BusStopsPullToRefreshTableViewController : BusStopBaseTableViewController {
	EGORefreshTableHeaderView *refreshHeaderView;

	BOOL _reloading;
}

- (id)initWithTableWidth:(CGFloat)width Height:(CGFloat)height 
                   Stops:(NSMutableArray*)s andDelegate:(id)object
                   needLoadMoreStopsButton:(BOOL) needMore;

@property(assign,getter=isReloading) BOOL reloading;
@property(nonatomic,readonly) EGORefreshTableHeaderView *refreshHeaderView;
@property (nonatomic, assign) id<PullToRefreshTableDelegate> delegate;

@property BOOL needLoadMoreButton;


- (void)reloadDataAndStopLoadingAnimation;
- (void)reloadTableViewDataSource;
- (void)dataSourceDidFinishLoadingNewData;

@end
