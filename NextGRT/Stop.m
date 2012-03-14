//
//  Stops.m
//  GRTEasyGo
//
//  Created by Yuanfeng on 11-05-27.
//  Copyright 2011. All rights reserved.
//

#import "Stop.h"
#import "BusRoute.h"

@implementation Stop

@synthesize busRoutes = busRoutes_, isFav = isFavorite_, stopID = stopID_, stopName = stopName_, lat = lat_, lon = lon_, distanceFromCurrPositionInMeter = distanceFromCurrPositionInMeter_;

- (id) initWithStopID:(NSString*)stopID AndStopName:(NSString*)stopName Lat:(float)lat Lon:(float)lon {
    return [self initWithStopID:stopID AndStopName:stopName Lat:lat Lon:lon distanceFromCurrPosition:-1];
}

- (id) initWithStopID:(NSString*)stopID AndStopName:(NSString*)stopName Lat:(float)lat Lon:(float)lon distanceFromCurrPosition:(double)distance {
    lat_ = lat;
    lon_ = lon;
    stopID_ = [stopID copy];
    stopName_ = [stopName copy];
    distanceFromCurrPositionInMeter_ = distance;
    
    return self;
}

- (void)assignBusRoutes:(NSArray*)routes {
    self.busRoutes = [NSMutableArray arrayWithArray:routes];
}

- (void)cleanNoServiceBus
{
    for (int i =0; i < [busRoutes_ count]; i++) {
        BusRoute *route = [busRoutes_ objectAtIndex:i];
        if (![route hasAnyMoreServices]) {
            [busRoutes_ removeObjectAtIndex:i];
        }
    }
}

- (int) numberOfBusRoutes {
    return [self.busRoutes count];
}

- (int) distanceFromCurrPosition {
    return [[NSNumber numberWithDouble:distanceFromCurrPositionInMeter_] intValue];
}

//helper function for sorting stops
- (NSComparisonResult)compareDistanceWithStop:(Stop*)s {
    return [[NSNumber numberWithDouble:[self distanceFromCurrPositionInMeter]] 
                compare: [NSNumber numberWithDouble:[s distanceFromCurrPositionInMeter]]];
}
            
- (void)dealloc {
    self.stopID = nil;
    self.stopName = nil;
    self.busRoutes = nil;
}

@end
