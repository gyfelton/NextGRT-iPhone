//
//  OpenedBusStopCell.m
//  GRTEasyGo
//
//  Created by Yuanfeng on 11-06-30.
//  Copyright 2011 Elton(Yuanfeng) Gao. All rights reserved.
//

#import "OpenedBusStopCell.h"
#import "BusRoute.h"
#import "RouteDetailCell.h"
#import "BusStopBaseTableViewController.h"
#import "UserTouchCaptureView.h"

@implementation OpenedBusStopCell

@synthesize parentViewController;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //insert a grouped table showing detailed buses and stops
        self.clipsToBounds = YES;

        _detailTableVC = [[RouteDetailTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
        
        //Need to disable autoresize or the table will behave very strange!
        _detailTableVC.tableView.autoresizingMask -= UIViewAutoresizingFlexibleHeight;
        
        _detailTableVC.userTouchEventDelegate = self.parentViewController;
        _detailTableVC.tableView.frame = CGRectMake(0, NAME_HEIGHT + EXTRA_INFO_HEIGHT + 32, self.contentView.frame.size.width, 145);
//        detailTable_.layer.cornerRadius = 5.0f;
        
        //disable this to let cell collapse even user touches on the detail table
         _detailTableVC.tableView.userInteractionEnabled = NO;
        
         _detailTableVC.tableView.scrollEnabled = NO;
         _detailTableVC.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        UIImage *bgImg = [UIImage imageNamed:@"route_detail_bg_shadow"];
        bgImg = [bgImg stretchableImageWithLeftCapWidth:0 topCapHeight:0];
         _detailTableVC.tableView.backgroundView = [[UIImageView alloc] initWithImage:bgImg];
        
        UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"route_detail_arrow_shadow"]];
        arrow.center = CGPointMake(self.contentView.center.x, 0);
        arrow.frame = CGRectMake(arrow.frame.origin.x,  _detailTableVC.tableView.frame.origin.y-arrow.frame.size.height, arrow.frame.size.width, arrow.frame.size.height);
        [self.contentView addSubview:arrow];
        
        //[self addSubview:distanceFromCurrPosition_];
        [self.contentView addSubview: _detailTableVC.tableView];
    }
    return self;
}

- (void)refreshRoutesInCell {   
    [super refreshRoutesInCell];
    int distance = [_stop distanceFromCurrPositionInMeter];
    if( distance != -1 ) {
        availableRoutes_.text = [NSString stringWithFormat:local(@"Distance from here: %dm"), distance];
        availableRoutes_.font = [UIFont boldSystemFontOfSize:EXTRA_INFO_FONT_SIZE];
    } else {
        availableRoutes_.font = [UIFont systemFontOfSize:EXTRA_INFO_FONT_SIZE];
    }
    _detailTableVC.stop = _stop;
    [_detailTableVC.tableView reloadData];
}

- (void)initCellInfoWithStop:(Stop*)stop{
    [super initCellInfoWithStop:stop];
    _stop = stop;
    timeElapsed_ = 0;
    //need to adjust frame of detailTable based on number of routes
    _detailTableVC.tableView.frame = CGRectMake(_detailTableVC.tableView.frame.origin.x, _detailTableVC.tableView.frame.origin.y, _detailTableVC.tableView.frame.size.width, [_stop.busRoutes count]*OPENED_CELL_INTERNAL_CELL_HEIGHT + 20);
    NSLog(@"%d", [_stop.busRoutes count]);
    [self refreshRoutesInCell];
}

- (void)removeAllTimerOverlayFromSuperView
{
    [_detailTableVC removeAllTimerOverlayFromSuperView];
}

- (void)setParentViewController:(id<UserTouchEventDelegate>)parentVC
{
    parentViewController = parentVC;
    _detailTableVC.userTouchEventDelegate = parentViewController;
}

- (void)dealloc
{
}

@end
