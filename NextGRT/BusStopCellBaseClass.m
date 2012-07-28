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

@synthesize name = _name, extraInfo = _extraInfo, cellType;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _name = [[UILabel alloc] initWithFrame:CGRectMake(INSET_LEFT, 3, NAME_WIDTH, NAME_HEIGHT)];
        _name.shadowOffset = CGSizeMake(0, 1);
        _name.shadowColor = [UIColor whiteColor];
        _name.backgroundColor = [UIColor clearColor];
        _name.font = [UIFont boldSystemFontOfSize:NAME_FONT_SIZE];
        [self.contentView addSubview:_name];
        
        _extraInfo = [[UILabel alloc] initWithFrame:CGRectMake(INSET_LEFT, NAME_HEIGHT+4, EXTRA_INFO_WIDTH, EXTRA_INFO_HEIGHT)];
        _extraInfo.font = [UIFont systemFontOfSize:EXTRA_INFO_FONT_SIZE];
        _extraInfo.textAlignment = UITextAlignmentLeft;
        _extraInfo.textColor = [UIColor grayColor];
        _extraInfo.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_extraInfo];
        
        _fav = [[UIButton alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width-INSET_RIGHT-10, 0, INSET_RIGHT, 80)];
        _fav.center = CGPointMake(_fav.center.x, self.contentView.center.y);
        _fav.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        _fav.showsTouchWhenHighlighted = YES;
        [_fav setImage:[UIImage imageNamed:@"star_empty_big"] forState:UIControlStateNormal];
        [_fav setImage:[UIImage imageNamed:@"star_full_big"] forState:UIControlStateHighlighted];
        [_fav setImage:[UIImage imageNamed:@"star_full_big"] forState:UIControlStateSelected];
        [_fav addTarget:self action:@selector(favPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_fav];
        
        _availableRoutes = [[UILabel alloc] initWithFrame:CGRectMake(INSET_LEFT, NAME_HEIGHT+EXTRA_INFO_HEIGHT+8, BUTTON_SIZE_WIDTH, BUTTON_SIZE_HEIGHT)];
        _availableRoutes.font = [UIFont systemFontOfSize:EXTRA_INFO_FONT_SIZE];
        _availableRoutes.backgroundColor = [UIColor clearColor];
        _availableRoutes.textAlignment = UITextAlignmentLeft;
        _availableRoutes.text = @"";
        _availableRoutes.shadowOffset = CGSizeMake(0, 1);
        _availableRoutes.shadowColor = [UIColor whiteColor];
        [self.contentView addSubview:_availableRoutes];
        
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
        _fav.userInteractionEnabled = NO;
    }
     _fav.center = CGPointMake(_fav.center.x, 32); 
}

- (void)toggleFavButtonStatus {
    _isStopFav = !_isStopFav;
    _fav.selected = !_fav.selected;
}

- (void)initCellInfoWithStop:(Stop*)stop {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _stop = stop;
    
    if( [[FavouriteStopsCentralManager sharedInstance] isFavouriteStop:stop] ) {
        _isStopFav = YES;
        _fav.selected = YES;
        
        NSString* result = [[FavouriteStopsCentralManager sharedInstance] getCustomNameForStop:stop];
        if( [result length] != 0 || ![result isEqualToString:@""]) {
            //if there is indeed a custom name, make it as main title
            _name.text = result;
            _extraInfo.text = [NSString stringWithFormat:@"%@, %@", stop.stopName, stop.stopID];
        } else {
            //otherwise, still put original stop name
            //TODO refractor this method(duplication)
            _name.text = stop.stopName;
            _extraInfo.text = [NSString stringWithFormat:local(@"Bus Stop ID: %@"), stop.stopID];
        }
    } else {
        _isStopFav = NO;
        _fav.selected = NO;
        
        _name.text = stop.stopName;
        _extraInfo.text = [NSString stringWithFormat:local(@"Bus Stop ID: %@"), stop.stopID];
    }
}

- (void)refreshRoutesInCell {
    int numRoutesToDisplay = [_stop numberOfDistinctBusRoutes];
    //bool moreThanTwoRoues = numRoutesToDisplay>2 ? YES:NO;
    //numRoutesToDisplay = numRoutesToDisplay>=3 ? 3:numRoutesToDisplay;
    
    if (numRoutesToDisplay != 0) {
        _availableRoutes.text = numRoutesToDisplay==1?local(@"Bus route: ") : local(@"Bus routes: ");
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
            NSString* routeName = [_stop.distinctBusRoutesName objectAtIndex:i];
            NSString* comma = (i==[_stop.distinctBusRoutesName count]-1)? @"" :@",";
            _availableRoutes.text = [NSString stringWithFormat:@"%@%@%@ ", _availableRoutes.text, routeName, comma];
        }
    } else {
        _availableRoutes.text = local(@"No bus route available.");
    }
}

