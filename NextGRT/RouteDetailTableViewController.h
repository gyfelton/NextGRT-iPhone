//
//  RouteDetailTableViewController.h
//  NextGRT
//
//  Created by Yuanfeng on 12-04-24.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Stop.h"
#import "UserTouchCaptureView.h"

@interface RouteDetailTableViewController : UITableViewController
{
    Stop *_stop;
    NSMutableArray *_detailCellTimerOverlay;
}

/**
 *Remove all timer UI it puts on its superview
 */
- (void)removeAllTimerOverlayFromSuperView;

/**
 * UITableViewController parentTableViewController
 * link between the cell and its tableViewController for putting timer on it
 */
@property (nonatomic, unsafe_unretained) UITableViewController *parentTableViewController;

@property (nonatomic, unsafe_unretained) id<UserTouchEventDelegate> userTouchEventDelegate;

@property (nonatomic, strong) Stop *stop;
/**
 * An array of timer UI overlay
 * readonly
 */
@property (nonatomic, readonly) NSMutableArray *detailCellTimerOverlay;

@end
