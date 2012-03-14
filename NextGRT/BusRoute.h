//
//  BusRoute.h
//  GRTEasyGo
//
//  Created by Yuanfeng on 11-07-05.
//  Copyright 2011 Elton(Yuanfeng) Gao. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BusRoute : NSObject {
    NSString* fullRouteNumber_; //note: iXpress is valid here, so represent in NSString
    NSString* shortRouteNumber_; //note: iXpress becomes iXps
    
    NSString* routeID_;
    NSString* direction_; //ex: To FairView
    
    //just keep track of all possible times, go away with time passed by
    NSMutableArray* nextArrivalTimes_; //keep track of time of next buses

    NSMutableArray* nextBusCountDown_;
    
    //should not keep count down in negative value!
    NSMutableArray* nextArrivalDirection_;
}

@property (copy) NSString* fullRouteNumber;
@property (copy) NSString* shortRouteNumber;
@property (copy) NSString* routeID;


- (id) initWithRouteNumber:(NSString*)routeNumber routeID:(NSString*)routeID direction:(NSString*)dir AndTime:(NSString*)time;
- (void) addNextArrivalTime:(NSString*)time Direction:(NSString*) direction;
- (void) refreshCountDown;
- (void) initNextArrivalCountDownBaesdOnTime:(NSDate*)time;

- (BOOL)hasAnyMoreServices;
- (NSString*) parseTimeInterval:(NSTimeInterval) diff;
- (NSString*) getNextBusDirection;

- (NSString*) getFirstArrivalTime;
- (NSString*) getSecondArrivalTime;

- (NSString*) getFirstArrivalActualTime;
- (NSString*) getSecondArrivalActualTime;
@end
