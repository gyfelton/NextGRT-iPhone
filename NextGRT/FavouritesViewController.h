//
//  FirstViewController.h
//  NextGRT
//
//  Created by Yuanfeng on 12-01-13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavouritesViewController : UIViewController
{
     NSMutableArray* _favStops;
}
@property (nonatomic, strong) NSMutableArray* favStopsDict;

@end
