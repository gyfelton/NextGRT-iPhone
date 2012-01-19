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
#define OPENED_CELL_HEIGHT_BASE 98
#define OPENED_CELL_INTERNAL_CELL_HEIGHT 65

@class Stop;

@interface BusStopBaseTableViewController : UITableViewController {
    bool gotTimer;
    NSTimer* timer_;
    NSIndexPath* selectedCellIndexPath_;
}

- (id)initWithTableWidth:(CGFloat)width Height:(CGFloat)height Stops:(NSMutableArray*)s;

@property (nonatomic, retain) NSMutableArray* stops;

@end
