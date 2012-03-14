//
//  UnopenedBusStopCell.m
//  GRTEasyGo
//
//  Created by Yuanfeng on 11-06-29.
//  Copyright 2011 Elton(Yuanfeng) Gao. All rights reserved.
//

#import "UnopenedBusStopCell.h"
#import "Stop.h"
#import "BusRoute.h"

#define BUTTON_SIZE_WIDTH 320
#define BUTTON_SIZE_HEIGHT 17

@implementation UnopenedBusStopCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //give three blank label for route number and time
        //routesAndTimes_ = [[NSMutableArray alloc] init];
//        for (int i=0; i<3; i++) {
//            UILabel* label = [[[UILabel alloc] initWithFrame:CGRectMake(INSET_LEFT + BUTTON_SIZE_WIDTH*i, NAME_HEIGHT+EXTRA_INFO_HEIGHT + 5, BUTTON_SIZE_WIDTH, BUTTON_SIZE_HEIGHT)] autorelease];
//            label.textAlignment = UITextAlignmentLeft;
//            label.font = [UIFont systemFontOfSize:EXTRA_INFO_FONT_SIZE];
//            [routesAndTimes_ addObject:label];
//            [self addSubview:label];
//        }

    }
    return self;
}

- (void)initCellInfoWithStop:(Stop*)stop{
//    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    [super initCellInfoWithStop:stop];
    
    [self refreshRoutesInCell];
}

- (void)refreshRoutesInCell{
    [super refreshRoutesInCell];
}

//- (void) refreshRoutesTimes:(NSTimeInterval) timeElapsed {
//    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"HH'h'MM'min"];
//    for (int i=0; i<2; i++) {
//        UILabel* label = [routesAndTimes_ objectAtIndex:i];
//        NSDate* time = [formatter dateFromString:label.text];
//        NSTimeInterval newInterval = [time timeIntervalSince1970] - timeElapsed;
//        [label setText:[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:newInterval]]];
//    }
//}

- (void)dealloc
{
}

@end
