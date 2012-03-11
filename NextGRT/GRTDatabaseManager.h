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

#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

@protocol GRTDatabaseManagerDelegate <NSObject>

@optional
- (void)stopInfoArrayReceived:(NSArray*) stops;
- (void)nearbyStopsReceived:(NSMutableArray*)stops;
- (void)busRoutesForAllStopsReceived;
@end

@interface GRTDatabaseManager : NSObject {
    NSString* _databasePath;
    
    double _latLonBaseOffset;
    
    FMDatabase *_db;
}


@property (copy) NSString* databasePath;
//@property (nonatomic, assign) id<GRTDatabaseManagerDelegate> delegate;

+ (id) sharedManager;

- (void) queryStopIDs:(NSArray*) stopIDs withDelegate:(id)object groupByStopName:(bool) groupByStopname;

- (void) queryNearbyStops:(CLLocation *) location withDelegate:(id)object withSearchRadiusFactor:(double)factor;

- (void) queryBusRoutesForStops:(NSMutableArray*)stops withDelegate:(id)object;

//used solely for search using name for now
- (void) queryStopIDsUsingName:(NSString*)name withDelegate:(id<GRTDatabaseManagerDelegate>)object groupByStopName:(BOOL) groupByStopName;

- (NSMutableArray*) queryAllStopsWithStopName:(NSString*)stopName;

@end
