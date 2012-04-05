//
//  BusStopCellBaseClass.h
//  GRTEasyGo
//
//  Created by Yuanfeng on 11-07-06.
//  Copyright 2011 Elton(Yuanfeng) Gao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "Stop.h"

#define INSET_LEFT 13
#define INSET_RIGHT 30
#define NAME_WIDTH 280
#define NAME_HEIGHT 22
#define EXTRA_INFO_WIDTH 280
#define EXTRA_INFO_HEIGHT 16
#define EXTRA_INFO_FONT_SIZE 14.0
#define NAME_FONT @"Helvetica"
#define NAME_FONT_SIZE 20.0

enum BusStopCellType {
    cellForFavVC = 0,
    cellForSearchVC = 1
    };
typedef enum BusStopCellType BusStopCellType;

/**
 * Base Cell UI for each bus stop
 * Each cell represents a bus stop, consisting of basic info
 */
@interface BusStopCellBaseClass : UITableViewCell <UITextFieldDelegate,UIAlertViewDelegate> {
    //Showing bus stop name or custom name
    UILabel* name_;

    //Showing bus stop ID and original name if have customized name
    UILabel* extraInfo_;
    
    //fav button
    UIButton* fav_;
    
    UILabel* availableRoutes_;
    
    UITextField *customNameField_;
    UIAlertView* alert_;
    
    Stop* stop_;
    
    bool isStopFav_;
}

/**
 * Standard init method for cell
 */
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

/**
 * After cell is created, use this method to assign information to the cell
 * @param: Stop stop    cannot be nil value
 */
- (void)initCellInfoWithStop:(Stop*)stop;

/**
 * Call this to refresh the routes information inside this bus cell
 */
- (void)refreshRoutesInCell;

/**
 Tells the cell to toggle between fac and not-fav state
 */
- (void)toggleFavButtonStatus;

/**
 Trigger editing state of the nickname of the bus
 */
- (void)askForEditingOfNickName;

@property BusStopCellType cellType;

/**
 * Accesor/setter for name of the stop
 * Fully customizable
 */
@property (nonatomic, retain) UILabel* name;

/**
 * Accesor/setter for extraInfo of the stop
 * Fully customizable
 */
@property (nonatomic, retain) UILabel* extraInfo;

@end

