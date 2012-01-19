//
//  FavouriteStopsCentralManager.m
//  GRTEasyGo
//
//  Created by Yuanfeng on 11-07-12.
//  Copyright 2011 Elton(Yuanfeng) Gao. All rights reserved.
//

#import "FavouriteStopsCentralManager.h"

@implementation FavouriteStopsCentralManager

static FavouriteStopsCentralManager *sharedInstance_ = nil;

+ (FavouriteStopsCentralManager *)sharedInstance {
    @synchronized(sharedInstance_) {
        if (!sharedInstance_) {
            sharedInstance_ = [[FavouriteStopsCentralManager alloc] init];
        }
    }
    return sharedInstance_;
}

- (id)init {
    self = [super init];
    if (self){
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSArray* savedFavStops = [prefs objectForKey:USER_DEFAULT_FAV_STOP_KEY];
        if (savedFavStops != nil) {
            _favStopDicts = [[NSMutableArray alloc] initWithArray:savedFavStops];
        } else {
            _favStopDicts = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

- (BOOL)isFavouriteStop:(Stop*)stop {
    bool isFav = NO;
    for( NSMutableDictionary* dict in _favStopDicts ) {
        NSString* str = [dict objectForKey:STOP_ID_KEY];
        if( [str compare:[stop stopID]] == NSOrderedSame ) {
            isFav = YES;
            NSLog(@"%@ is a fav stop!", [stop stopID]);
            break;
        }
    }
    return  isFav;
}

- (NSString*)getCustomNameForStop:(Stop*)stop {
    NSString* name = @"";
    for( NSMutableDictionary* dict in _favStopDicts ) {
        NSString* str = [dict objectForKey:STOP_ID_KEY];
        if( [str compare:[stop stopID]] == NSOrderedSame ) {
            name = [dict objectForKey:STOP_CUSTOM_NAME_KEY];
            break;
        }
    }
    return name; //if empty string is returned, that means there is no custom name added
}

- (BOOL) addFavoriteStop:(Stop*)stop Name:(NSString*)name {
    if (![self isFavouriteStop:stop]) {
        //use mutable dictionary so that we can modify custom name in the future
        NSMutableDictionary* stopDict = [[NSMutableDictionary alloc] initWithObjects:
                                    [NSArray arrayWithObjects:[stop stopID],name, nil] 
                                    forKeys:[NSArray arrayWithObjects: STOP_ID_KEY, STOP_CUSTOM_NAME_KEY, nil]];
        [_favStopDicts addObject:stopDict];
        [self saveFavStops];
        return YES;
    } else {
        return NO;
    }
}

- (void) deleteFavoriteStop:(Stop*)stop {
    for( int i=0; i<[_favStopDicts count]; i++ ) {
        NSMutableDictionary* dict = [_favStopDicts objectAtIndex:i];
        NSString* str = [dict objectForKey:STOP_ID_KEY];
        if( [str compare:[stop stopID]] == NSOrderedSame ) {
            [_favStopDicts removeObjectAtIndex:i];
            [self saveFavStops];
            break;
        }
    }
}

//- (void)saveTeamOrder:(NSMutableArray*)teams {
//    [teams_ release];
//    teams_ = [teams retain];
//    [self saveTeams];
//}

- (void)saveFavStops {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];    
    [prefs setObject:_favStopDicts  forKey:USER_DEFAULT_FAV_STOP_KEY];
}

- (NSMutableArray*) getFavoriteStopDict {
    return _favStopDicts;
}

- (void)dealloc {
}

@end
