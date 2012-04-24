//
//  UIImage+RenderViewToImage.m
//  NextGRT
//
//  Created by Yuanfeng on 12-04-23.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImage+RenderViewToImage.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIImage (RenderViewToImage)

+ (UIImage*)renderViewToImage:(UIView*)view
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [UIScreen mainScreen].scale);
    else
        UIGraphicsBeginImageContext(view.frame.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage*)renderViewToImage:(UIView*)view fromViewFrame:(CGRect)frame
{
    UIImage *originalImage =  [self renderViewToImage:view];
    CGRect cropFrame = frame;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
    {
        CGFloat scale = [UIScreen mainScreen].scale;
        cropFrame = CGRectMake(cropFrame.origin.x*scale, cropFrame.origin.y*scale, cropFrame.size.width*scale, cropFrame.size.height*scale);
    }
    CGImageRef imageRef = CGImageCreateWithImageInRect([originalImage CGImage], cropFrame);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    return croppedImage;
}

@end
