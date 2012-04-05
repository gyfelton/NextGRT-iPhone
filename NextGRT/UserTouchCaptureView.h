//
//  UserTouchCaptureView.h
//  NextGRT
//
//  Created by Yuanfeng on 12-03-02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define HUD_WIDTH 295

@class UserTouchCaptureView;

@protocol UserTouchEventDelegate <NSObject>
@required
- (void)userDidBeginTouchOnView:(UserTouchCaptureView*)view;
- (void)userDidEndTouchOnView:(UserTouchCaptureView*)view;

@end

/**
 * A subclass of UIView that tries to cathch user's touch and move a area that moves according to user finger's movement
 */
@interface UserTouchCaptureView : UIView
{
    UIView *_HUD;
    UIView *_trackerOnHUD;
//    UIImageView *_glow;
}

/**
 * delegate can receive events about user touches and user end the touch
 */
@property (nonatomic, unsafe_unretained) id<UserTouchEventDelegate> customDelegate;

/**
 * This view is floating on each cell, so needs the cell's indexPath info
 */
@property (nonatomic, strong) NSIndexPath *indexPath;

@end
