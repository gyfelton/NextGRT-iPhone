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

/**
 * @class FavouriteStopsCentralManager
 * A singleton manager for all favourite stops
 */
@interface FavouriteStopsCentralManager : NSObject {
    NSMutableArray *_favStopDicts; //use array of dictionaries because we need to remember the order of stops for future functionalities
}

/**
 * Accessor to the singleton instance of FavouriteStopsCentralManager
 */
+ (FavouriteStopsCentralManager*) sharedInstance;

/**
 * @param Stop stop         the stop to check
 * @return whether the stop passed in is a favorite stop
 */
- (BOOL) isFavouriteStop: (Stop*) stop;

/**
 * @param Stop stop         The stop to add a favourite stop
 * @param   NSString name   The nickname the user assigns, can be nil or empty
 * @return whether adding of fav stop is successful or not
 */
- (BOOL) addFavoriteStop:(Stop*)stop Name:(NSString*)name;

/**
 * @param Stop stop         The fav stop to be edited
 * @param   NSString name   The nickname the user assigns, can be nil or empty
 * @return a BOOL indicating whether it is succesful or not, failure can be unknown error or the stop is not a fav stop
 */
- (BOOL) editFavoriteStop:(Stop*)stop Name:(NSString*)name;

/**
 * @param NSInteger sourceIndex the index of fav stop to be moved
 * @param NSInteger destIndex   the index of fav stop to be swapped with
 * @return a BOOL indicating whether the move is successful or not
 */
- (BOOL) moveStopAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destIndex;

/**
 * @param Stop stop     The stop to be deleted
 * @return whether the delete is successful or not; failure can be because the stop is not a fav stop
 */
- (BOOL) deleteFavoriteStop: (Stop*) stop;

/**
 * @param NSInteger index     The index of the stop to be deleted
 * @return whether the delete is successful or not; failure can be because the index of out of bound
 */
- (BOOL) deleteFavoriteStopAtIndex:(NSInteger)index;

/**
 * @param Stop stop     The stop to be checked
 * @return name of the stop, empty means no nick name is assign for this stop or this stop is not a fav stop
 */
- (NSString*)getCustomNameForStop:(Stop*)stop;

/**
 * tell the manager to save the fac stops stored
 */
- (void) saveFavStops;

/**
 * @return a array of all fav stops
 */
- (NSMutableArray*) getFavoriteStopDict;
@end

