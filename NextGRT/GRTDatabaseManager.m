//
//  GRTDatabaseManager.m
//  GRTEasyGo
//
//  Created by Yuanfeng on 11-05-27.
//  Copyright Elton(Yuanfeng) Gao 2011. All rights reserved.
//

#import "GRTDatabaseManager.h"
#import <sqlite3.h>
#import "Stop.h"
#import "BusRoute.h"
#import <CoreLocation/CoreLocation.h>

static GRTDatabaseManager* sharedManager = nil;

@implementation GRTDatabaseManager

@synthesize databasePath = _databasePath, isAskingForManualLocation;

+ (GRTDatabaseManager*) sharedManager {
    @synchronized(self) {
        if( sharedManager == nil ) {
            sharedManager = [[GRTDatabaseManager alloc] init];
        }
    }
    return sharedManager;
}

- (id) init {
    self = [super init];
    if( self ) {
        // Setup some globals
        
        // Get the path to the documents directory and append the databaseName
        self.databasePath = [[NSBundle mainBundle] pathForResource:kDatabaseName ofType:@"sqlite"];
//        NSLog(@"%@", self.databasePath);
        
        _db = [FMDatabase databaseWithPath:self.databasePath];
        
        if (!_db) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fatal error" message:@"Cannot find database, app cannot run anymore." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            return nil;
        }
        [_db open];
        
//        //load database
//        // Check if the SQL database has already been saved to the users phone, if not then copy it over
//        BOOL success;
//        
//        // Create a FileManager object, we will use this to check the status
//        // of the database and to copy it over if required
//        NSFileManager *fileManager = [NSFileManager defaultManager];
//        
//        // Check if the database has already been created in the users filesystem
//        success = [fileManager fileExistsAtPath:self.databasePath];
//        
//        // If the database already exists then return without doing anything
//        if( !success ) {
//            // If not then proceed to copy the database from the application to the users filesystem
//            
//            // Get the path to the database in the application package
//            NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:_databaseName];
//            
//            // Copy the database from the package to the users filesystem
//            [fileManager copyItemAtPath:databasePathFromApp toPath:self.databasePath error:nil];
//            
//        }
    }
    return self;
}

/*Notes for Developer:
 The following sqlite queries requires modification to original GRT database, please make sure the following is done so that the app run as expected:
 1. In Calendar Table, make sure no out-dated service_id exists(only allow one service_id), otherwise we can have multiple entry for a same time for same bus/bus stop
 2. In CalendarDate Table, all entris having retired service_id must be deleted
 3. In Stops: stop_lat and stop_lon needs to be DOUBLE or it will not get any result. 
 4. All Stop_id field must be numeric
 5. In Calandar Table, monday, tuesday.... must be NUMERIC 
 if there is any problem, feel free to email to gyfelton@gmail.com
*/

- (NSString*)cleanStopID:(NSString*)stopID withResultSet:(FMResultSet*) s
{
    NSString *newStopID = [stopID copy];
    //Need to analyse the stopID and convert illegal ones to legal ones
    if ([newStopID length]>5) {
        if (debug) {
            NSLog(@"WARNING: illegal stop id");
        }
        NSString *stop_desc = [s stringForColumn:@"stop_desc"];
        NSArray *texts = [stop_desc componentsSeparatedByString:@" "];
        if ([texts count]>1) {
            newStopID = [texts objectAtIndex:1]; //the second object, which is the real ID
        }
    }
    return newStopID;
}

- (void) queryStopIDs:(NSArray*) stopIDs withDelegate:(id<GRTDatabaseManagerDelegate>)object groupByStopName:(bool) groupByStopName {
    // Setup the database object
    NSMutableArray* results = [[NSMutableArray alloc] init];
    
    for( NSString* stopID in stopIDs ) {
        
        // Setup the SQL Statement and compile it for faster access
        NSString* completeSQLStmt = [NSString stringWithFormat:kQueryStopIDs, stopID];
        if (groupByStopName) {
            completeSQLStmt = [completeSQLStmt stringByAppendingString:kQueryFilterGroupByStopName];
        }
        
        
        FMResultSet *s = [_db executeQuery:completeSQLStmt];
        while ([s next]) {
                // Read the data from the result row
                //TODO check char* return is null or not before format to string
            float lat = [s doubleForColumn:@"stop_lat"];
            float lon = [s doubleForColumn:@"stop_lon"];
                
            
            NSString *stopID = [s stringForColumn:@"stop_id"];
            stopID = [self cleanStopID:stopID withResultSet:s];
            
            NSString *stopName = [s stringForColumn:@"stop_name"];
                
            // Create a new animal object with the data from the database
            Stop* theStop = [[Stop alloc] initWithStopID:stopID AndStopName:stopName Lat:lat Lon:lon];
            [results addObject:theStop];
        }
    }
    
    if (object && [object respondsToSelector:@selector(stopInfoArrayReceived:)]) {
        [object stopInfoArrayReceived:results];
    }
}

