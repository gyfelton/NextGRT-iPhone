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
            if (debug) {
                NSLog(@"%@ is a fav stop!", [stop stopID]);
            }
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

- (BOOL)addFavoriteStop:(Stop*)stop Name:(NSString*)name {
    if (![self isFavouriteStop:stop]) {
        //use mutable dictionary so that we can modify custom name in the future
        NSMutableDictionary* stopDict = [[NSMutableDictionary alloc] initWithObjects:
                                    [NSArray arrayWithObjects:[stop stopID],name, nil] 
                                    forKeys:[NSArray arrayWithObjects: STOP_ID_KEY, STOP_CUSTOM_NAME_KEY, nil]];
        [_favStopDicts addObject:stopDict];
        [self saveFavStops];
        [[NSNotificationCenter defaultCenter] postNotificationName:kFavStopArrayDidUpdateNotification object:nil];
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)editFavoriteStop:(Stop*)stop Name:(NSString*)name {
    if ([self isFavouriteStop:stop]) {
        for( NSMutableDictionary* dict in _favStopDicts ) {
            NSString* str = [dict objectForKey:STOP_ID_KEY];
            if( [str compare:[stop stopID]] == NSOrderedSame ) {
                [dict setValue:name forKey:STOP_CUSTOM_NAME_KEY];
                [self saveFavStops];
                [[NSNotificationCenter defaultCenter] postNotificationName:kFavStopArrayDidUpdateNotification object:nil];
                return YES;
            }
        }
       
    } else {
    }
    return NO;
}

- (BOOL) moveStopAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destIndex
{
    if ((sourceIndex < [_favStopDicts count]) && (destIndex < [_favStopDicts count])) {
        NSMutableDictionary *stopDict = [_favStopDicts objectAtIndex:sourceIndex];
        [_favStopDicts removeObjectAtIndex:sourceIndex];
        [_favStopDicts insertObject:stopDict atIndex:destIndex];
        [self saveFavStops];
        [[NSNotificationCenter defaultCenter] postNotificationName:kFavStopArrayDidUpdateNotification object:nil];
        return YES;
    } else
    {
        return NO;
    }
}

- (BOOL) deleteFavoriteStop:(Stop*)stop {
    for( int i=0; i<[_favStopDicts count]; i++ ) {
        NSMutableDictionary* dict = [_favStopDicts objectAtIndex:i];
        NSString* str = [dict objectForKey:STOP_ID_KEY];
        if( [str compare:[stop stopID]] == NSOrderedSame ) {
            [_favStopDicts removeObjectAtIndex:i];
            [self saveFavStops];
            [[NSNotificationCenter defaultCenter] postNotificationName:kFavStopArrayDidUpdateNotification object:nil];
            return YES;
            break;
        }
    }
    return NO;
}

- (BOOL)deleteFavoriteStopAtIndex:(NSInteger)index
{
    if ([_favStopDicts count]>index) {
        [_favStopDicts removeObjectAtIndex:index];
        [self saveFavStops];
        [[NSNotificationCenter defaultCenter] postNotificationName:kFavStopArrayDidUpdateNotification object:nil];
        return YES;
    } else
    {
        return NO;
    }
}

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
