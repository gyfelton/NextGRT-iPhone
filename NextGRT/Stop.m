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
@synthesize distinctBusRoutesName = _distinctBusRoutesName;

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

- (void)initDistinctRouteNames
{
    NSMutableSet *nameSet = [[NSMutableSet alloc] initWithCapacity:[self.busRoutes count]];
    for (BusRoute *busRoute in self.busRoutes) {
        [nameSet addObject:busRoute.shortRouteNumber];
    }
    self.distinctBusRoutesName = [NSMutableArray arrayWithArray:[nameSet allObjects]];
}
                                  
- (void)assignBusRoutes:(NSArray*)routes {
    self.busRoutes = [NSMutableArray arrayWithArray:routes];
    [self initDistinctRouteNames];
}

- (void)cleanNoServiceBus
{
    for (int i =0; i < [busRoutes_ count]; i++) {
        BusRoute *route = [busRoutes_ objectAtIndex:i];
        if (![route hasAnyMoreServices]) {
            [busRoutes_ removeObjectAtIndex:i];
        }
    }
    [self initDistinctRouteNames];
}

- (int) numberOfBusRoutes {
    return [self.busRoutes count];
}

- (int) numberOfDistinctBusRoutes
{
    return [self.distinctBusRoutesName count];
}

- (int) distanceFromCurrPosition {
    if (distanceFromCurrPositionInMeter_) {
            return [[NSNumber numberWithDouble:distanceFromCurrPositionInMeter_] intValue];
    } else
    {
        return -1;
    }
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

#pragma mark - MKAnnotation Protocol
- (CLLocationCoordinate2D)coordinate;
{
    CLLocationCoordinate2D theCoordinate;
    theCoordinate.latitude = lat_;
    theCoordinate.longitude = lon_;
    return theCoordinate; 
}

// required if you set the MKPinAnnotationView's "canShowCallout" property to YES
- (NSString *)title
{
    return self.stopName;
}

// optional
- (NSString *)subtitle
{
    return @"Avaialable routes:";
}
@end
