//
//  BusStopBaseTableViewController.h
//  GRTEasyGo
//
//  Created by Yuanfeng on 11-07-15.
//  Copyright 2011 Elton(Yuanfeng) Gao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullToRefreshTableViewController.h"

#define UNOPENED_CELL_HEIGHT 65
#define OPENED_CELL_HEIGHT_BASE 91
#define OPENED_CELL_INTERNAL_CELL_HEIGHT 65

@class Stop;

@protocol BusStopBaseTabeViewDelegate <NSObject>
@optional
- (void)tableView:(UITableView *)tableView  commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface BusStopBaseTableViewController : UITableViewController {
    bool gotTimer;
    NSTimer* timer_;
    NSIndexPath* selectedCellIndexPath_;
}

@property BOOL forFavStopVC;
@property (nonatomic, retain) NSMutableArray* stops;
@property (nonatomic, assign) id<BusStopBaseTabeViewDelegate> customDelegate;

- (id)initWithTableWidth:(CGFloat)width Height:(CGFloat)height Stops:(NSMutableArray*)s;
- (void)foldAllStops;

@end
