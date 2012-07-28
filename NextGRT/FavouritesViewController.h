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
#import <MessageUI/MessageUI.h>

@interface FavouritesViewController : UIViewController <GRTDatabaseManagerDelegate, MBProgressHUDDelegate, BusStopBaseTabeViewDelegate, MFMessageComposeViewControllerDelegate>
{
    IBOutlet UIImageView *_welcomeHint;
    NSMutableArray* _favStops;
    BusStopBaseTableViewController* _favStopsTableVC;
    
    MBProgressHUD *_hud;
}

@property (nonatomic, strong) NSMutableArray* favStopsDict;

@end
