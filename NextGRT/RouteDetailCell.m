//
//  RouteDetailCell.m
//  GRTEasyGo
//
//  Created by Yuanfeng on 11-07-11.
//  Copyright 2011 Elton(Yuanfeng) Gao. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "RouteDetailCell.h"

#define BUS_ICON_LEFT_OFFSET 6
#define BUS_ICON_WIDTH 50
#define BUS_ICON_HEIGHT 50
#define ROUTE_NUM_WIDTH 203
#define ROUTE_NUM_HEIGHT 30
#define FIRST_TIME_WIDTH 163
#define FIRST_TIME_HEIGHT 30

@implementation RouteDetailCell

@synthesize routeDetail = _routeDetail, firstTime = firstTime_, secondTime = secondTime_; //, nextBusDirection = nextBusDirection_;
//@synthesize timerBtn = _timerBtn;
@synthesize routeNumber = _routeNumber;

- (void)styleCellDetails1
{
    
    busIcon_ = [[UIImageView alloc] initWithFrame:CGRectMake(BUS_ICON_LEFT_OFFSET, 5, BUS_ICON_WIDTH, BUS_ICON_HEIGHT)];
    busIcon_.image = [UIImage imageNamed:@"btnBus_64x64"];
    
    //        _timerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //        _timerBtn.showsTouchWhenHighlighted = YES;
    //        
    //        _timerBtn.frame = CGRectMake(BUS_ICON_LEFT_OFFSET, 5, BUS_ICON_WIDTH, BUS_ICON_HEIGHT);
    //        [_timerBtn setImage:[UIImage imageNamed:@"btnBus_64x64"] forState:UIControlStateNormal];
    //        [self.contentView addSubview:_timerBtn];
    
    [self.contentView addSubview:busIcon_];
    
    //Put bus number inside a box
    UIImageView *route_num_bg = [[UIImageView alloc] initWithFrame:CGRectMake(busIcon_.bounds.origin.x + BUS_ICON_WIDTH + 8, 3, 31, 25)];
    CGPoint center = route_num_bg.center;
    route_num_bg.frame = CGRectMake(0, 0, 33, 27); //Make it bigger
    route_num_bg.center = center;
    
    route_num_bg.image = [UIImage imageNamed:@"route_num_bg"];
    [route_num_bg.image stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    route_num_bg.contentMode = UIViewContentModeScaleToFill;
    [self.contentView addSubview:route_num_bg];
    route_num_bg.layer.cornerRadius = 10.0f;
    _routeNumber = [[UILabel alloc] initWithFrame:route_num_bg.frame];
    _routeNumber.frame = CGRectMake(_routeNumber.frame.origin.x+1, _routeNumber.frame.origin.y, _routeNumber.frame.size.width, _routeNumber.frame.size.height);
    _routeNumber.textAlignment = UITextAlignmentCenter;
    _routeNumber.backgroundColor = [UIColor clearColor];
    _routeNumber.textColor = [UIColor whiteColor];
    _routeNumber.shadowColor = [UIColor colorWithRed:0.22f green:0.55f blue:0.80f alpha:1.0f];
    _routeNumber.shadowOffset = CGSizeMake(0, -1);
    _routeNumber.font = [UIFont boldSystemFontOfSize:18];
    _routeNumber.adjustsFontSizeToFitWidth = YES;
    _routeNumber.minimumFontSize = 11;
    _routeNumber.frame = CGRectMake(0, 0, _routeNumber.frame.size.width, _routeNumber.frame.size.height);
    [route_num_bg addSubview:_routeNumber];
    
    _routeDetail = [[AutoScrollLabel alloc] initWithFrame:CGRectMake( busIcon_.bounds.origin.x + BUS_ICON_WIDTH + 8 + route_num_bg.frame.size.width, 0, ROUTE_NUM_WIDTH, ROUTE_NUM_HEIGHT)];//[[MarqueeLabel alloc] initWithFrame:CGRectMake( busIcon_.bounds.origin.x + BUS_ICON_WIDTH + 8, 4, ROUTE_NUM_WIDTH, ROUTE_NUM_HEIGHT) andSpeed:3 andBuffer:3.0f];
    //routeNumber_ = [[UILabel alloc] initWithFrame:CGRectMake( busIcon_.bounds.origin.x + BUS_ICON_WIDTH + 8, 4, ROUTE_NUM_WIDTH, ROUTE_NUM_HEIGHT)];
    //routeNumber_.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    _routeDetail.scrollSpeed = 20.0f;
    _routeDetail.pauseInterval = 0.9f;
    _routeDetail.bufferSpaceBetweenLabels = 36;
    
    _routeDetail.text = @"12";
    //routeNumber_.textAlignment = UITextAlignmentLeft;
    [_routeDetail setTextAlightment:UITextAlignmentLeft];
    _routeDetail.textColor = [UIColor blackColor];
    _routeDetail.font = [UIFont boldSystemFontOfSize:18];
    _routeDetail.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_routeDetail];
    
    //        nextBusDirection_ = [[[UILabel alloc] initWithFrame:CGRectMake( busIcon_.bounds.origin.x + BUS_ICON_WIDTH + 20, ROUTE_NUM_HEIGHT + 3, 200, 20)] retain];
    //        nextBusDirection_.font = [UIFont systemFontOfSize:14];
    //        [self addSubview:nextBusDirection_];
    
    nextBusIn_  = [[UILabel alloc] initWithFrame:CGRectMake(busIcon_.bounds.origin.x + BUS_ICON_WIDTH + 10, ROUTE_NUM_HEIGHT-9, 62, FIRST_TIME_HEIGHT)];
    nextBusIn_.text = local(@"next bus: ");
    nextBusIn_.font = [UIFont systemFontOfSize:14];
    nextBusIn_.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:nextBusIn_];
    
    firstTime_ = [[UILabel alloc] initWithFrame:CGRectMake(nextBusIn_.frame.origin.x + nextBusIn_.frame.size.width, ROUTE_NUM_HEIGHT-9, FIRST_TIME_WIDTH, FIRST_TIME_HEIGHT)];
    firstTime_.text = @"test";
    firstTime_.adjustsFontSizeToFitWidth = YES;
    firstTime_.font = [UIFont boldSystemFontOfSize:18];
    firstTime_.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:firstTime_];
    
    _subsequentBusIn = [[UILabel alloc] initWithFrame:nextBusIn_.frame];
    _subsequentBusIn.text = local(@"subsequent bus:");
    _subsequentBusIn.font = [UIFont systemFontOfSize:14];
    _subsequentBusIn.frame = CGRectMake(_subsequentBusIn.frame.origin.x, ROUTE_NUM_HEIGHT+9, [_subsequentBusIn.text sizeWithFont:_subsequentBusIn.font].width, _subsequentBusIn.frame.size.height);
    _subsequentBusIn.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_subsequentBusIn];
    
    secondTime_ = [[UILabel alloc] initWithFrame:CGRectMake(_subsequentBusIn.frame.origin.x + _subsequentBusIn.frame.size.width + 12, ROUTE_NUM_HEIGHT+9, FIRST_TIME_WIDTH, FIRST_TIME_HEIGHT)];
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
    
    [_routeDetail setTextShadowOffset:CGSizeMake(0, 1)];
    [_routeDetail setTextShadowColor:[UIColor whiteColor]];
    //routeNumber_.shadowOffset = CGSizeMake(0, 1);
    //routeNumber_.shadowColor = [UIColor whiteColor];
}

