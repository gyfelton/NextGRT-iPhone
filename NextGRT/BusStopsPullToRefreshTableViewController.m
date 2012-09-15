//  BusStopsPullToRefreshLoadMoreTableViewController.m
//
//  Created by Jesse Collis on 1/07/10.
//  Copyright 2010 JC Multimedia Design. All rights reserved.
//
//  source: https://github.com/jessedc/EGOTableViewPullRefresh
//
//  Modified by Elton(Yuanfeng) Gao. All rihgts reserved
//  Does not inherit from original class as objective-C does not support multiple inheritance
//  Support pull down to reload location


#import "BusStopsPullToRefreshTableViewController.h"
#import "EGORefreshTableHeaderView.h"


@implementation BusStopsPullToRefreshTableViewController
@synthesize reloading=_reloading, needLoadMoreButton;
@synthesize refreshHeaderView;
@synthesize delegate;
@synthesize isAskingForManualLocation;

#pragma mark -
#pragma mark View lifecycle

- (id)initWithTableWidth:(CGFloat)width Height:(CGFloat)height Stops:(NSMutableArray*)s andDelegate:(id)object needLoadMoreStopsButton:(BOOL) needMore {
    self = [super initWithTableWidth:width Height:height Stops:s];
    if( self ) {
        self.needLoadMoreButton = needMore;
        self.delegate = object;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	 if (refreshHeaderView == nil) {
		 refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, 320.0f, self.tableView.bounds.size.height)];
		 refreshHeaderView.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
		 refreshHeaderView.bottomBorderThickness = 1.0;
		 [self.tableView addSubview:refreshHeaderView];
		 self.tableView.showsVerticalScrollIndicator = YES;
	 }
    [self.refreshHeaderView setLastRefreshDate:nil];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

#pragma mark -
#pragma mark Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    // Return the number of sections.
//    return 1;
//}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return @"Within 100m";
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //detect whether it's for needMoreButton first
    //take care of special case when there is no stop
    if( [[super stops] count] == 0 || ([indexPath row] > [[super stops] count]) ) {
        return NEED_MORE_BUTTON_HEIGHT;
    } else {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath]; //call super for height if not a load more button
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int oneMoreRow = needLoadMoreButton? 1: 0;
    // Return the number of rows in the section.
    return [super tableView:tableView numberOfRowsInSection:(NSInteger)section] + oneMoreRow;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell* cell = nil;
    
    //if it is need more button, load cell for loadMore...
    if( [indexPath row] >= [[super stops] count] ) {
        //if there is only two cells, just open all of them
        //TODO custom cell that has an indicator on it
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"needMoreButton"];
        if( !cell ) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"needMoreButton"];
        }
        cell.textLabel.numberOfLines = 2;
        if( [[super stops] count] == 0 ) { //if there is no stop found, ask user to expand search radius
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = local(@"No stops nearby. Click here to expand search radius.");
                    cell.textLabel.textColor = [UIColor darkGrayColor];
                    cell.textLabel.font = [UIFont systemFontOfSize:14];
                    break;
                case 2: //thid row
                    cell.textLabel.text = local(@"No stops nearby. Click here to expand search radius.");
                    cell.textLabel.textColor = [UIColor darkGrayColor];
                    cell.textLabel.font = [UIFont systemFontOfSize:14];
                    break;
                default:
                    break;
            }
        } else {
            cell.textLabel.text = local(@"Load more stops...");
        }
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    assert(cell);
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //first check whether it is the need more button
    if( [indexPath row] >= [[super stops] count] ) {
        switch (indexPath.row) {
            case 0:
                [self.tableView cellForRowAtIndexPath:indexPath].textLabel.text = local(@"Loading...");
                break;
            case 2:
                [self.tableView cellForRowAtIndexPath:indexPath].textLabel.text = local(@"Loading...");
                self.isAskingForManualLocation = YES;
                break;
            default:
                [self.tableView cellForRowAtIndexPath:indexPath].textLabel.text = local(@"Loading...");
                break;
        }
        //TODO what the heck? if not use this UI will freeze....
        [self performSelector:@selector(requestForMoreStops) withObject:nil afterDelay:0.02];
    } else {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (void) requestForMoreStops {
    [delegate requestForMoreStops];
}

#pragma mark -
#pragma mark ScrollView Callbacks
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	
	if (scrollView.isDragging) {
		if (refreshHeaderView.state == EGOOPullRefreshPulling && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f && !_reloading) {
			[refreshHeaderView setState:EGOOPullRefreshNormal];
		} else if (refreshHeaderView.state == EGOOPullRefreshNormal && scrollView.contentOffset.y < -65.0f && !_reloading) {
			[refreshHeaderView setState:EGOOPullRefreshPulling];
		}
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	if (scrollView.contentOffset.y <= - 65.0f && !_reloading) {
		_reloading = YES;
		[refreshHeaderView setState:EGOOPullRefreshLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		self.tableView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
        [self reloadTableViewDataSource];
	}
}

#pragma mark -
#pragma mark refreshHeaderView Methods

- (void) reloadDataAndStopLoadingAnimation {
    //TODO load more cells with animation
    [self.tableView reloadData];
    //if this reload data is triggered by pull to refresh...
    if( self.reloading ) {
        [self dataSourceDidFinishLoadingNewData];
        [refreshHeaderView setCurrentDate];  //  should check if location is got successfully!!! if not this date should not be updated

    } else {
        //if it is triggered by load more button
    }
}

- (void)dataSourceDidFinishLoadingNewData{
	_reloading = NO;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[self.tableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	
	[refreshHeaderView setState:EGOOPullRefreshNormal];
}

- (void) reloadTableViewDataSource
{
	//TODO should the loading of bus stops be done by this controller or its parent?
    [self.delegate requestForNewGeoLocation]; //ask parent controller to reload geolocation
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
	refreshHeaderView=nil;
    [super viewDidUnload];
}


- (void)dealloc {
}


@end

