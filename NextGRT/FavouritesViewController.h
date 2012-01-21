//
//  FirstViewController.h
//  NextGRT
//
//  Created by Yuanfeng on 12-01-13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BusStopBaseTableViewController.h"
#import "GRTDatabaseManager.h"
#import "MBProgressHUD.h"

@interface FavouritesViewController : UIViewController <GRTDatabaseManagerDelegate, MBProgressHUDDelegate, BusStopBaseTabeViewDelegate>
{
    IBOutlet UILabel *_mainTitle;
    IBOutlet UITextView *_secTitle;
    NSMutableArray* _favStops;
    BusStopBaseTableViewController* _favStopsTableVC;
    
    MBProgressHUD *_hud;
}
@property (nonatomic, strong) NSMutableArray* favStopsDict;

@end
