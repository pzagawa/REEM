//
//  PZLaterItemsViewController.m
//  REEM
//
//  Created by Piotr Zagawa on 01.11.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import "PZLaterItemsViewController.h"
#import "PZModel.h"
#import "PZItemsTableViewHeader.h"
#import "PZReminderTableViewCell.h"

@interface PZLaterItemsViewController ()

@property (readonly) PZRemindersLaterList *remindersLater;

@property NSArray *itemsPostponed;
@property NSArray *itemsTomorrow;
@property NSArray *itemsAfterTomorrow;

@end

@implementation PZLaterItemsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self->_remindersLater = [[PZRemindersLaterList alloc] initWithEventStore:self.model.eventStore];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (PZDataListItemsType)listItemsType
{
    return PZDataListItemsTypeRemindersLater;
}

#pragma mark TableView

- (void)reloadDataItems
{
    [super reloadDataItems];

    [self.remindersLater fetchRemindersLater:^
    {
        @synchronized(self.remindersLater)
        {
            self.itemsPostponed = [self.remindersLater.itemsPostponed copy];
            self.itemsTomorrow = [self.remindersLater.itemsTomorrow copy];
            self.itemsAfterTomorrow = [self.remindersLater.itemsAfterTomorrow copy];
        }

        [self.tableView reloadData];
        
        [self resetScrollOffset];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = @"";
    int count = 0;
    
    @synchronized(self.remindersLater)
    {
        if (section == 0)
        {
            sectionTitle = [self titleForSection:PZDataListItemsSectionTypePostponed];
            count = (int)self.itemsPostponed.count;
        }
        
        if (section == 1)
        {
            sectionTitle = [self titleForSection:PZDataListItemsSectionTypeTomorrow];
            count = (int)self.itemsTomorrow.count;
        }

        if (section == 2)
        {
            sectionTitle = [self titleForSection:PZDataListItemsSectionTypeAfterTomorrow];
            count = (int)self.itemsAfterTomorrow.count;
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
    @synchronized(self.remindersLater)
    {
        if (section == 0)
        {
            return self.itemsPostponed.count;
        }
        
        if (section == 1)
        {
            return self.itemsTomorrow.count;
        }
        
        if (section == 2)
        {
            return self.itemsAfterTomorrow.count;
        }
    }
    
    return 0;
}

- (PZReminderItem *)reminderItemWithIndexPath:(NSIndexPath *)indexPath
{
    @synchronized(self.remindersLater)
    {
        PZReminderItem *reminderItem = nil;

        NSInteger row = indexPath.row;
        
        if (indexPath.section == 0)
        {
            if (row >= 0 && row <= (self.itemsPostponed.count - 1))
            {
                reminderItem = [self.itemsPostponed objectAtIndex:row];
                
                reminderItem.isShowDateEnabled = YES;
            }
        }
        
        if (indexPath.section == 1)
        {
            if (row >= 0 && row <= (self.itemsTomorrow.count - 1))
            {
                reminderItem = [self.itemsTomorrow objectAtIndex:row];
                
                reminderItem.isShowDateEnabled = NO;
            }
        }
        
        if (indexPath.section == 2)
        {
            if (row >= 0 && row <= (self.itemsAfterTomorrow.count - 1))
            {
                reminderItem = [self.itemsAfterTomorrow objectAtIndex:row];
                
                reminderItem.isShowDateEnabled = NO;
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
    @synchronized(self.remindersLater)
    {
        if (reminderCell.indexPath.section == 0)
        {
            self.itemsPostponed = [self removeItemFromArray:self.itemsPostponed atIndex:reminderCell.indexPath.row];
        }
        
        if (reminderCell.indexPath.section == 1)
        {
            self.itemsTomorrow = [self removeItemFromArray:self.itemsTomorrow atIndex:reminderCell.indexPath.row];
        }

        if (reminderCell.indexPath.section == 2)
        {
            self.itemsAfterTomorrow = [self removeItemFromArray:self.itemsAfterTomorrow atIndex:reminderCell.indexPath.row];
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
