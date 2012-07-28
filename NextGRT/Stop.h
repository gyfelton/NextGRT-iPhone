//
//  Stops.h
//  GRTEasyGo
//
//  Created by Yuanfeng on 11-05-27.
//  Copyright 2011. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
/** 
 * A Model bus top that adopt MKAnnotation protocol
 */
@interface Stop : NSObject <MKAnnotation>{
    float lat_;
    float lon_;
    NSString* stopID_;
    NSString* stopName_;
    BOOL isFavorite_;
    
    double distanceFromCurrPositionInMeter_; //note: this is optional, if invalid, will just init as -1
    
    NSMutableArray* busRoutes_;
    NSMutableArray *_distinctBusRoutesName;
    //NSString* locationType;
    //NSString* zoneID;
}

@property (nonatomic, retain) NSMutableArray* busRoutes;
@property (nonatomic, retain) NSMutableArray *distinctBusRoutesName;
@property (nonatomic, retain) NSString* stopName;
@property (nonatomic, retain) NSString* stopID;
@property BOOL isFav;
@property double distanceFromCurrPositionInMeter;
@property float lat;
@property float lon;

/**
 * method for init a new stop
 * @param NSString stopID       ID number for stop
 * @param NSString stopName     name of the stop, can be the nick name
 * @param float lat/lon         representing geo location of the stop
 * @return a new Stop instance, never return nil
 */
- (id) initWithStopID:(NSString*)stopID AndStopName:(NSString*)stopName Lat:(float)lat Lon:(float)lon;

/**
 * method for init a new stop with distance from current posistion information
 * @param double distance       representing the distance from the stop to the user
 * @return a new Stop instance, never return nil
 */
- (id) initWithStopID:(NSString*)stopID AndStopName:(NSString*)stopName Lat:(float)lat Lon:(float)lon distanceFromCurrPosition:(double)distance;

/**
 * Attach array of routes to the stop
 * @param: NSArray routes: An array of routes instances, can be nil or empty array
 */
- (void) assignBusRoutes:(NSArray*)routes;

/**
 * Method to delete all buses that no long have service within this day
 */
- (void)cleanNoServiceBus;

- (int) numberOfDistinctBusRoutes;

/**
 * @return number of bus routes under this stop
 */
- (int) numberOfBusRoutes;

/**
 * @return distance of the stop from the user in meters, -1 if no distance specified
 */
- (int) distanceFromCurrPosition;
@end
