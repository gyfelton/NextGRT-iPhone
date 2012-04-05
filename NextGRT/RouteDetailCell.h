//
//  RouteDetailCell.h
//  GRTEasyGo
//
//  Created by Yuanfeng on 11-07-11.
//  Copyright 2011 Elton(Yuanfeng) Gao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MarqueeLabel.h"
#import "AutoScrollLabel.h"

/**
 * A UITableViewCell subclass showing info of each route for each bus stop
 */
@interface RouteDetailCell : UITableViewCell {
    UIImageView* busIcon_;
    //UILabel* routeNumber_;
    AutoScrollLabel *routeNumber_;
    UILabel* nextBusIn_;
    UILabel* _subsequentBusIn;
    UILabel* firstTime_;
    UILabel* secondTime_;
}

/**
 * AutoScrollable routeNumber          route number and its headsign
 * can be long so make it auto-scrollable
 */
@property (nonatomic, strong) AutoScrollLabel* routeNumber;

/**
 * UILabel firstTime/SecondTime        
 * Showing two arrival times for each route
 * Fully customizable
 */
@property (nonatomic, strong) UILabel* firstTime;
@property (nonatomic, strong) UILabel* secondTime;

@end
