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
    _statusBarMsgViewLabel.textColor = [UIColor colorWithRed:188/263.0f green:206/255.0f blue:220/255.0f alpha:1.0f];
    _statusBarMsgViewLabel.shadowColor = [UIColor blackColor];
    _statusBarMsgViewLabel.shadowOffset = CGSizeMake(0, -1);
    _statusBarMsgViewLabel.font = [UIFont boldSystemFontOfSize:15];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = _statusBarMsgView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:80/255.0f green:106/255.0f blue:142/255.0f alpha:1.0f] CGColor], (id)[[UIColor colorWithRed:66/255.0f green:92/255.0f blue:132/255.0f alpha:1.0f] CGColor], (id)[[UIColor colorWithRed:64/255.0f green:91/255.0f blue:131/255.0f alpha:1.0f] CGColor], nil];
    [_statusBarMsgView.layer insertSublayer:gradient atIndex:0];
    
    _statusBarMsgView.backgroundColor = [UIColor colorWithRed:64/255.0f green:91/255.0f blue:131/255.0f alpha:1.0f];
    
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