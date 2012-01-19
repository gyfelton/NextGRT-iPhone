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

@implementation OpenedBusStopCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //insert a grouped table showing detailed buses and stops
        self.clipsToBounds = YES;
        
        detailTable_ = [[UITableView alloc] initWithFrame:CGRectMake(0, NAME_HEIGHT + EXTRA_INFO_HEIGHT + 5 + 32, self.contentView.frame.size.width, 145) style:UITableViewStyleGrouped];
//        detailTable_.layer.cornerRadius = 5.0f;
        detailTable_.userInteractionEnabled = NO;
        detailTable_.scrollEnabled = NO;
        detailTable_.delegate = self;
        detailTable_.dataSource = self;
        detailTable_.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        UIImage *bgImg = [UIImage imageNamed:@"route_detail_bg"];
        bgImg = [bgImg stretchableImageWithLeftCapWidth:0 topCapHeight:16];
        detailTable_.backgroundView = [[UIImageView alloc] initWithImage:bgImg];
        
        UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"route_detail_arrow"]];
        arrow.center = CGPointMake(self.contentView.center.x, 0);
        arrow.frame = CGRectMake(arrow.frame.origin.x, detailTable_.frame.origin.y-arrow.frame.size.height*0.8, arrow.frame.size.width*0.8, arrow.frame.size.height*0.8);
        [self.contentView addSubview:arrow];
        
        //[self addSubview:distanceFromCurrPosition_];
        [self.contentView addSubview:detailTable_];
    }
    return self;
}

- (void)refreshRoutesInCellWithSeconds:(NSTimeInterval) seconds {   
    [super refreshRoutesInCellWithSeconds:seconds];
    int distance = [stop_ distanceFromCurrPositionInMeter];
    if( distance != -1 ) {
        availableRoutes_.text = [NSString stringWithFormat:@"Distance from here: %dm", distance];
    } else {
        //        availableRoutes_.text = @"";
    }
    [detailTable_ reloadData];
}

- (void)initCellInfoWithStop:(Stop*)stop{
    [super initCellInfoWithStop:stop];
    stop_ = stop;
    timeElapsed_ = 0;
    //need to adjust frame of detailTable based on number of routes
    detailTable_.frame = CGRectMake(detailTable_.frame.origin.x, detailTable_.frame.origin.y, detailTable_.frame.size.width, [stop_.busRoutes count]*OPENED_CELL_INTERNAL_CELL_HEIGHT + 20);
    [detailTable_ reloadData];
    [self refreshRoutesInCellWithSeconds:0];
}

#pragma mark - UITable DataSource

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    NSLog(@"heighFor gets called %d", section);
//    int distance = [stop_ distanceFromCurrPositionInMeter];
//    if( distance != -1 ) {
//        return -1;
//    } else {
//        return 0;
//    }
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return OPENED_CELL_INTERNAL_CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
//    int distance = [stop_ distanceFromCurrPositionInMeter];
//    if( distance != -1 ) {
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.height, 30)];
//        label.text = [NSString stringWithFormat:@"Distance from here: %dm", distance];
//        return label;
//    } else {
//        return nil;
//    }
    return nil;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //NSLog(@"%d", [stop_.busRoutes count]);
    return [stop_.busRoutes count];//>3?3:[stop_.busRoutes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [detailTable_ dequeueReusableCellWithIdentifier:@"detailCell"];
    if( !cell ) {
        cell = [[RouteDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"detailCell"];
    }
    BusRoute* route = [stop_.busRoutes objectAtIndex:[indexPath row]];
    
    ((RouteDetailCell*)cell).routeNumber.text = [NSString stringWithFormat:@"%@ %@", route.fullRouteNumber, [route getNextBusDirection]];
    ((RouteDetailCell*)cell).firstTime.text = [route getFirstArrivalTime];
    ((RouteDetailCell*)cell).secondTime.text = [route getSecondArrivalTime];
    //((RouteDetailCell*)cell).nextBusDirection.text = [NSString stringWithFormat:@"To: %@", [route getNextBusDirection]];
    return cell;
}

- (void)dealloc
{
}

@end
