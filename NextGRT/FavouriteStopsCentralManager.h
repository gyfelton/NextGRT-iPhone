//
//  FavouriteStopsCentralManager.h
//  GRTEasyGo
//
//  Created by Yuanfeng on 11-07-12.
//  Copyright 2011 Elton(Yuanfeng) Gao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Stop.h"

#define STOP_ID_KEY @"stop_id"
#define STOP_CUSTOM_NAME_KEY @"custom_name"
#define USER_DEFAULT_FAV_STOP_KEY @"FavoriteBusStops"

@interface FavouriteStopsCentralManager : NSObject {
    NSMutableArray *favStopDicts_; //use array of dictionaries because we need to remember the order of stops for future functionalities
}

+ (FavouriteStopsCentralManager*) sharedInstance;

- (BOOL) isFavouriteStop: (Stop*) stop;
- (BOOL) addFavoriteStop:(Stop*)stop Name:(NSString*)name;
- (void) deleteFavoriteStop: (Stop*) stop;
- (NSString*)getCustomNameForStop:(Stop*)stop;

//- (void) saveStopOrder:(NSMutableArray*) stops;
- (void) saveFavStops;

- (NSMutableArray*) getFavoriteStopDict;
@end