//Route number on the bus icon
- (void)styleDetailCell2
{
    
    UIImageView *route_num_bg = [[UIImageView alloc] initWithFrame:CGRectMake(BUS_ICON_LEFT_OFFSET + 3, 9, BUS_ICON_WIDTH-6, BUS_ICON_HEIGHT-6)];
    route_num_bg.image = [UIImage imageNamed:@"route_num_bg"];
        [route_num_bg.image stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    route_num_bg.contentMode = UIViewContentModeScaleToFill;
    [self.contentView addSubview:route_num_bg];
    
    _routeNumber = [[UILabel alloc] initWithFrame:route_num_bg.frame];
    _routeNumber.frame = CGRectMake(_routeNumber.frame.origin.x+2, _routeNumber.frame.origin.y, _routeNumber.frame.size.width, _routeNumber.frame.size.height);
    _routeNumber.textAlignment = UITextAlignmentCenter;
    _routeNumber.backgroundColor = [UIColor clearColor];
    _routeNumber.textColor = [UIColor whiteColor];
    _routeNumber.shadowColor = [UIColor colorWithRed:0.22f green:0.55f blue:0.80f alpha:1.0f];
    _routeNumber.shadowOffset = CGSizeMake(0, -1);
    _routeNumber.font = [UIFont boldSystemFontOfSize:20];
    _routeNumber.frame = CGRectMake(0, 0, _routeNumber.frame.size.width, _routeNumber.frame.size.height);
    [route_num_bg addSubview:_routeNumber];
    
    _routeDetail = [[AutoScrollLabel alloc] initWithFrame:CGRectMake( route_num_bg.bounds.origin.x + BUS_ICON_WIDTH + 11, 0, ROUTE_NUM_WIDTH + 25, ROUTE_NUM_HEIGHT)];//[[MarqueeLabel alloc] initWithFrame:CGRectMake( busIcon_.bounds.origin.x + BUS_ICON_WIDTH + 8, 4, ROUTE_NUM_WIDTH, ROUTE_NUM_HEIGHT) andSpeed:3 andBuffer:3.0f];
    //routeNumber_ = [[UILabel alloc] initWithFrame:CGRectMake( busIcon_.bounds.origin.x + BUS_ICON_WIDTH + 8, 4, ROUTE_NUM_WIDTH, ROUTE_NUM_HEIGHT)];
    //routeNumber_.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    _routeDetail.scrollSpeed = 20.0f;
    _routeDetail.pauseInterval = 0.9f;
    _routeDetail.bufferSpaceBetweenLabels = 36;
    
    _routeDetail.text = @"12";
    //routeNumber_.textAlignment = UITextAlignmentLeft;
    [_routeDetail setTextAlightment:UITextAlignmentLeft];
    _routeDetail.textColor = [UIColor blackColor];
    _routeDetail.font = [UIFont boldSystemFontOfSize:18];
    _routeDetail.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_routeDetail];
    
    //        nextBusDirection_ = [[[UILabel alloc] initWithFrame:CGRectMake( busIcon_.bounds.origin.x + BUS_ICON_WIDTH + 20, ROUTE_NUM_HEIGHT + 3, 200, 20)] retain];
    //        nextBusDirection_.font = [UIFont systemFontOfSize:14];
    //        [self addSubview:nextBusDirection_];
    
    nextBusIn_  = [[UILabel alloc] initWithFrame:CGRectMake(busIcon_.bounds.origin.x + BUS_ICON_WIDTH + 10, ROUTE_NUM_HEIGHT-9, 62, FIRST_TIME_HEIGHT)];
    nextBusIn_.text = local(@"next bus: ");
    nextBusIn_.font = [UIFont systemFontOfSize:14];
    nextBusIn_.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:nextBusIn_];
    
    firstTime_ = [[UILabel alloc] initWithFrame:CGRectMake(nextBusIn_.frame.origin.x + nextBusIn_.frame.size.width, ROUTE_NUM_HEIGHT-9, FIRST_TIME_WIDTH, FIRST_TIME_HEIGHT)];
    firstTime_.text = @"test";
    firstTime_.adjustsFontSizeToFitWidth = YES;
    firstTime_.font = [UIFont boldSystemFontOfSize:18];
    firstTime_.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:firstTime_];
    
    _subsequentBusIn = [[UILabel alloc] initWithFrame:nextBusIn_.frame];
    _subsequentBusIn.text = local(@"subsequent bus:");
    _subsequentBusIn.font = [UIFont systemFontOfSize:14];
    _subsequentBusIn.frame = CGRectMake(_subsequentBusIn.frame.origin.x, ROUTE_NUM_HEIGHT+9, [_subsequentBusIn.text sizeWithFont:_subsequentBusIn.font].width, _subsequentBusIn.frame.size.height);
    _subsequentBusIn.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_subsequentBusIn];
    
    secondTime_ = [[UILabel alloc] initWithFrame:CGRectMake(_subsequentBusIn.frame.origin.x + _subsequentBusIn.frame.size.width + 12, ROUTE_NUM_HEIGHT+9, FIRST_TIME_WIDTH, FIRST_TIME_HEIGHT)];
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
    
    [_routeDetail setTextShadowOffset:CGSizeMake(0, 1)];
    [_routeDetail setTextShadowColor:[UIColor whiteColor]];
    //routeNumber_.shadowOffset = CGSizeMake(0, 1);
    //routeNumber_.shadowColor = [UIColor whiteColor];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (ENABLE_NEW_FEATURES) {
            [self styleCellDetails1]; //Route number same line as direction
        } else
        {
            [self styleDetailCell2]; //Route number on the bus icon
        }
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
@end
