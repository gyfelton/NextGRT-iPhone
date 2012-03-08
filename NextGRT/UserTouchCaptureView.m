//
//  UserTouchCaptureView.m
//  NextGRT
//
//  Created by Yuanfeng on 12-03-02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserTouchCaptureView.h"
#import "AppDelegate.h"

@implementation UserTouchCaptureView

@synthesize indexPath, customDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGFloat rightMostPoint = 0.0f;
    for (UITouch *touch in touches) {
        if ([touch locationInView:self].x > rightMostPoint)
            rightMostPoint = [touch locationInView:self].x;
    }
    if (rightMostPoint < 70) {
        _HUD = [[UIView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y-50, HUD_WIDTH, 50)];
        _HUD.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.7f];
        [self.superview addSubview:_HUD];
        _HUD.alpha = 0.0f;
        _HUD.layer.cornerRadius = 10.0f;
        
        _trackerOnHUD = [[UIView alloc] initWithFrame:CGRectMake(10, 15, 60, 40)];
        _trackerOnHUD.backgroundColor = [UIColor clearColor];
        _trackerOnHUD.layer.borderWidth = 3.0f;
        _trackerOnHUD.layer.borderColor = [[UIColor whiteColor] CGColor];
        _trackerOnHUD.layer.cornerRadius = 10.0f;
//        _trackerOnHUD.frame = CGRectOffset(_trackerOnHUD.frame, -1*_HUD.frame.size.width/2+20, 0);
        [_HUD addSubview:_trackerOnHUD];
        
        [UIView animateWithDuration:0.15f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^()
        {
            _HUD.alpha = 1.0f;
            _HUD.frame = CGRectOffset(_HUD.frame, 0, -10);
            _trackerOnHUD.frame = CGRectOffset(_trackerOnHUD.frame, 0, -10);
        } completion:^(BOOL finished){}];

        if (customDelegate && [customDelegate respondsToSelector:@selector(userDidBeginTouchOnView:)] ) {
            [customDelegate userDidBeginTouchOnView:self];
        }
    } else
    {
//        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGFloat xOrigin = [touch locationInView:self].x;
    NSLog(@"%f", xOrigin);
    if ( xOrigin > 5 && xOrigin < HUD_WIDTH-5-60) {
            _trackerOnHUD.frame = CGRectMake([touch locationInView:self].x, _trackerOnHUD.frame.origin.y, _trackerOnHUD.frame.size.width, _trackerOnHUD.frame.size.height);
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_HUD removeFromSuperview];
    if (customDelegate && [customDelegate respondsToSelector:@selector(userDidEndTouchOnView:)] ) {
        [customDelegate userDidEndTouchOnView:self];
    }
//    [super touchesMoved:touches withEvent:event];
}
@end
