//
//  PZTodayItemsViewController.m
//  REEM
//
//  Created by Piotr Zagawa on 01.11.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import "PZTodayItemsViewController.h"
#import "PZModel.h"
#import "PZItemsTableViewHeader.h"
#import "PZReminderTableViewCell.h"
#import "PZReminderItem.h"

@interface PZTodayItemsViewController ()

@property (readonly) PZRemindersTodayList *remindersToday;

@property NSArray *itemsTodo;
@property NSArray *itemsDone;

@end

@implementation PZTodayItemsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self->_remindersToday = [[PZRemindersTodayList alloc] initWithEventStore:self.model.eventStore];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (PZDataListItemsType)listItemsType
{
    return PZDataListItemsTypeRemindersToday;
}

#pragma mark TableView

- (void)reloadDataItems
{
    [super reloadDataItems];
    
    [self.remindersToday fetchRemindersToday:^
    {
        @synchronized(self.remindersToday)
        {
            self.itemsTodo = [self.remindersToday.itemsTodo copy];
            self.itemsDone = [self.remindersToday.itemsDone copy];
        }
        
        self.tabBarItem.badgeValue = self.remindersToday.expiredAlarmsCountText;

        [self.tableView reloadData];

        [self restoreScrollOffset];
        
        [self resetScrollOffset];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = @"";
    int count = 0;
    
    @synchronized(self.remindersToday)
    {
        if (section == 0)
        {
            sectionTitle = [self titleForSection:PZDataListItemsSectionTypeToDo];
            count = (int)self.itemsTodo.count;
        }

        if (section == 1)
        {
            sectionTitle = [self titleForSection:PZDataListItemsSectionTypeDone];
            count = (int)self.itemsDone.count;
        }
    }
    
    if (count == 0)
    {
        return sectionTitle;
    }
    else
    {
        return [NSString stringWithFormat:@"%@: %i", sectionTitle, count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    @synchronized(self.remindersToday)
    {
        if (section == 0)
        {
            return self.itemsTodo.count;
        }
        
        if (section == 1)
        {
            return self.itemsDone.count;
        }
    }
    
    return 0;
}

- (PZReminderItem *)reminderItemWithIndexPath:(NSIndexPath *)indexPath
{
    @synchronized(self.remindersToday)
    {
        PZReminderItem *reminderItem = nil;
        
        NSInteger row = indexPath.row;
        
        if (indexPath.section == 0)
        {
            if (row >= 0 && row <= (self.itemsTodo.count - 1))
            {
                reminderItem = [self.itemsTodo objectAtIndex:row];
            }
        }
        
        if (indexPath.section == 1)
        {
            if (row >= 0 && row <= (self.itemsDone.count - 1))
            {
                reminderItem = [self.itemsDone objectAtIndex:row];
            }
        }
        
        return reminderItem;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    PZReminderTableViewCell *reminderCell = [tableView dequeueReusableCellWithIdentifier:@"cellReminder" forIndexPath:indexPath];
    
    PZReminderItem *reminderItem = [self reminderItemWithIndexPath:indexPath];

    if (reminderItem != nil)
    {
        reminderCell.delegate = self;
        
        reminderCell.indexPath = indexPath;
        
        reminderCell.dataItem = reminderItem;

        cell = reminderCell;
    }
    
    return cell;
}

- (void)removeReminderWithCell:(PZReminderTableViewCell *)reminderCell
{
    @synchronized(self.remindersToday)
    {
        if (reminderCell.indexPath.section == 0)
        {
            self.itemsTodo = [self removeItemFromArray:self.itemsTodo atIndex:reminderCell.indexPath.row];
        }
        
        if (reminderCell.indexPath.section == 1)
        {
            self.itemsDone = [self removeItemFromArray:self.itemsDone atIndex:reminderCell.indexPath.row];
        }
    }
    
    [self removeItemAtIndexPath:reminderCell.indexPath withCompletion:^
    {
        [reminderCell.dataItem commit];

        [self reloadDataItems];
    }];
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self scrollSwipeViewCellsBackExcept:nil];
}

#pragma mark PZTableViewCellDelegate

- (void)onSwipeStartActionWithCell:(PZTableViewCell *)cell
{
    [self scrollSwipeViewCellsBackExcept:cell];
}

- (void)onSwipeRightActionWithCell:(PZTableViewCell *)cell
{
    PZReminderTableViewCell *reminderCell = (PZReminderTableViewCell *)(cell);

    reminderCell.dataItem.isCompleted = !reminderCell.dataItem.isCompleted;

    [self removeReminderWithCell:reminderCell];
}

- (void)onSwipeLeftLockWithCell:(PZTableViewCell *)cell
{
    self.swipedCell = cell;
}

- (NSArray *)rightActionButtonsWithCell:(PZTableViewCell *)cell
{
    return @[ self.cellRightActionButtonDelete, self.cellRightActionButtonSetTime ];
}

#pragma mark PZTableViewCell buttons events

- (void)onTapCellRightActionButtonDelete:(id)sender
{
    PZReminderTableViewCell *reminderCell = (PZReminderTableViewCell *)(self.swipedCell);

    [self scrollSwipeViewCellsBackExcept:nil];
    
    [reminderCell.dataItem deleteItem];
    
    [self removeReminderWithCell:reminderCell];
}

- (void)onTapCellRightActionButtonSetTime:(id)sender
{
    PZReminderTableViewCell *reminderCell = (PZReminderTableViewCell *)(self.swipedCell);

    [self showAlarmSelectorForReminderCell:reminderCell];
}

#pragma mark Reminder selection

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PZReminderItem *reminderItem = [self reminderItemWithIndexPath:indexPath];

    [self showEditForReminderItem:reminderItem withTagItem:nil];
}

@end
