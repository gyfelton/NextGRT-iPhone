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

@interface UserTouchCaptureView : UIView
{
    UIView *_HUD;
    UIView *_trackerOnHUD;
//    UIImageView *_glow;
}
@property (nonatomic, unsafe_unretained) id<UserTouchEventDelegate> customDelegate;
@property (nonatomic, strong) NSIndexPath *indexPath;
@end