- (void) queryStopIDsUsingName:(NSString*)name withDelegate:(id<GRTDatabaseManagerDelegate>)object groupByStopName:(BOOL) groupByStopName {
    // Setup the database object
    NSMutableArray* results = [[NSMutableArray alloc] init];
    
    // Setup the SQL Statement and compile it for faster access
    NSString* completeSQLStmt = [NSString stringWithFormat:kQueryStopName, name];
    if (groupByStopName) {
        completeSQLStmt = [completeSQLStmt stringByAppendingString:kQueryFilterGroupByStopName];
    }
    
    FMResultSet *s = [_db executeQuery:completeSQLStmt];
    while ([s next]) {
        // Read the data from the result row
        //TODO check char* return is null or not before format to string
        float lat = [s doubleForColumn:@"stop_lat"];
        float lon = [s doubleForColumn:@"stop_lon"];
        
        
        NSString *stopID = [s stringForColumn:@"stop_id"];
        stopID = [self cleanStopID:stopID withResultSet:s];
        
        NSString *stopName = [s stringForColumn:@"stop_name"];
        
        // Create a new animal object with the data from the database
        Stop* theStop = [[Stop alloc] initWithStopID:stopID AndStopName:stopName Lat:lat Lon:lon];
        [results addObject:theStop];
    }
    if (object && [object respondsToSelector:@selector(stopInfoArrayReceived:)]) {
        [object stopInfoArrayReceived:results];
    }
}

- (void) calculateLatLonBaseOffset:(CLLocation*)location {
    //base on 100m and 45 degree bearing, 200m,300m and so on is linear relationship(approximation)
    //6371:earth's radius
    //based on uw's location, there is some offset needed to be added, turns out it is 0.0007
    //source: http://www.movable-type.co.uk/scripts/latlong.html
    
    _latLonBaseOffset = 0.1 / 6371 * sqrt(2) + 0.0007;
}


- (void) queryNearbyStops:(CLLocation *)location withDelegate:(id<GRTDatabaseManagerDelegate>)object withSearchRadiusFactor:(double)factor {
    //for debug purpse:
    if (debug) {
        NSLog(@"ATTENTION! location is override!");
        CLLocation* temp = [[CLLocation alloc] initWithLatitude:43.472617 longitude:-80.541059];
        location = temp;
    }
    
    //init result array
    NSMutableArray* stops = [[NSMutableArray alloc] init];
    
    NSLog(@"current location -  lat:%f, lon:%f", location.coordinate.latitude, location.coordinate.longitude);
    [self calculateLatLonBaseOffset:location]; //init latLonBaseOffset_
    
    //calculate radius needed
    double radius = 5 * factor; //500m * factor
    
    // Setup the SQL Statement and compile it for faster access
    NSString* completeSQLStmt = 
    [NSString stringWithFormat:kQueryNearbyStops
     , location.coordinate.latitude - _latLonBaseOffset * radius
     , location.coordinate.latitude + _latLonBaseOffset * radius
     , location.coordinate.longitude - _latLonBaseOffset * radius
     , location.coordinate.longitude + _latLonBaseOffset * radius];
    
    FMResultSet *s = [_db executeQuery:completeSQLStmt];
    while ([s next]) {
        //retrieve values for each record
        // Read the data from the result row
        //TODO check char* return is null or not before format to string?
        float lat = [s doubleForColumn:@"stop_lat"]; //sqlite3_column_double(compiledStatement, 0);
        float lon = [s doubleForColumn:@"stop_lon"]; //sqlite3_column_double(compiledStatement, 2);
        
        double distance = [location distanceFromLocation:[[CLLocation alloc] initWithLatitude:lat longitude:lon]];
        
        NSString *stopID = [s stringForColumn:@"stop_id"];//[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
        stopID = [self cleanStopID:stopID withResultSet:s];
        
        NSString *stopName = [s stringForColumn:@"stop_name"];//[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
        
        // Create a new stop object with the data from the database
        Stop* aStop = [[Stop alloc] initWithStopID:stopID AndStopName:stopName Lat:lat Lon:lon distanceFromCurrPosition:distance];
        [stops addObject:aStop];
    }
    
    //sort the stops here since we gurantee that stops here all have a proper distance data
    [stops sortUsingSelector:@selector(compareDistanceWithStop:)];
    
    if (object && [object respondsToSelector:@selector(nearbyStopsReceived:)]) {
        [object nearbyStopsReceived:stops];
    }
}

