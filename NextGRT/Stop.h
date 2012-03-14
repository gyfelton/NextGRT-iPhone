//
//  Stops.h
//  GRTEasyGo
//
//  Created by Yuanfeng on 11-05-27.
//  Copyright 2011. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Stop : NSObject {
    float lat_;
    float lon_;
    NSString* stopID_;
    NSString* stopName_;
    BOOL isFavorite_;
    
    double distanceFromCurrPositionInMeter_; //note: this is optional, if invalid, will just init as -1
    
    NSMutableArray* busRoutes_;
    //NSString* locationType;
    //NSString* zoneID;
}

@property (nonatomic, retain) NSMutableArray* busRoutes;
@property (nonatomic, retain) NSString* stopName;
@property (nonatomic, retain) NSString* stopID;
@property BOOL isFav;
@property double distanceFromCurrPositionInMeter;
@property float lat;
@property float lon;

- (id) initWithStopID:(NSString*)stopID AndStopName:(NSString*)stopName Lat:(float)lat Lon:(float)lon;
- (id) initWithStopID:(NSString*)stopID AndStopName:(NSString*)stopName Lat:(float)lat Lon:(float)lon distanceFromCurrPosition:(double)distance;
- (void) assignBusRoutes:(NSArray*)routes;
- (void)cleanNoServiceBus;
- (int) numberOfBusRoutes;
- (int) distanceFromCurrPosition;
@end
