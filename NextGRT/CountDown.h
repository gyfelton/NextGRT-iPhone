//
//  CountDown.h
//  GRTEasyGo
//
//  Created by Yuanfeng on 11-07-29.
//  Copyright 2011 Elton(Yuanfeng) Gao. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CountDown : NSObject {
}

@property NSTimeInterval countDown;

- (id) initWithTimeInterval:(NSTimeInterval)interval;

@end