- (NSString*) dayOfWeekHelper {
    int weekday = [[[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:[NSDate date]] weekday];
    switch (weekday) {
        case 1:
            return [NSString stringWithString:@"sunday"];
            break;
        case 2:
            return [NSString stringWithString:@"monday"];
            break;
        case 3:
            return [NSString stringWithString:@"tuesday"];
            break;
        case 4:
            return [NSString stringWithString:@"wednesday"];
            break;
        case 5:
            return [NSString stringWithString:@"thursday"];
            break;
        case 6:
            return [NSString stringWithString:@"friday"];
            break;
        case 7:
            return [NSString stringWithString:@"saturday"];
            break;
        default:
            return [NSString stringWithString:@"monday"];
            break;
    }
}

- (void) queryBusRoutesForStops:(NSMutableArray*)stops withDelegate:(id<GRTDatabaseManagerDelegate>)object {
    
    //generate current time (truncate seconds)
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH':'mm':'00"];
    NSString* currTime = [formatter stringFromDate:[NSDate date]];
    NSLog(@"currTime: %@", currTime);
    
    for( Stop* aStop in stops) {
        //to store routes
        NSMutableArray* routes = [NSMutableArray arrayWithCapacity:0];
        
        //TODO handle case on special days
        //Firstly, construct the day of today
        NSString* dayOfWeek = [self dayOfWeekHelper]; 
        
        //The, retrieve serviceID
        NSString* serviceIDQuery = [NSString stringWithFormat:kQueryNormalServiceID, dayOfWeek];
        
        // Setup the SQL Statement and compile it for faster access
        NSString* completeSQLStmt = [NSString stringWithFormat:kQueryRoutesTimes, [aStop stopID], currTime, serviceIDQuery];
//        NSLog(@"%@", [aStop stopID]);
        FMResultSet *s = [_db executeQuery:completeSQLStmt];
        NSString* currRoute = nil;
        BusRoute* route = nil;
        while ([s next]) {
            
            // Read the data from the result row
            NSString* routeNum = [s stringForColumn:@"route_id"];//[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
            NSString* departureTime = [s stringForColumn:@"departure_time"];//[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];r
            NSString* direction = [s stringForColumn:@"trip_headsign"];//[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
            
//            NSString *numAndDirectionCombined = [NSString stringWithFormat:@"%@%@", routeNum, direction];
            if( currRoute && [currRoute compare:routeNum] == NSOrderedSame ) {
                //just add the time and direction since it is the same bus
                [route addNextArrivalTime:departureTime Direction:direction];
            } else { //we encounter a new route, add old route to array
                if( route ) {
                    [routes addObject:route];
                    //[route release];
                }
                currRoute = routeNum;
                
                //alloc a new route object for new route
                route = [[BusRoute alloc] initWithRouteNumber:routeNum routeID:routeNum direction:direction AndTime:departureTime];
            }
        }
        //add last route to it
        if (route) {
            [routes addObject:route];
        }
        
        for( BusRoute* route in routes ) {
            [route initNextArrivalCountDownBaesdOnTime:[NSDate date]];
        }
        [aStop assignBusRoutes: routes];
    }
    
    if (object && [object respondsToSelector:@selector(busRoutesForAllStopsReceived)]) {
        [object busRoutesForAllStopsReceived];
    }
}

- (NSMutableArray*) queryAllStopsWithStopName:(NSString*)stopName {
    NSMutableArray* results = [[NSMutableArray alloc] init];
    
	// Open the database from the users files sytem
    // Setup the SQL Statement and compile it for faster access
    NSString* completeSQLStmt = [NSString stringWithFormat:kQueryStopsWithStopName, stopName];
    
    FMResultSet *s = [_db executeQuery:completeSQLStmt];
    while ([s next]) {
        // Read the data from the result row
        //TODO check char* return is null or not before format to string
        float lat = [s doubleForColumn:@"stop_lat"];
        float lon = [s doubleForColumn:@"stop_lon"];//sqlite3_column_double(compiledStatement, 2);
        
        NSString *stopID = [s stringForColumn:@"stop_id"];
        stopID = [self cleanStopID:stopID withResultSet:s];
        
        NSString *stopName = [s stringForColumn:@"stop_name"];
        
        // Create a new stop object with the data from the database
        Stop* theStop = [[Stop alloc] initWithStopID:stopID AndStopName:stopName Lat:lat Lon:lon];
        [results addObject:theStop];
    }
    
    return results;
}

@end