#pragma mark - fav button delegate
- (void)favPressed {
    if (cellType == cellForSearchVC) {
        if( !_isStopFav ) {
            [self toggleFavButtonStatus];
            
            _alert = [[UIAlertView alloc] initWithTitle:local(@"Added to your favorite!")
                                                message:local(@"You can assign a nickname:\n\n\n")
                                               delegate:self 
                                      cancelButtonTitle:local(@"Skip") otherButtonTitles:local(@"Done"), nil];
            _alert.tag = ADD_FAV_ALERT_TAG;
            
            _customNameField = [[UITextField alloc] initWithFrame:CGRectMake(14,77,254,28)];
            //        customNameField_.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 13, 10)];
            _customNameField.borderStyle = UITextBorderStyleRoundedRect;
            _customNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
            _customNameField.leftViewMode = UITextFieldViewModeAlways;
            _customNameField.font = [UIFont systemFontOfSize:18];
            _customNameField.backgroundColor = [UIColor whiteColor];
            _customNameField.keyboardAppearance = UIKeyboardAppearanceAlert;
            _customNameField.delegate = self;
            [_customNameField setSelected:YES];
            //customNameField_.placeholder = local(@"enter the nickname here");
            
            [_alert setTransform:CGAffineTransformMakeTranslation(0,109)];
            [_alert show];
            
            [_alert addSubview:_customNameField];
        } else {
            _alert = [[UIAlertView alloc] initWithTitle:local(@"Remove Favourite Stop")
                                                message:local(@"Are you sure to do so?")
                                               delegate:self 
                                      cancelButtonTitle:local(@"Cancel") otherButtonTitles:local(@"Confirm"), nil];
            _alert.tag = REMOVE_FAV_ALERT_TAG;
            
            [_alert show];
        }
    } else
    {
        //edit the nickname!
        _alert = [[UIAlertView alloc] initWithTitle:local(@"Change Nickname")
                                            message:local(@"Or leave it blank to erase nickname\n\n\n")
                                           delegate:self 
                                  cancelButtonTitle:local(@"Cancel") otherButtonTitles:local(@"Done"), nil];
        _alert.tag = EDIT_FAV_ALERT_TAG;
        
        _customNameField = [[UITextField alloc] initWithFrame:CGRectMake(14,77,254,28)];
        //        customNameField_.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 13, 10)];
        _customNameField.borderStyle = UITextBorderStyleRoundedRect;
        _customNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _customNameField.leftViewMode = UITextFieldViewModeAlways;
        _customNameField.font = [UIFont systemFontOfSize:18];
        _customNameField.backgroundColor = [UIColor whiteColor];
        _customNameField.keyboardAppearance = UIKeyboardAppearanceAlert;
        _customNameField.delegate = self;
        [_customNameField setSelected:YES];
        _customNameField.placeholder = _name.text;
        //customNameField_.placeholder = local(@"enter the nickname here");
        
        [_alert setTransform:CGAffineTransformMakeTranslation(0,109)];
        [_alert show];
        
        [_alert addSubview:_customNameField];
    }
}

- (void)askForEditingOfNickName
{
    [self favPressed]; //as if fav is pressed to trigger editing
}

#pragma mark - Text Field Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if( [[textField text] length] != 0 ) {
        [_alert dismissWithClickedButtonIndex:CONFIRM_INDEX animated:YES];
    } else {
        textField.placeholder = local(@"Please enter a name!");
    }
    return YES;
}

#pragma mark - Alert View Delegate

- (void)didPresentAlertView:(UIAlertView *)alertView {
    [_customNameField becomeFirstResponder];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    [_customNameField resignFirstResponder];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if( alertView.tag == ADD_FAV_ALERT_TAG) {
        NSString *nickName = nil;
        if (buttonIndex == SKIP_INDEX) {
            nickName = @"";
        } else
        {
            nickName = [_customNameField text];
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
            [[FavouriteStopsCentralManager sharedInstance] editFavoriteStop:_stop Name:[_customNameField text]];
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

