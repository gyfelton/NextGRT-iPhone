//
//  MoreViewController.m
//  NextGRT
//
//  Created by Yuanfeng on 12-01-13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MoreViewController.h"
#import "AboutScreenViewController.h"

@implementation MoreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = local(@"More");
        //        self.tabBarItem.image = [UIImage imageNamed:@"first"];
        self.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:3];
        self.title = local(@"More");
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    switch (indexPath.row) {
        case 0:
        {
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.textLabel.text = local(@"Show Countdown");
            _countDownSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            [_countDownSwitch addTarget:self action:@selector(didToggleCountdownSwitch:) forControlEvents:UIControlEventValueChanged];
            
            NSDictionary *dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:USER_DEFAULT_KEY_COUNTDOWN];
            if (dict && [[dict objectForKey:@"bool"] boolValue]) {
                _countDownSwitch.on = YES;
            } else
            {
                _countDownSwitch.on = NO;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            //if actual time switch is no, should disable it
            dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:USER_DEFAULT_KEY_ACTUAL_TIME];
            if (dict && [[dict objectForKey:@"bool"] boolValue]) {
                _countDownSwitch.enabled = YES;
            } else
            {
                _countDownSwitch.enabled = NO;
            }
            
            cell.accessoryView = _countDownSwitch;
        }
            break;
        case 1:
        {
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.textLabel.text = local(@"Show Actual Time");
            _actualTimeSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            [_actualTimeSwitch addTarget:self action:@selector(didToggleActualTimeSwitch:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = _actualTimeSwitch;
            
            NSDictionary *dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:USER_DEFAULT_KEY_ACTUAL_TIME];
            if (dict && [[dict objectForKey:@"bool"] boolValue]) {
                _actualTimeSwitch.on = YES;
            } else
            {
                _actualTimeSwitch.on = NO;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
            break;
        case 2:
        {
            cell.textLabel.text = local(@"About");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
        case 3:
        {
            cell.textLabel.text = local(@"Rate this app");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        default:
            break;
    }

    
    return cell;
}

- (void)didToggleCountdownSwitch:(UISwitch*)uiSwitch
{
    BOOL value = uiSwitch.on;
    [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:value] forKey:@"bool"] forKey:USER_DEFAULT_KEY_COUNTDOWN];
    
    if (value) {
        _actualTimeSwitch.enabled = YES;
    }
}

- (void)didToggleActualTimeSwitch:(UISwitch*)uiSwitch
{
    BOOL value = uiSwitch.on;
    [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:value] forKey:@"bool"] forKey:USER_DEFAULT_KEY_ACTUAL_TIME];
    if (!value) {
        _countDownSwitch.on = YES;
        _countDownSwitch.enabled = NO;
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"bool"] forKey:USER_DEFAULT_KEY_COUNTDOWN];
    } else
    {
        _countDownSwitch.enabled = YES;
    }
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    switch (indexPath.row) {
        case 2:
        {
            AboutScreenViewController* about = [[AboutScreenViewController alloc] initWithNibName:@"AboutScreenViewController" bundle:nil];
            
            [self.navigationController pushViewController:about animated:YES];
        }
            break;
        case 3:
        {
            NSString *str = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa";
            str = [NSString stringWithFormat:@"%@/wa/viewContentsUserReviews?", str]; 
            str = [NSString stringWithFormat:@"%@type=Purple+Software&id=", str];
            
            //TODO! change app id
            // Here is the app id from itunesconnect
            str = [NSString stringWithFormat:@"%@289382458", str]; 
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        }
            break;
        default:
            break;
    }    
}


@end
