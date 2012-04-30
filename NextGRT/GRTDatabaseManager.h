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

/**
 * @protocol GRTDatabaseManagerDelegate
 * Tells delegate the state of query
 */
@protocol GRTDatabaseManagerDelegate <NSObject>

@optional
- (void)stopInfoArrayReceived:(NSArray*) stops;
- (void)nearbyStopsReceived:(NSMutableArray*)stops;
- (void)busRoutesForAllStopsReceived;
@end

/**
 * @class GRTDatabaseManager
 * A singleton manager for all queries about the database storing information of buses, stops and time info
 */
@interface GRTDatabaseManager : NSObject {
    NSString* _databasePath;
    
    double _latLonBaseOffset;
    
    FMDatabase *_db;
}

@property (nonatomic) BOOL isAskingForManualLocation;

/**
 * @property path of the database the manager points to
 */
@property (copy) NSString* databasePath;

/**
 * Accessor to the singleton of this manager
 */
+ (GRTDatabaseManager*) sharedManager;

/**
 * Query the information of a list of stops
 * @param NSArray stopIDs      An array of stop IDs for query
 * @param id delegate     Tells the manager the object to pass info
 * @param BOOL gourpByStopName  If Yes, then the result will put stops with the same name together in the array
 * @return void, but will tell the delegate the result through "stopInfoArrayReceived", with the array of stops
 */
- (void) queryStopIDs:(NSArray*) stopIDs withDelegate:(id)object groupByStopName:(bool) groupByStopname;

/**
 * Query nearby stops based on a geo location and radius provided
 * @param CLLocation geo        Location to calculate on
 * @param id delegate           Tells the manager the object to pass to
 * @param double factor         Radius to be covered, where center is the geo location
 * @return void, but will tell the delegate the result through "nearbyStopsReceived", with the array of stops
 */
- (void) queryNearbyStops:(CLLocation *) location withDelegate:(id)object withSearchRadiusFactor:(double)factor;

/**
 * Query the routes for each stop listed
 * @param NSmutableArray stops      A list of stops for query 
 * @param id delegate           Tells the manager the object to pass to
 * @return return void, but will tell the delegate the result through "busRoutesForAllStopsReceived", Stops passed in will have the route information
 */
- (void) queryBusRoutesForStops:(NSMutableArray*)stops withDelegate:(id)object;

/**
 * Query the stop ID based a search string for each stop listed
 * @param NSString name     The name to seach for 
 * @param id delegate           Tells the manager the object to pass to
 * @param BOOL gourpByStopName  If Yes, then the result will put stops with the same name together in the array
 * @return return void, but will tell the delegate the result through "stopInfoArrayReceived", Stops passed in will have the route information
 */
- (void) queryStopIDsUsingName:(NSString*)name withDelegate:(id<GRTDatabaseManagerDelegate>)object groupByStopName:(BOOL) groupByStopName;


/**
 * Query all stops that have this stop name
 * @param NSString *stopName the name of to query for
 * @return a array of stops that containes this stop name, for opposite stops for example
 */
- (NSMutableArray*) queryAllStopsWithStopName:(NSString*)stopName;

@end
