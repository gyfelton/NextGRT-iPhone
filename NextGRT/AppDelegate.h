//
//  AppDelegate.h
//  NextGRT
//
//  Created by Yuanfeng on 12-01-13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "StatusBarMsgAppDelegate.h"

@interface AppDelegate : StatusBarMsgAppDelegate <UITabBarControllerDelegate>

void uncaughtExceptionHandler(NSException *exception);

+ (CLLocationManager*) sharedLocationManager;

@property BOOL locationServiceBecomeActive;

@property (strong, nonatomic) UITabBarController *tabBarController;

@end
