//
//  BusRoute.m
//  GRTEasyGo
//
//  Created by Yuanfeng on 11-07-05.
//  Copyright 2011 Elton(Yuanfeng) Gao. All rights reserved.
//

#import "BusRoute.h"
#import "CountDown.h"

@implementation BusRoute

@synthesize fullRouteNumber = fullRouteNumber_, shortRouteNumber = shortRouteNumber_, routeID = routeID_;

//init the route with first direction and its time
- (id) initWithRouteNumber:(NSString*)routeNumber routeID:(NSString*)routeID direction:(NSString*)dir AndTime:(NSString*)time {
    if( [routeNumber compare:@"200"] == NSOrderedSame ) {
        self.shortRouteNumber = @"iXps";
        self.fullRouteNumber = @"iXpress";
    } else {
        self.shortRouteNumber = routeNumber;
        self.fullRouteNumber = routeNumber;
    }
    
    self.routeID = routeID;
    nextArrivalTimes_ = [[NSMutableArray alloc] initWithObjects:time, nil];
    nextArrivalDirection_ = [[NSMutableArray alloc] initWithObjects:dir, nil];
    nextBusCountDown_ = [[NSMutableArray alloc] initWithObjects: nil];
    
    return self;
}

- (void) addNextArrivalTime:(NSString*)time Direction:(NSString*) direction {
    [nextArrivalTimes_ addObject:time];
    [nextArrivalDirection_ addObject:direction];
}

- (void) refreshCountDownWithSeconds:(NSTimeInterval)seconds {
    //simply modify every countDown object
    for( CountDown* countDown in nextBusCountDown_ ) {
        countDown.countDown = countDown.countDown - seconds;
    }
}

- (NSString*) getArrivalTime:(int) index {
    while( [nextBusCountDown_ count] > index+1 ) { //while there is a count down
        NSTimeInterval countDown = [[nextBusCountDown_ objectAtIndex:index] countDown];
        if( countDown < -30 ) {
            [nextBusCountDown_ removeObjectAtIndex:index];
            //TODO should combine them together so that they don't exist when count down is deleted
            [nextArrivalDirection_ removeObjectAtIndex:index];
            [nextArrivalTimes_ removeObjectAtIndex:index];
        } else if( countDown < 30 ) {
            return [NSString stringWithString:@"Due"];
        } else {
            return [self parseTimeInterval:countDown];
        }
    }
    //no more buses available;
    return [NSString stringWithString:@"No Service"];
}

- (NSString*) getNextBusDirection {
    if( [nextArrivalDirection_ count] > 1 ) {
        return [nextArrivalDirection_ objectAtIndex:0];
    }
    return @"";
}

- (NSString*) getFirstArrivalTime {
    return [self getArrivalTime:0];
}

- (NSString*) getSecondArrivalTime {
    NSString* result = [self getArrivalTime:1];
    if( [result compare:[NSString stringWithString:@"No Service"]] == NSOrderedSame ) {
        return [NSString stringWithString:@""];
    } else {
        return result;
    }
}

- (void) initNextArrivalCountDownBaesdOnTime:(NSDate*)time {
    //get time's date and year using dateFormatter
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString* currDateString = [dateFormat stringFromDate:time];
    
    //combination of currDateString and nextArrivalTime TODO: how abt time that is tmr?
    NSDateFormatter* inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; 
    
    //TODO nextArrival should be nextDeparture
    //loop through every nextArrivalTime and calculate the count down
    for( NSString* nextArrivalTime in nextArrivalTimes_ ) {
        int offset = 0;
        //Problem: the query actually return with some time as "24:13:00" which whill not be parsed correctly
        //Solution: if we get any hour value > 23, we chop it off and add it back to count down later
        NSArray* timeComponents = [nextArrivalTime componentsSeparatedByString:@":"];
        if( [timeComponents count] > 1 ) {
            NSString* hourComponent = [timeComponents objectAtIndex:0];
            int hour = [hourComponent intValue];
            if( hour > 23 ){
                offset = hour - 23;
                hour = 23; //adjust time to 23:min:sec, then add the missing hours back later
                //TODO: nextArrivalTime = [NSString stringWithFormat:@"%d:%@:%@", hour, [timeComponents objectAtIndex:1], [timeComponents objectAtIndex:1]];
            }
        }
        //now combine currDateString with nextBusTime to generate the actual time
        NSString* combined = [NSString stringWithFormat:@"%@ %@", currDateString, nextArrivalTime];
        NSDate* nextArrivalTimeInNSDate = [inputFormatter dateFromString:combined];
        
        if( nextArrivalTimeInNSDate ) {
            NSTimeInterval countDown = [nextArrivalTimeInNSDate timeIntervalSinceDate:time];
            countDown += offset * 3600; //add the missing hours back to countDown
            CountDown* c = [[CountDown alloc] initWithTimeInterval:countDown];
            [nextBusCountDown_ addObject: c];
            
            //NSLog(@"time countdown: %f", diff);
        } else {
            NSLog(@"ERROR! invalid nextArrivalTimeInNSDate");
        }   
    }
}

-(NSString*) parseTimeInterval:(NSTimeInterval) diff {
    //manually convert timeInterval to hour min and sec
    int hour = diff/3600;
    int minAndSec = (int)diff % 3600;
    int min = minAndSec / 60;
    int sec = minAndSec % 60;
    if( sec > 30 ) {
        min++; //count sec as a min
    }
    NSString* result;
    if( hour != 0 ) {
        result = [[NSString alloc] initWithFormat:@"%dh%02dm", hour, min]; //%02dh%02dm
    } else {
        //just output hour
        result = [[NSString alloc] initWithFormat:@"%dmin", min];
    }
    return result;
}

- (void)dealloc {
//    [fullRouteNumber_ release];
//    [shortRouteNumber_ release];    
//    [routeID_ release];  
//    [direction_ release];      
//    [nextArrivalTimes_ release];  
//    [nextArrivalDirection_ release];  
//    [nextBusCountDown_ release];  
//    [super dealloc];
}

@end
