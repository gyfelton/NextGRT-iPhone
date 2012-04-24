//
//  BusStopCellBaseClass.m
//  GRTEasyGo
//
//  Created by Yuanfeng on 11-07-06.
//  Copyright 2011 Elton(Yuanfeng) Gao. All rights reserved.
//

#import "BusStopCellBaseClass.h"
#import "Stop.h"
#import "BusRoute.h"
#import "FavouriteStopsCentralManager.h"

#define BUTTON_SIZE_WIDTH 280
#define BUTTON_SIZE_HEIGHT 15

#define SKIP_INDEX 0
#define CONFIRM_INDEX 1

#define ADD_FAV_ALERT_TAG 0
#define REMOVE_FAV_ALERT_TAG 1
#define EDIT_FAV_ALERT_TAG 2

@implementation BusStopCellBaseClass

@synthesize name = name_, extraInfo = extraInfo_, cellType;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        name_ = [[UILabel alloc] initWithFrame:CGRectMake(INSET_LEFT, 3, NAME_WIDTH, NAME_HEIGHT)];
        name_.shadowOffset = CGSizeMake(0, 1);
        name_.shadowColor = [UIColor whiteColor];
        name_.backgroundColor = [UIColor clearColor];
        name_.font = [UIFont boldSystemFontOfSize:NAME_FONT_SIZE];
        [self.contentView addSubview:name_];
        
        extraInfo_ = [[UILabel alloc] initWithFrame:CGRectMake(INSET_LEFT, NAME_HEIGHT+4, EXTRA_INFO_WIDTH, EXTRA_INFO_HEIGHT)];
        extraInfo_.font = [UIFont systemFontOfSize:EXTRA_INFO_FONT_SIZE];
        extraInfo_.textAlignment = UITextAlignmentLeft;
        extraInfo_.textColor = [UIColor grayColor];
        extraInfo_.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:extraInfo_];
        
        fav_ = [[UIButton alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width-INSET_RIGHT-10, 0, INSET_RIGHT, 80)];
        fav_.center = CGPointMake(fav_.center.x, self.contentView.center.y);
        fav_.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        fav_.showsTouchWhenHighlighted = YES;
        [fav_ setImage:[UIImage imageNamed:@"star_empty_big"] forState:UIControlStateNormal];
        [fav_ setImage:[UIImage imageNamed:@"star_full_big"] forState:UIControlStateHighlighted];
        [fav_ setImage:[UIImage imageNamed:@"star_full_big"] forState:UIControlStateSelected];
        [fav_ addTarget:self action:@selector(favPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:fav_];
        
        availableRoutes_ = [[UILabel alloc] initWithFrame:CGRectMake(INSET_LEFT, NAME_HEIGHT+EXTRA_INFO_HEIGHT+8, BUTTON_SIZE_WIDTH, BUTTON_SIZE_HEIGHT)];
        availableRoutes_.font = [UIFont systemFontOfSize:EXTRA_INFO_FONT_SIZE];
        availableRoutes_.backgroundColor = [UIColor clearColor];
        availableRoutes_.textAlignment = UITextAlignmentLeft;
        availableRoutes_.text = @"";
        availableRoutes_.shadowOffset = CGSizeMake(0, 1);
        availableRoutes_.shadowColor = [UIColor whiteColor];
        [self.contentView addSubview:availableRoutes_];
        
        UIImage *cellBg = [UIImage imageNamed:@"cell_bg"];
        cellBg = [cellBg stretchableImageWithLeftCapWidth:0 topCapHeight:1];
        self.backgroundView = [[UIImageView alloc] initWithImage:cellBg];
        
        cellType = cellForSearchVC; //by default
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (cellType == cellForFavVC) {
        fav_.userInteractionEnabled = NO;
    }
     fav_.center = CGPointMake(fav_.center.x, 32); 
}

- (void)toggleFavButtonStatus {
    isStopFav_ = !isStopFav_;
    fav_.selected = !fav_.selected;
}

