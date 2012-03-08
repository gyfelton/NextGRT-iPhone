//
//  StatusBarMsgAppDelegate.m
//  NextGRT
//
//  Created by Yuanfeng on 12-01-13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "StatusBarMsgAppDelegate.h"

#define VIEW_HEIGHT 19

@implementation StatusBarMsgAppDelegate
@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //must set to transparent
    self.window.backgroundColor = [UIColor clearColor];
    // Override point for customization after application launch.
    
    //raise windows level by UIWindowLevelStatusBar + 1 so that whatever appears on status bar is not blocked by statusBar
    self.window.windowLevel = UIWindowLevelStatusBar+1;
    
    _statusBarMsgView = [[UIView alloc] initWithFrame:CGRectMake(0, -1 * VIEW_HEIGHT, self.window.frame.size.width, VIEW_HEIGHT)];
    _statusBarMsgView.backgroundColor = [UIColor clearColor];
//    _statusBarMsgView.layer.cornerRadius = 5.0f;
    
    _statusBarMsgViewLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _statusBarMsgView.frame.size.width, _statusBarMsgView.frame.size.height)];
    _statusBarMsgViewLabel.backgroundColor = [UIColor clearColor];
    [_statusBarMsgView addSubview:_statusBarMsgViewLabel];
    [self.window addSubview:_statusBarMsgView];
    
    _statusBarMsgView.hidden = YES;
    
    return YES;
}

- (void)removeStatusBarMsg:(BOOL)animated
{
    if (animated) {
        [UIView beginAnimations:@"transition" context:NULL];
    }

    _statusBarMsgView.frame = CGRectMake(0, -1 * VIEW_HEIGHT, _statusBarMsgView.frame.size.width, _statusBarMsgView.frame.size.height);
    if (animated) {
        [UIView commitAnimations];
    }    
}

- (void)showMessageAtStatusBarWithText:(NSString*)text duration:(NSTimeInterval)duration animated:(BOOL)animated
{
    _statusBarMsgViewLabel.text = text;
    _statusBarMsgViewLabel.textAlignment = UITextAlignmentCenter;
    _statusBarMsgViewLabel.textColor = [UIColor whiteColor];
    _statusBarMsgViewLabel.shadowColor = [UIColor blackColor];
    _statusBarMsgViewLabel.shadowOffset = CGSizeMake(0, 1);
    _statusBarMsgViewLabel.font = [UIFont boldSystemFontOfSize:15];
    _statusBarMsgView.backgroundColor = [UIColor colorWithRed:0.12f green:0.69f blue:0.99f alpha:1.0f];
    
    _statusBarMsgView.hidden = NO;
    
    if (animated) {
        [UIView beginAnimations:@"transition" context:NULL];
    }
    _statusBarMsgView.frame = CGRectMake(0, 0, _statusBarMsgView.frame.size.width, _statusBarMsgView.frame.size.height);
    if (animated) {
        [UIView commitAnimations];
    }
    if (duration < 0) {
        //infinity, don't remove
    } else
    {
        [self performSelector:@selector(removeStatusBarMsg:) withObject:[NSNumber numberWithBool:animated] afterDelay:duration];
    }
}

@end