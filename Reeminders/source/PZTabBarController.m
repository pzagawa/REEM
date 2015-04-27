//
//  PZTabBarController.m
//  REEM
//
//  Created by Piotr Zagawa on 02.11.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import "PZTabBarController.h"
#import "PZItemsTableViewController.h"
#import "PZReminderEditViewController.h"
#import "PZTagEditViewController.h"
#import "PZColors.h"
#import "PZUtils.h"
#import "PZItem.h"
#import "PZTodayItemsViewController.h"
#import "PZLaterItemsViewController.h"
#import "PZTagItemsViewController.h"

@interface PZTabBarController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnAddItem;

@property (readonly) PZRemindersTodayList *remindersToday;

@property (readonly) PZItemsTableViewController *selectedItemsViewController;

@end

@implementation PZTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self->_remindersToday = [[PZRemindersTodayList alloc] init];
    
    //set icons tint color
    self.tabBar.selectedImageTintColor = [UIColor colorWithRed:0.2 green:0.1 blue:0.0 alpha:1.0];
    
    //handle UITabBarControllerDelegate
    self.delegate = self;
    
    [[PZModel instance] initializeEventStore:^(BOOL granted, NSError *error)
    {
        NSLog(@"[PZTabBarController] viewDidLoad - event store initialization completed");
        
        if (granted)
        {
            NSLog(@"[PZTabBarController] access granted, fetching tags..");

            [[PZModel instance] fetchTags];
        }
        else
        {
            [[NSOperationQueue mainQueue] addOperation:[NSBlockOperation blockOperationWithBlock:^
            {
                NSString *message = @"REEM can't read or manage your reminders.\nYou can enable access to reminders in settings.";

                [[[UIAlertView alloc] initWithTitle:@"No access to reminders" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }]];
        }
    }];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

- (void)onApplicationDidBecomeActiveNotification:(NSNotification *)notification
{
    [self.remindersToday fetchRemindersTodayTodo:^
    {
        self.tabBarItem.badgeValue = self.remindersToday.expiredAlarmsCountText;
    }];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:PZItemsTableViewController.class])
    {
        PZItemsTableViewController *tableViewController = (PZItemsTableViewController *)viewController;
        
        self.title = tableViewController.title;
        
        [tableViewController reloadDataItems];
    }
}

- (PZDataListItemsType)selectedListItemsType
{
    if ([self.selectedViewController isKindOfClass:PZTodayItemsViewController.class])
    {
        return PZDataListItemsTypeRemindersToday;
    }
    
    if ([self.selectedViewController isKindOfClass:PZLaterItemsViewController.class])
    {
        return PZDataListItemsTypeRemindersLater;
    }

    if ([self.selectedViewController isKindOfClass:PZTagItemsViewController.class])
    {
        return PZDataListItemsTypeTags;
    }

    return -1;
}

- (PZItemsTableViewController *)selectedItemsViewController
{
    UIViewController *vc = self.selectedViewController;
    
    if (self.selectedListItemsType == PZDataListItemsTypeRemindersToday)
    {
        return (PZTodayItemsViewController *)vc;
    }

    if (self.selectedListItemsType == PZDataListItemsTypeRemindersLater)
    {
        return (PZLaterItemsViewController *)vc;
    }

    if (self.selectedListItemsType == PZDataListItemsTypeTags)
    {
        return (PZTagItemsViewController *)vc;
    }

    return nil;
}


#pragma mark UI actions

- (IBAction)addNewItem:(id)sender
{
    PZItemsTableViewController *itemsTable = self.selectedItemsViewController;

    if (self.selectedListItemsType == PZDataListItemsTypeRemindersToday)
    {
        [itemsTable showEditForReminderItem:nil withTagItem:nil];
    }
    
    if (self.selectedListItemsType == PZDataListItemsTypeRemindersLater)
    {
        [itemsTable showEditForReminderItem:nil withTagItem:nil];
    }
    
    if (self.selectedListItemsType == PZDataListItemsTypeTags)
    {
        [itemsTable showEditForTagItem:nil];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}

@end