- (void)initCellInfoWithStop:(Stop*)stop {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _stop = stop;
    
    if( [[FavouriteStopsCentralManager sharedInstance] isFavouriteStop:stop] ) {
        isStopFav_ = YES;
        fav_.selected = YES;
        
        NSString* result = [[FavouriteStopsCentralManager sharedInstance] getCustomNameForStop:stop];
        if( [result length] != 0 || ![result isEqualToString:@""]) {
            //if there is indeed a custom name, make it as main title
            name_.text = result;
            extraInfo_.text = [NSString stringWithFormat:@"%@, %@", stop.stopName, stop.stopID];
        } else {
            //otherwise, still put original stop name
            //TODO refractor this method(duplication)
            name_.text = stop.stopName;
            extraInfo_.text = [NSString stringWithFormat:local(@"Bus Stop ID: %@"), stop.stopID];
        }
    } else {
        isStopFav_ = NO;
        fav_.selected = NO;
        
        name_.text = stop.stopName;
        extraInfo_.text = [NSString stringWithFormat:local(@"Bus Stop ID: %@"), stop.stopID];
    }
}

- (void)refreshRoutesInCell {
    int numRoutesToDisplay = [_stop numberOfBusRoutes];
    //bool moreThanTwoRoues = numRoutesToDisplay>2 ? YES:NO;
    //numRoutesToDisplay = numRoutesToDisplay>=3 ? 3:numRoutesToDisplay;
    
    if (numRoutesToDisplay != 0) {
        availableRoutes_.text = numRoutesToDisplay==1?local(@"Bus route in op: ") : local(@"Bus routes in op: ");
        for (int i=0; i<numRoutesToDisplay; i++) {
            //        if( i != 2 ) {
            //            UILabel* label = [routesAndTimes_ objectAtIndex:i];
            //            BusRoute* route = [stop_.busRoutes objectAtIndex:i];
            //            
            //            //get the first arrival time
            //            label.text = [route getFirstArrivalTime];
            //        } else if( moreThanTwoRoues ) {
            //            UILabel* label = [routesAndTimes_ objectAtIndex:i];
            //            [label setText:@"••••••"];
            //        } else {
            //            UILabel* label = [routesAndTimes_ objectAtIndex:i];
            //            label.text = @"";
            //        }
            BusRoute* route = [_stop.busRoutes objectAtIndex:i];
            NSString* comma = (i==[_stop.busRoutes count]-1)? @"" :@",";
            availableRoutes_.text = [NSString stringWithFormat:@"%@%@%@ ", availableRoutes_.text, route.shortRouteNumber, comma];
        }
    } else {
        availableRoutes_.text = local(@"No bus route available.");
    }
}

