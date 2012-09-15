//
//  UIDevice+Resolutions.h
//
//  Source: https://github.com/malcommac/iOSUtilities/tree/main/UIDevice+Resolutions
//  SO Page: http://stackoverflow.com/questions/12396545/how-to-deal-with-iphone-5-screen-size#comment16660870_12397738

#import <UIKit/UIKit.h>

enum {
    UIDevice_iPhoneStandardRes      = 1,    // iPhone 1,3,3GS Standard Resolution   (320x960px)
    UIDevice_iPhoneHiRes            = 2,    // iPhone 4,4S High Resolution          (640x960px)
    UIDevice_iPhoneTallerHiRes      = 3,    // iPhone 5 High Resolution             (640x1136px)
    UIDevice_iPadStandardRes        = 4,    // iPad 1,2 Standard Resolution         (1024x768px)
    UIDevice_iPadHiRes              = 5     // iPad 3 High Resolution               (2048x1536px)
}; typedef NSUInteger UIDeviceResolution;

@interface UIDevice (Resolutions) { }

+ (UIDeviceResolution) currentResolution;

@end
