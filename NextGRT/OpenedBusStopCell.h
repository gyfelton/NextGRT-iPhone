//
//  OpenedBusStopCell.h
//  GRTEasyGo
//
//  Created by Yuanfeng on 11-06-30.
//  Copyright 2011 Elton(Yuanfeng) Gao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BusStopCellBaseClass.h"

@class Stop;

/**
 * Cubsclass of BusStopBaseCell containing more information of a cell after it is expanded by the user
 */
@interface OpenedBusStopCell : BusStopCellBaseClass <UITableViewDelegate, UITableViewDataSource> {
    //UITable showing bus stops and routes
    UITableView* detailTable_;
    
    //UILabel* distanceFromCurrPosition_;
    
    NSTimeInterval timeElapsed_;
    
    NSMutableArray *_detailCellTimerOverlay;
}

/**
 *Remove all timer UI it puts on its superview
 */
- (void)removeAllTimerOverlayFromSuperView;

/**
 * An array of timer UI overlay
 * readonly
 */
@property (nonatomic, readonly) NSMutableArray *detailCellTimerOverlay;

/**
 * UITableViewController parentTableViewController
 * link between the cell and its tableViewController for putting timer on it
 */
@property (nonatomic, unsafe_unretained) UITableViewController *parentTableViewController;
@end
