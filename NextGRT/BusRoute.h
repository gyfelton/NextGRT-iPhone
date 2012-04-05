//
//  BusRoute.h
//  GRTEasyGo
//
//  Created by Yuanfeng on 11-07-05.
//  Copyright 2011 Elton(Yuanfeng) Gao. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @class BusRoute
 * A data model storing information of each bus route
 */
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

/**
 * Represents a route number in full
 * Note: iXpress is valid here, so represent in NSString
 */
@property (copy) NSString* fullRouteNumber;

/**
 * Represents a route number in short form
 * Note: iXpress becomes iXp here
 */
@property (copy) NSString* shortRouteNumber;

/**
 * stores the route ID
 */
@property (copy) NSString* routeID;

/**
 * Init new route instance with information:
 * @param NSString routeNumber
 * @param NSString routeID
 * @param NSString dir      string representing the direction of the bus going, direction in terms of terminal
 * @param NSString time     indicates first arrival time of the bus
 */
- (id) initWithRouteNumber:(NSString*)routeNumber routeID:(NSString*)routeID direction:(NSString*)dir AndTime:(NSString*)time;

/**
 * Use this method add another arrival time for this bus route
 * @param NSString time     
 * @param NSString direction
 */
- (void) addNextArrivalTime:(NSString*)time Direction:(NSString*) direction;

/**
 * Use this method the refresh the count down of each arrival time
 */
- (void) refreshCountDown;

/**
 * init count down of all next arrival times based on time passed in
 * @param NSTime time           The time to be used to calculte the next arrival time
 */
- (void) initNextArrivalCountDownBaesdOnTime:(NSDate*)time;

/**
 * ask if there is any more service for this route
 * @return BOOL indicating whether there is any more service
 */
- (BOOL)hasAnyMoreServices;

/**
 * Manually convert timeInterval to hour min and sec
 * @param NSTimerInterval diff 
 * @return a human readable string in the format of hh:mm:ss based on the time interval
 */
- (NSString*) parseTimeInterval:(NSTimeInterval) diff;

/** 
 * @return the string represeting the direction of the bus
 */
- (NSString*) getNextBusDirection;

/**
 *returm the NSString of the first and next arrival time in countdown format
 */
- (NSString*) getFirstArrivalTime;
- (NSString*) getSecondArrivalTime;

/**
 *returm the NSString of the first and next arrival time in actual time format
 */
- (NSString*) getFirstArrivalActualTime;
- (NSString*) getSecondArrivalActualTime;
@end
