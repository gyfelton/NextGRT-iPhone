//
//  GRTDatabaseManager.h
//  GRTEasyGo
//
//  Created by Yuanfeng on 11-05-27.
//  Copyright Elton(Yuanfeng) Gao 2011. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Stop.h"
#import "CoreLocation/CLLocation.h"

//TODO should use delegate? seems that it doesn't help anything
@protocol GRTDatabaseManagerDelegate <NSObject>

@optional
- (void)stopInfoArrayReceived:(NSArray*) stops;
- (void)nearbyStopsReceived:(NSMutableArray*)stops;
- (void)busRoutesForAllStopsReceived;
@end

@interface GRTDatabaseManager : NSObject {
    NSString* databaseName_;
    NSString* databasePath_;
    
    double latLonBaseOffset_;
}


@property (copy) NSString* databasePath;
@property (nonatomic, assign) id<GRTDatabaseManagerDelegate> delegate;

+ (id) sharedManager;

- (void) calculateLatLonBaseOffset:(CLLocation*)location;

- (void) queryStopIDs:(NSArray*) stopIDs withDelegate:(id)object groupByStopName:(bool) groupByStopname;
- (void) queryNearbyStops:(CLLocation *) location withDelegate:(id)object withSearchRadiusFactor:(double)factor;
- (void) queryBusRoutesForStops:(NSMutableArray*)stops withDelegate:(id)object;
- (NSMutableArray*) queryAllStopsWithStopName:(NSString*)stopName;
@end
