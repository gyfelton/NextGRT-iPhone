//
//  CountDown.m
//  GRTEasyGo
//
//  Created by Yuanfeng on 11-07-29.
//  Copyright 2011 Elton(Yuanfeng) Gao. All rights reserved.
//

#import "CountDown.h"


@implementation CountDown

@synthesize countDown;

- (id) initWithTimeInterval:(NSTimeInterval)interval { 
    self.countDown = interval;
    return self;
}

- (void)dealloc {

}
@end
