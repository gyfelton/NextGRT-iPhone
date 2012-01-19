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

@synthesize databasePath = _databasePath;

+ (id) sharedManager {
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
        _databaseName = kDatabaseName;
        
        // Get the path to the documents directory and append the databaseName
        self.databasePath = [[NSBundle mainBundle] pathForResource:@"GRTDataBase" ofType:@"sqlite"];
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

- (void)queryStopIDsHelper:(NSDictionary*)arg
{
    NSMutableArray *stopIDs = [arg valueForKey:@"stopIDs"];
    
    id d = [arg valueForKey:@"delegate"];
    
    BOOL groupByStopName = [[arg valueForKey:@"groupByStopName"] boolValue];
    
    // Setup the database object
	sqlite3 *database;
    NSMutableArray* results = [[NSMutableArray alloc] init];
    
	// Open the database from the users files sytem
	if(sqlite3_open([self.databasePath UTF8String], &database) == SQLITE_OK) {
        for( NSString* stopID in stopIDs ) {
            
            // Setup the SQL Statement and compile it for faster access
            NSString* completeSQLStmt = [NSString stringWithFormat:kQueryStopIDs, stopID];
            if (groupByStopName) {
                completeSQLStmt = [completeSQLStmt stringByAppendingString:kQueryFilterGroupByStopName];
            }
            
            sqlite3_stmt *compiledStatement;
            if(sqlite3_prepare_v2(database, [completeSQLStmt UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
                // get all results
                while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
                    // Read the data from the result row
                    //TODO check char* return is null or not before format to string
                    float lat = sqlite3_column_double(compiledStatement, 0);
                    float lon = sqlite3_column_double(compiledStatement, 2);
                    
                    NSString *stopID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
                    NSString *stopName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
                    
                    // Create a new animal object with the data from the database
                    Stop* theStop = [[Stop alloc] initWithStopID:stopID AndStopName:stopName Lat:lat Lon:lon];
                    [results addObject:theStop];
                }
            }
            // Release the compiled statement from memory
            sqlite3_finalize(compiledStatement);
        }
	}
	sqlite3_close(database);
    
    //[self.delegate stopInfoArrayReceived:results];
    [[NSNotificationCenter defaultCenter] postNotificationName:kStopInfoReceivedNotificationName object:results userInfo:[NSDictionary dictionaryWithObjectsAndKeys:d, @"delegate", nil]];
}

- (void) queryStopIDs:(NSArray*) stopIDs withDelegate:(id)object groupByStopName:(bool) groupByStopname {
    NSDictionary *arg = [[NSDictionary alloc] initWithObjectsAndKeys:stopIDs, @"stopIDs", object, @"delegate", [NSNumber numberWithBool:groupByStopname], @"groupByStopName", nil];
    [self performSelectorOnMainThread:@selector(queryStopIDsHelper:) withObject:arg waitUntilDone:NO];
}

- (void) calculateLatLonBaseOffset:(CLLocation*)location {
    //base on 100m and 45 degree bearing, 200m,300m and so on is linear relationship(approximation)
    //6371:earth's radius
    //based on uw's location, there is some offset needed to be added, turns out it is 0.0007
    //source: http://www.movable-type.co.uk/scripts/latlong.html
    
    _latLonBaseOffset = 0.1 / 6371 * sqrt(2) + 0.0007;
}

- (void)queryNearbyStopsHelper:(NSDictionary*)arg
{
    CLLocation *location = [arg valueForKey:@"location"];
    id delegate = [arg valueForKey:@"delegate"];
    double factor = [[arg valueForKey:@"searchRadiusFactor"] doubleValue];
    
    //for debug purpse:
    NSLog(@"ATTENTION! location is override!");
    CLLocation* temp = [[CLLocation alloc] initWithLatitude:43.472617 longitude:-80.541059];
    location = temp;
    
    //self.delegate = object;
    
    // Setup the database object
	sqlite3 *database;
    
    //init result array
    NSMutableArray* stops = [[NSMutableArray alloc] init];
    
    NSLog(@"current location -  lat:%f, lon:%f", location.coordinate.latitude, location.coordinate.longitude);
    [self calculateLatLonBaseOffset:location]; //init latLonBaseOffset_
    
	// Open the database from the users files sytem
	if (true) {//(sqlite3_open([self.databasePath UTF8String], &database) == SQLITE_OK) {
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
            float lat = [s doubleForColumnIndex:0]; //sqlite3_column_double(compiledStatement, 0);
            float lon = [s doubleForColumnIndex:2]; //sqlite3_column_double(compiledStatement, 2);
            
            double distance = [location distanceFromLocation:[[CLLocation alloc] initWithLatitude:lat longitude:lon]];
            
            NSString *stopID = [s stringForColumnIndex:3];//[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
            NSString *stopName = [s stringForColumnIndex:4];//[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
            
            // Create a new stop object with the data from the database
            Stop* aStop = [[Stop alloc] initWithStopID:stopID AndStopName:stopName Lat:lat Lon:lon distanceFromCurrPosition:distance];
            [stops addObject:aStop];
        }
        
//		sqlite3_stmt *compiledStatement;
//        int resultCode = sqlite3_prepare_v2(database, [completeSQLStmt UTF8String], -1, &compiledStatement, NULL);
//		if( resultCode == SQLITE_OK ) {
//            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
//				// Read the data from the result row
//                //TODO check char* return is null or not before format to string?
//                float lat = sqlite3_column_double(compiledStatement, 0);
//                float lon = sqlite3_column_double(compiledStatement, 2);
//                
//                double distance = [location distanceFromLocation:[[CLLocation alloc] initWithLatitude:lat longitude:lon]];
//                
//				NSString *stopID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
//				NSString *stopName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
//				
//				// Create a new stop object with the data from the database
//				Stop* aStop = [[Stop alloc] initWithStopID:stopID AndStopName:stopName Lat:lat Lon:lon distanceFromCurrPosition:distance];
//                [stops addObject:aStop];
//			}
//		}
//		// Release the compiled statement from memory
//		sqlite3_finalize(compiledStatement);
	}
//	sqlite3_close(database);
    
    //sort the stops here since we gurantee that stops here all have a proper distance data
    [stops sortUsingSelector:@selector(compareDistanceWithStop:)];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kQueryNearbyStopsDidFinishNotification object:stops userInfo:[NSDictionary dictionaryWithObjectsAndKeys:delegate, @"delegate", nil]];
}

