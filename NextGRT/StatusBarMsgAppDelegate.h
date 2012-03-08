//
//  StatusBarMsgAppDelegate.h
//  NextGRT
//
//  Created by Yuanfeng on 12-01-13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatusBarMsgAppDelegate : UIResponder <UIApplicationDelegate>
{
    UIView *_statusBarMsgView;
    UILabel *_statusBarMsgViewLabel;
}

- (void)showMessageAtStatusBarWithText:(NSString*)text duration:(NSTimeInterval)duration animated:(BOOL)animated;

@property (strong, nonatomic) UIWindow *window;

@end
