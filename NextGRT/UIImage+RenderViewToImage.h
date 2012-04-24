//
//  UIImage+RenderViewToImage.h
//  NextGRT
//
//  Created by Yuanfeng on 12-04-23.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (RenderViewToImage)

+ (UIImage*)renderViewToImage:(UIView*)view;

+ (UIImage*)renderViewToImage:(UIView*)view fromViewFrame:(CGRect)frame;

@end
