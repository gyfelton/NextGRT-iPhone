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

@interface OpenedBusStopCell : BusStopCellBaseClass <UITableViewDelegate, UITableViewDataSource> {
    //UITable showing bus stops and routes
    UITableView* detailTable_;
    
    //UILabel* distanceFromCurrPosition_;
    
    NSTimeInterval timeElapsed_;
}

@end
