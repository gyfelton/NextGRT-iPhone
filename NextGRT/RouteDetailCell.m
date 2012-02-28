//
//  RouteDetailCell.m
//  GRTEasyGo
//
//  Created by Yuanfeng on 11-07-11.
//  Copyright 2011 Elton(Yuanfeng) Gao. All rights reserved.
//

#import "RouteDetailCell.h"

#define BUS_ICON_LEFT_OFFSET 6
#define BUS_ICON_WIDTH 50
#define BUS_ICON_HEIGHT 50
#define ROUTE_NUM_WIDTH 230
#define ROUTE_NUM_HEIGHT 30
#define FIRST_TIME_WIDTH 163
#define FIRST_TIME_HEIGHT 30

@implementation RouteDetailCell

@synthesize routeNumber = routeNumber_, firstTime = firstTime_, secondTime = secondTime_; //, nextBusDirection = nextBusDirection_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        busIcon_ = [[UIImageView alloc] initWithFrame:CGRectMake(BUS_ICON_LEFT_OFFSET, 5, BUS_ICON_WIDTH, BUS_ICON_HEIGHT)];
        busIcon_.image = [UIImage imageNamed:@"btnBus_64x64"];
        [self.contentView addSubview:busIcon_];
        
//        UIScrollView *slider = [[UIScrollView alloc] initWithFrame:CGRectMake(BUS_ICON_LEFT_OFFSET, 5, 290, BUS_ICON_HEIGHT)];
//        busIcon_.frame = CGRectMake(0, 0, busIcon_.frame.size.width, busIcon_.frame.size.height);
//        slider.contentSize = CGSizeMake(600, slider.frame.size.height);
//        slider.scrollEnabled = YES;
//        slider.contentOffset = CGPointMake(-30, 0);
//        slider.maximumZoomScale = 1.0f;
//        slider.backgroundColor = [UIColor redColor];
//        [slider addSubview:busIcon_];
        
        routeNumber_ = [[MarqueeLabel alloc] initWithFrame:CGRectMake( busIcon_.bounds.origin.x + BUS_ICON_WIDTH + 8, 4, ROUTE_NUM_WIDTH, ROUTE_NUM_HEIGHT) andSpeed:3 andBuffer:3.0f];
        routeNumber_.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
        routeNumber_.text = @"12";
        routeNumber_.textAlignment = UITextAlignmentLeft;
        routeNumber_.font = [UIFont boldSystemFontOfSize:18];
        routeNumber_.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:routeNumber_];
        
//        nextBusDirection_ = [[[UILabel alloc] initWithFrame:CGRectMake( busIcon_.bounds.origin.x + BUS_ICON_WIDTH + 20, ROUTE_NUM_HEIGHT + 3, 200, 20)] retain];
//        nextBusDirection_.font = [UIFont systemFontOfSize:14];
//        [self addSubview:nextBusDirection_];
        
        nextBusIn_  = [[UILabel alloc] initWithFrame:CGRectMake(busIcon_.bounds.origin.x + BUS_ICON_WIDTH + 10, ROUTE_NUM_HEIGHT-10, 62, FIRST_TIME_HEIGHT)];
        nextBusIn_.text = local(@"next bus: ");
        nextBusIn_.font = [UIFont systemFontOfSize:14];
        nextBusIn_.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:nextBusIn_];
        
        firstTime_ = [[UILabel alloc] initWithFrame:CGRectMake(nextBusIn_.frame.origin.x + nextBusIn_.frame.size.width, ROUTE_NUM_HEIGHT-10, FIRST_TIME_WIDTH, FIRST_TIME_HEIGHT)];
        firstTime_.text = @"test";
        firstTime_.adjustsFontSizeToFitWidth = YES;
        firstTime_.font = [UIFont boldSystemFontOfSize:18];
        firstTime_.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:firstTime_];
        
        _subsequentBusIn = [[UILabel alloc] initWithFrame:nextBusIn_.frame];
        _subsequentBusIn.text = local(@"subsequent bus:");
        _subsequentBusIn.font = [UIFont systemFontOfSize:14];
        _subsequentBusIn.frame = CGRectMake(_subsequentBusIn.frame.origin.x, ROUTE_NUM_HEIGHT+8, [_subsequentBusIn.text sizeWithFont:_subsequentBusIn.font].width, _subsequentBusIn.frame.size.height);
        _subsequentBusIn.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_subsequentBusIn];
        
        secondTime_ = [[UILabel alloc] initWithFrame:CGRectMake(_subsequentBusIn.frame.origin.x + _subsequentBusIn.frame.size.width + 12, ROUTE_NUM_HEIGHT+8, FIRST_TIME_WIDTH, FIRST_TIME_HEIGHT)];
        secondTime_.text = @"test";
        secondTime_.font = [UIFont systemFontOfSize:14];
        secondTime_.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:secondTime_];
        
        firstTime_.shadowOffset = CGSizeMake(0, 1);
        firstTime_.shadowColor = [UIColor whiteColor];
//        secondTime_.shadowOffset = CGSizeMake(0, 1);
//        secondTime_.shadowColor = [UIColor whiteColor];
//        _subsequentBusIn.shadowOffset = CGSizeMake(0, 1);
//        _subsequentBusIn.shadowColor = [UIColor whiteColor];
        routeNumber_.shadowOffset = CGSizeMake(0, 1);
        routeNumber_.shadowColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint pt = [touch locationInView:busIcon_];
}
@end
