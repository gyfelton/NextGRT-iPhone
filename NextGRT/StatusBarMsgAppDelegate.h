//
//  StatusBarMsgAppDelegate.h
//  NextGRT
//
//  Created by Yuanfeng on 12-01-13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * @class A subclass of UIResponder having the ability to show a msg on the status bar
 * To use this class, just subclass the app delegate from this class
 */
@interface StatusBarMsgAppDelegate : UIResponder <UIApplicationDelegate>
{
    UIView *_statusBarMsgView;
    UILabel *_statusBarMsgViewLabel;
}

/**
 * Use this method to show the msg on the status bar
 * @param NSString text         The text to show
 * @param NSTimeInterval duration       The duration for the msg to show, -1 if msg is shown forever
 * @param BOOL animated         indicate whether the msg is shown instantly or slides out
 */
- (void)showMessageAtStatusBarWithText:(NSString*)text duration:(NSTimeInterval)duration animated:(BOOL)animated;

@property (strong, nonatomic) UIWindow *window;

@end