#pragma mark - fav button delegate
- (void)favPressed {
    if (cellType == cellForSearchVC) {
        if( !isStopFav_ ) {
            [self toggleFavButtonStatus];
            
            alert_ = [[UIAlertView alloc] initWithTitle:local(@"Added to your favorite!")
                                                message:local(@"You can assign a nickname:\n\n\n")
                                               delegate:self 
                                      cancelButtonTitle:local(@"Skip") otherButtonTitles:local(@"Done"), nil];
            alert_.tag = ADD_FAV_ALERT_TAG;
            
            customNameField_ = [[UITextField alloc] initWithFrame:CGRectMake(14,77,254,30)];
            //        customNameField_.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 13, 10)];
            customNameField_.borderStyle = UITextBorderStyleBezel;
            customNameField_.clearButtonMode = UITextFieldViewModeWhileEditing;
            customNameField_.leftViewMode = UITextFieldViewModeAlways;
            customNameField_.layer.cornerRadius = 5.0f;
            customNameField_.font = [UIFont systemFontOfSize:18];
            customNameField_.backgroundColor = [UIColor whiteColor];
            customNameField_.keyboardAppearance = UIKeyboardAppearanceAlert;
            customNameField_.delegate = self;
            [customNameField_ setSelected:YES];
            //customNameField_.placeholder = local(@"enter the nickname here");
            
            [alert_ setTransform:CGAffineTransformMakeTranslation(0,109)];
            [alert_ show];
            
            [alert_ addSubview:customNameField_];
        } else {
            alert_ = [[UIAlertView alloc] initWithTitle:local(@"Remove Favourite Stop")
                                                message:local(@"Are you sure to do so?")
                                               delegate:self 
                                      cancelButtonTitle:local(@"Cancel") otherButtonTitles:local(@"Confirm"), nil];
            alert_.tag = REMOVE_FAV_ALERT_TAG;
            
            [alert_ show];
        }
    } else
    {
        //edit the nickname!
        alert_ = [[UIAlertView alloc] initWithTitle:local(@"Change Nickname")
                                            message:local(@"Or leave it blank to erase nickname\n\n\n")
                                           delegate:self 
                                  cancelButtonTitle:local(@"Cancel") otherButtonTitles:local(@"Done"), nil];
        alert_.tag = EDIT_FAV_ALERT_TAG;
        
        customNameField_ = [[UITextField alloc] initWithFrame:CGRectMake(14,77,254,30)];
        //        customNameField_.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 13, 10)];
        customNameField_.borderStyle = UITextBorderStyleBezel;
        customNameField_.clearButtonMode = UITextFieldViewModeWhileEditing;
        customNameField_.leftViewMode = UITextFieldViewModeAlways;
        customNameField_.layer.cornerRadius = 5.0f;
        customNameField_.font = [UIFont systemFontOfSize:18];
        customNameField_.backgroundColor = [UIColor whiteColor];
        customNameField_.keyboardAppearance = UIKeyboardAppearanceAlert;
        customNameField_.delegate = self;
        [customNameField_ setSelected:YES];
        customNameField_.placeholder = name_.text;
        //customNameField_.placeholder = local(@"enter the nickname here");
        
        [alert_ setTransform:CGAffineTransformMakeTranslation(0,109)];
        [alert_ show];
        
        [alert_ addSubview:customNameField_];
    }
}

- (void)askForEditingOfNickName
{
    [self favPressed]; //as if fav is pressed to trigger editing
}

#pragma mark - Text Field Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if( [[textField text] length] != 0 ) {
        [alert_ dismissWithClickedButtonIndex:CONFIRM_INDEX animated:YES];
    } else {
        textField.placeholder = local(@"Please enter a name!");
    }
    return YES;
}

#pragma mark - Alert View Delegate

- (void)didPresentAlertView:(UIAlertView *)alertView {
    [customNameField_ becomeFirstResponder];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    [customNameField_ resignFirstResponder];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if( alertView.tag == ADD_FAV_ALERT_TAG) {
        NSString *nickName = nil;
        if (buttonIndex == SKIP_INDEX) {
            nickName = @"";
        } else
        {
            nickName = [customNameField_ text];
        }
        
        [[FavouriteStopsCentralManager sharedInstance] addFavoriteStop:_stop Name:nickName];
        
        //refresh the cell's name (replace name with custom name)
        [self initCellInfoWithStop:_stop];
        
    } else if( alertView.tag == REMOVE_FAV_ALERT_TAG && buttonIndex == 1 ){
        //user confirmed to delete this fav
        [self toggleFavButtonStatus];
        [self setNeedsLayout]; //if this is not called, button will not become grey
        
        [[FavouriteStopsCentralManager sharedInstance] deleteFavoriteStop:_stop];
        
        //refresh the cell's name (remove custom name)
        [self initCellInfoWithStop:_stop];
    } else
    {
        if (buttonIndex == SKIP_INDEX) {
            //do nothing
        } else
        {
            [[FavouriteStopsCentralManager sharedInstance] editFavoriteStop:_stop Name:[customNameField_ text]];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    // Configure the view for the selected state
    [super setSelected:selected animated:animated];
}

#pragma mark - Memory Management

- (void)dealloc
{
    
}

@end