- (void) queryNearbyStops:(CLLocation *)location withDelegate:(id)object withSearchRadiusFactor:(double)factor {
    NSDictionary *arg = [NSDictionary dictionaryWithObjectsAndKeys:location, @"location", object, @"delegate", [NSNumber numberWithDouble:factor], @"searchRadiusFactor", nil];
    [self performSelectorOnMainThread:@selector(queryNearbyStopsHelper:) withObject:arg waitUntilDone:NO];
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

- (void) queryBusRoutesForStops:(NSMutableArray*)stops withDelegate:(id)object {
    NSMutableArray *ss = [stops copy];
    //generate current time (truncate seconds)
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH':'mm':'00"];
    NSString* currTime = [formatter stringFromDate:[NSDate date]];
    NSLog(@"currTime: %@", currTime);
    
    // Setup the database object
	sqlite3 *database;
    
    // Open the database from the users files sytem
	if(true) {// sqlite3_open([self.databasePath UTF8String], &database) == SQLITE_OK) {
        for( Stop* aStop in ss) {
            //to store routes
            NSMutableArray* routes = [NSMutableArray arrayWithCapacity:0];
            
            //TODO handle case on special days
            //Firstly, construct the day of today
            NSString* dayOfWeek = [self dayOfWeekHelper]; 
            
            //The, retrieve serviceID
            NSString* serviceIDQuery = [NSString stringWithFormat:kQueryNormalServiceID, dayOfWeek];
            
            // Setup the SQL Statement and compile it for faster access
            NSString* completeSQLStmt = [NSString stringWithFormat:kQueryRoutesTimes, [aStop stopID], currTime, serviceIDQuery];
            
            FMResultSet *s = [_db executeQuery:completeSQLStmt];
            NSString* currRoute = nil;
            BusRoute* route = nil;
            while ([s next]) {
                
                // Read the data from the result row
                NSString* routeNum = [s stringForColumnIndex:0];//[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
                NSString* departureTime = [s stringForColumnIndex:1];//[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];r
                NSString* direction = [s stringForColumnIndex:2];//[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
                
                if( currRoute && [currRoute compare:routeNum] == NSOrderedSame ) {
                    //just add the time and direction since it is the same bus
                    [route addNextArrivalTime:departureTime Direction:direction];
                } else { //we encounter a new route, add route to array
                    if( route ) {
                        [routes addObject:route];
                        //[route release];
                    }
                    currRoute = routeNum;
                    
                    //alloc a new route object for new route
                    route = [[BusRoute alloc] initWithRouteNumber:currRoute routeID:currRoute direction:direction AndTime:departureTime];
                }
            }
            //add last route to it
            if (route) {
                [routes addObject:route];
            }
//            sqlite3_stmt *compiledStatement;
//            if(sqlite3_prepare_v2(database, [completeSQLStmt UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
//                NSString* currRoute = nil;
//                BusRoute* route = nil;
//                
//                while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
//                    // Read the data from the result row
//                    NSString* routeNum = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
//                    NSString* departureTime = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
//                    NSString* direction = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
//                    
//                    if( currRoute && [currRoute compare:routeNum] == NSOrderedSame ) {
//                        //just add the time and direction since it is the same bus
//                        [route addNextArrivalTime:departureTime Direction:direction];
//                    } else { //we encounter a new route, add route to array
//                        if( route ) {
//                            [routes addObject:route];
//                            //[route release];
//                        }
//                        currRoute = routeNum;
//                        
//                        //alloc a new route object for new route
//                        route = [[BusRoute alloc] initWithRouteNumber:currRoute routeID:currRoute direction:direction AndTime:departureTime];
//                    }
//                }
//                //add last route to it
//                if (route) {
//                    [routes addObject:route];
//                }
//            }
            // Release the compiled statement from memory
//            sqlite3_finalize(compiledStatement);
            
            for( BusRoute* route in routes ) {
                [route initNextArrivalCountDownBaesdOnTime:[NSDate date]];
            }
            [aStop assignBusRoutes: routes];
        }
    }
    //sqlite3_close(database);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kBusRoutesForAllStopsReceivedNotificationName object:ss userInfo:[NSDictionary dictionaryWithObjectsAndKeys:object, @"delegate",nil]];
//    [self.delegate busRoutesForAllStopsReceived];
}

- (NSMutableArray*) queryAllStopsWithStopName:(NSString*)stopName {
    // Setup the database object
	sqlite3 *database;
    NSMutableArray* results = [[NSMutableArray alloc] init];
    
	// Open the database from the users files sytem
	if(sqlite3_open([self.databasePath UTF8String], &database) == SQLITE_OK) {
        // Setup the SQL Statement and compile it for faster access
        NSString* completeSQLStmt = [NSString stringWithFormat:kQueryStopsWithStopName, stopName];

        sqlite3_stmt *compiledStatement;
        if(sqlite3_prepare_v2(database, [completeSQLStmt UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
            // get all results
            while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
                // Read the data from the result row
                //TODO check char* return is null or not before format to string
                float lat = sqlite3_column_double(compiledStatement, 0);
                float lon = sqlite3_column_double(compiledStatement, 2);
                
                NSString *stopID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
                NSString *stopName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
                
                // Create a new stop object with the data from the database
                Stop* theStop = [[Stop alloc] initWithStopID:stopID AndStopName:stopName Lat:lat Lon:lon];
                [results addObject:theStop];
            }
        }
        // Release the compiled statement from memory
        sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
    
    return results;
}

@end
