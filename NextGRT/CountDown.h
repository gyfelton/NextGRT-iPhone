//
//  CountDown.h
//  GRTEasyGo
//
//  Created by Yuanfeng on 11-07-29.
//  Copyright 2011 Elton(Yuanfeng) Gao. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @class Countdown
 * A data model solely for each count down of next arrival time
 */
@interface CountDown : NSObject {
}

@property NSTimeInterval countDown;

/**
 * Init a new instance of Coutndown
 * @param NSTimeInterval interval   the count down in NSTimeInterval format
 * @return the new Coutndown instance
 */
- (id) initWithTimeInterval:(NSTimeInterval)interval;

@end
