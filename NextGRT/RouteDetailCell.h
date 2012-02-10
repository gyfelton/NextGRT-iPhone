//
//  RouteDetailCell.h
//  GRTEasyGo
//
//  Created by Yuanfeng on 11-07-11.
//  Copyright 2011 Elton(Yuanfeng) Gao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MarqueeLabel.h"

@interface RouteDetailCell : UITableViewCell {
    UIImageView* busIcon_;
    MarqueeLabel* routeNumber_;
    
    UILabel* nextBusIn_;
    UILabel* _subsequentBusIn;
    UILabel* firstTime_;
    UILabel* secondTime_;
    //UILabel* nextBusDirection_; //direction now merge with route number
}

@property (nonatomic, strong) MarqueeLabel* routeNumber;
@property (nonatomic, strong) UILabel* firstTime;
@property (nonatomic, strong) UILabel* secondTime;
//@property (nonatomic, assign) UILabel* nextBusDirection;
@end
