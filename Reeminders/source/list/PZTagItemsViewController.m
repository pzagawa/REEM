//
//  PZTagItemsViewController.m
//  REEM
//
//  Created by Piotr Zagawa on 02.11.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import "PZTagItemsViewController.h"
#import "PZModel.h"
#import "PZItemsTableViewHeader.h"
#import "PZTagTableViewCell.h"
#import "PZReminderItemsViewController.h"

@interface PZTagItemsViewController ()

@property (readonly) PZTagsList *tags;

@property NSArray *items;

@property (readonly) UIAlertView *alertView;

@property (weak) PZTagItem *selectedTagItem;

@end

@implementation PZTagItemsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self->_tags = [[PZTagsList alloc] init];
    
    self->_alertView = [[UIAlertView alloc ] initWithTitle:@"Do you want to remove" message:@"tag with all reminders?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"YES, remove it!", nil];
    
    self.alertView.alertViewStyle = UIAlertViewStyleDefault;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (PZDataListItemsType)listItemsType
{
    return PZDataListItemsTypeTags;
}

#pragma mark TableView

- (void)reloadDataItems
{
    [super reloadDataItems];
    
    [self.tags fetchTags:^
    {
        @synchronized(self.tags)
        {
            self.items = [self.tags.items copy];
        }
        
        [self.tableView reloadData];
        
        [self resetScrollOffset];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = @"";
    int count = 0;
    
    @synchronized(self.tags)
    {
        if (section == 0)
        {
            sectionTitle = [self titleForSection:PZDataListItemsSectionTypeAllTags];
            count = (int)self.items.count;
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
    @synchronized(self.tags)
    {
        if (section == 0)
        {
            return self.items.count;
        }
    }
    
    return 0;
}

- (PZTagItem *)tagItemWithIndexPath:(NSIndexPath *)indexPath
{
    @synchronized(self.tags)
    {
        PZTagItem *tagItem = nil;

        NSInteger row = indexPath.row;
        
        if (indexPath.section == 0)
        {
            if (row >= 0 && row <= (self.items.count - 1))
            {
                tagItem = [self.items objectAtIndex:indexPath.row];
            }
        }
        
        return tagItem;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    PZTagTableViewCell *tagCell = [tableView dequeueReusableCellWithIdentifier:@"cellTag" forIndexPath:indexPath];
    
    PZTagItem *tagItem = [self tagItemWithIndexPath:indexPath];
    
    if (tagItem != nil)
    {
        tagCell.delegate = self;
        
        tagCell.indexPath = indexPath;

        tagCell.dataItem = tagItem;

        cell = tagCell;
    }
    
    return cell;
}

- (void)removeCalendarWithCell:(PZTagTableViewCell *)tagCell
{
    @synchronized(self.tags)
    {
        if (tagCell.indexPath.section == 0)
        {
            self.items = [self removeItemFromArray:self.items atIndex:tagCell.indexPath.row];
        }
    }
    
    [self removeItemAtIndexPath:tagCell.indexPath withCompletion:^
    {
        [tagCell.dataItem commit];

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

- (void)onSwipeLeftLockWithCell:(PZTableViewCell *)cell
{
    self.swipedCell = cell;
}

- (NSArray *)rightActionButtonsWithCell:(PZTableViewCell *)cell
{
    return @[ self.cellRightActionButtonDelete ];
}

#pragma mark PZTableViewCell buttons events

- (void)onTapCellRightActionButtonDelete:(id)sender
{
    PZTagTableViewCell *tagCell = (PZTagTableViewCell *)(self.swipedCell);

    NSString *message = [NSString stringWithFormat:@"\n\"%@\"\n\ntag with all reminders?", tagCell.dataItem.name];
    
    self.alertView.message = message;

    [self.alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self scrollSwipeViewCellsBackExcept:nil];
    }

    if (buttonIndex == 1)
    {
        PZTagTableViewCell *tagCell = (PZTagTableViewCell *)(self.swipedCell);
        
        [self scrollSwipeViewCellsBackExcept:nil];
        
        [tagCell.dataItem deleteItem];
        
        [self removeCalendarWithCell:tagCell];
    }
}

#pragma mark Tag selection

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PZTagItem *tagItem = [self tagItemWithIndexPath:indexPath];

    NSLog(@"[PZTagItemsViewController] tapped calendar: %@", tagItem);

    self.selectedTagItem = tagItem;
    
    return indexPath;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueReminders"])
    {
        PZReminderItemsViewController *vc = segue.destinationViewController;

        vc.tagItem = self.selectedTagItem;
    }
}

- (void)onLongPressWithCell:(PZTableViewCell *)cell
{
    NSLog(@"[PZItemsTableViewController] onLongPressWithCell: %@", cell);
    
    PZTagTableViewCell *tagCell = (PZTagTableViewCell *)(cell);
    
    [self showEditForTagItem:tagCell.dataItem];
}

@end
