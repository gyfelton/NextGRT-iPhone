//
//  BusStopBaseTableViewController.h
//  GRTEasyGo
//
//  Created by Yuanfeng on 11-07-15.
//  Copyright 2011 Elton(Yuanfeng) Gao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullToRefreshTableViewController.h"
#import "MBProgressHUD.h"
#import "UserTouchCaptureView.h"

#define UNOPENED_CELL_HEIGHT 65
#define OPENED_CELL_HEIGHT_BASE 91
#define OPENED_CELL_INTERNAL_CELL_HEIGHT 65

@class Stop;

@protocol BusStopBaseTabeViewDelegate <NSObject>
@optional
- (void)tableView:(UITableView *)tableView  commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
//- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section;
//- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section;
@end

@interface BusStopBaseTableViewController : UITableViewController<UserTouchEventDelegate> {
    MBProgressHUD *_hud;
    bool gotTimer;
    NSDate *_todayDate; //to keep track of whether the day has gone to tmr
    NSTimer *_timerForUpdateTimeAndRefreshView;
    NSIndexPath* selectedCellIndexPath_;
}

@property BOOL forFavStopVC;
@property (nonatomic, retain) NSMutableArray* stops;
@property (nonatomic, assign) id<BusStopBaseTabeViewDelegate> customDelegate;

- (id)initWithTableWidth:(CGFloat)width Height:(CGFloat)height Stops:(NSMutableArray*)s;
- (void)foldAllStops;

@end
