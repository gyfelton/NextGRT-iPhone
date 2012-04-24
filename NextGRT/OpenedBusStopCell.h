//
//  OpenedBusStopCell.h
//  GRTEasyGo
//
//  Created by Yuanfeng on 11-06-30.
//  Copyright 2011 Elton(Yuanfeng) Gao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BusStopCellBaseClass.h"
#import "RouteDetailTableViewController.h"

@class Stop;

/**
 * Cubsclass of BusStopBaseCell containing more information of a cell after it is expanded by the user
 */
@interface OpenedBusStopCell : BusStopCellBaseClass {
    //UITable showing bus stops and routes
    RouteDetailTableViewController* _detailTableVC;
    
    //UILabel* distanceFromCurrPosition_;
    
    NSTimeInterval timeElapsed_;
}

/**
 *Remove all timer UI it puts on its superview
 */
- (void)removeAllTimerOverlayFromSuperView;

/**
 * id<UserTouchEventDelegate> parentViewController
 * link between the cell and its viewController for putting timer on it
 */
@property (nonatomic, unsafe_unretained) id<UserTouchEventDelegate> parentViewController;
@end
