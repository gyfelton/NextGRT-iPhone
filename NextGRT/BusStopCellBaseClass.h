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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void)initCellInfoWithStop:(Stop*)stop;
- (void)refreshRoutesInCell;
- (void)toggleFavButtonStatus;
- (void)askForEditingOfNickName;
@property BusStopCellType cellType;
@property (nonatomic, retain) UILabel* name;
@property (nonatomic, retain) UILabel* extraInfo;

@end

