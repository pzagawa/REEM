//
//  PZItemsTableViewController.m
//  Reeminders
//
//  Created by Piotr on 02.08.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import "PZItemsTableViewController.h"
#import "PZItemsTableViewHeader.h"
#import "PZItemsList.h"
#import "PZAlarmSelectorView.h"
#import "PZReminderTableViewCell.h"
#import "PZReminderEditViewController.h"
#import "PZTagEditViewController.h"
#import "PZNavigationController.h"

@interface PZItemsTableViewController ()

@property (readonly) NSDateFormatter *sectionDateFormatter;
@property (readonly) NSCalendar *calendar;
@property (readonly) NSCalendarUnit calendarUnits;

@property NSValue *savedScrollOffsetPoint;

@property PZAlarmSelectorView *alarmSelector;

@end

@implementation PZItemsTableViewController
{
    PZDataListItemsType _listItemsType;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self->_model = [PZModel instance];

    self->_tableViewHeader = [[PZItemsTableViewHeader alloc] init];
    
    self->_sectionDateFormatter = [NSDateFormatter new];
    
    [self.sectionDateFormatter setDateFormat:@"EEEE, d MMMM"];
    [self.sectionDateFormatter setLocale:[NSLocale currentLocale]];
    
    self->_calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    self->_calendarUnits = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute);
    
    self->_cellRightActionButtonDelete = [PZTableViewCell createCustomButtonWithImageNamed:@"list_item_action_delete.png"];
    self->_cellRightActionButtonSetTime = [PZTableViewCell createCustomButtonWithImageNamed:@"list_item_action_time.png"];
    
    [self.cellRightActionButtonDelete addTarget:self action:@selector(onTapCellRightActionButtonDelete:) forControlEvents:UIControlEventTouchUpInside];
    [self.cellRightActionButtonSetTime addTarget:self action:@selector(onTapCellRightActionButtonSetTime:) forControlEvents:UIControlEventTouchUpInside];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onModelNotification:) name:NOTIFICATION_MODEL_EVENT_STORE_INITIALIZED object:self];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onModelEventStoreFetchingFinishedNotification:) name:NOTIFICATION_MODEL_EVENT_STORE_FETCHING_FINISHED object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self reloadDataItems];
}

- (PZDataListItemsType)listItemsType
{
    return -1;
}

#pragma mark Event when model data update

- (void)onModelNotification:(NSNotification *)notification
{
    if ([notification.name isEqual:NOTIFICATION_MODEL_EVENT_STORE_INITIALIZED])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onModelEventStoreFetchingFinishedNotification:) name:NOTIFICATION_MODEL_EVENT_STORE_FETCHING_FINISHED object:nil];
    }
}

#pragma mark TableView

- (void)onModelEventStoreFetchingFinishedNotification:(NSNotification *)notification
{
    if (self.listItemsType == PZDataListItemsTypeTags)
    {
        //event comes from fetch finish, so only reload table
        [self.tableView reloadData];
    }
    else
    {
        [self reloadDataItems];
    }
}

- (void)reloadDataItems
{
    [self.tableView reloadData];
    
    [self scrollSwipeViewCellsBackExcept:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}

- (NSDate *)nowDateWithDayOffset:(NSUInteger)dayOffset
{
    NSDateComponents *nowDateComponents = [self.calendar components:self.calendarUnits fromDate:[NSDate date]];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    components.year = nowDateComponents.year;
    components.month = nowDateComponents.month;
    components.day = nowDateComponents.day + dayOffset;
    components.hour = 0;
    components.minute = 0;
    
    return [self.calendar dateFromComponents:components];
}

- (NSString *)afterTomorrowDateText
{
    NSDate *afterTomorrowDate = [self nowDateWithDayOffset:2];
    
    return [[self.sectionDateFormatter stringFromDate:afterTomorrowDate] uppercaseString];
}

- (NSString *)titleForSection:(PZDataListItemsSectionType)sectionType
{
    switch(sectionType)
    {
        case PZDataListItemsSectionTypeToDo:
            return @"TODO";
        case PZDataListItemsSectionTypeDone:
            return @"DONE";
        case PZDataListItemsSectionTypePostponed:
            return @"POSTPONED";
        case PZDataListItemsSectionTypeTomorrow:
            return @"TOMORROW";
        case PZDataListItemsSectionTypeAfterTomorrow:
            return [self afterTomorrowDateText];
        case PZDataListItemsSectionTypeAfterTomorrowMore:
            return @"LATER";
        case PZDataListItemsSectionTypeAllTags:
            return @"ALL TAGS";
        case PZDataListItemsSectionTypeAllTagReminders:
            return @"ALL REMINDERS";
        default:
            return @"(UNTITLED)";
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    
    return [self.tableViewHeader headerForTableView:tableView withTitle:sectionTitle];
}

- (void)scrollSwipeViewCellsBackExcept:(PZTableViewCell *)cell
{
    for (PZTableViewCell *itemCell in self.tableView.visibleCells)
    {
        if (itemCell != cell)
        {
            [itemCell setScrollSwipeViewBack];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self scrollSwipeViewCellsBackExcept:nil];
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{

}

#pragma mark PZTableViewCellDelegate

- (void)onSwipeStartActionWithCell:(PZTableViewCell *)cell
{
    
}

- (void)onSwipeRightActionWithCell:(PZTableViewCell *)cell
{
    
}

- (void)onSwipeLeftLockWithCell:(PZTableViewCell *)cell
{
    
}

- (NSArray *)rightActionButtonsWithCell:(PZTableViewCell *)cell
{
    return @[];
}

#pragma mark PZTableViewCell buttons events

- (void)onTapCellRightActionButtonDelete:(id)sender
{
    
}

- (void)onTapCellRightActionButtonSetTime:(id)sender
{
    
}

#pragma mark Table item removal

- (NSArray *)removeItemFromArray:(NSArray *)array atIndex:(NSInteger)index
{
    NSMutableArray *list = [NSMutableArray arrayWithArray:array];
    
    [list removeObjectAtIndex:index];
    
    return [NSArray arrayWithArray:list];
}

- (void)restoreScrollOffset
{
    if (self.savedScrollOffsetPoint != nil)
    {
        CGPoint savedScrollOffset = self.savedScrollOffsetPoint.CGPointValue;
        
        [self.tableView setContentOffset:savedScrollOffset];
        
        self.savedScrollOffsetPoint = nil;
    }

    self.savedScrollOffsetPoint = [NSValue valueWithCGPoint:self.tableView.contentOffset];
}

- (void)resetScrollOffset
{
    self.savedScrollOffsetPoint = nil;
}

- (void)saveScrollOffset
{
    self.savedScrollOffsetPoint = [NSValue valueWithCGPoint:self.tableView.contentOffset];
}

- (void)removeItemAtIndexPath:(NSIndexPath *)indexPath withCompletion:(PZTableViewItemRemoveCompletion)completionBlock
{
    [self saveScrollOffset];
    
    [CATransaction begin];
    
    [CATransaction setCompletionBlock:^
    {
        completionBlock();
    }];
    
    [self.tableView beginUpdates];
    
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    [self.tableView endUpdates];
    
    [CATransaction commit];
}

- (void)insertItemAtIndexPath:(NSIndexPath *)indexPath withCompletion:(PZTableViewItemRemoveCompletion)completionBlock
{
    [CATransaction begin];
    
    [CATransaction setCompletionBlock:^
     {
         completionBlock();
     }];
    
    [self.tableView beginUpdates];
    
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    [self.tableView endUpdates];
    
    [CATransaction commit];
}

- (void)showAlarmSelectorForReminderCell:(PZReminderTableViewCell *)reminderCell
{
    __weak PZItemsTableViewController *selfWeakRef = self;

    UIViewController *viewController = self.navigationController;

    self.alarmSelector = [PZAlarmSelectorView instanceWithViewController:viewController];

    [self.alarmSelector showForReminderItem:reminderCell.dataItem withCompletion:^(NSDate *time, BOOL isCanceled)
    {
        selfWeakRef.alarmSelector = nil;

        if (isCanceled)
        {
            [reminderCell.dataItem rollback];

            [selfWeakRef scrollSwipeViewCellsBackExcept:nil];
            return;
        }

        reminderCell.dataItem.alarmDate = time;
        
        [reminderCell.dataItem saveItem];

        [selfWeakRef scrollSwipeViewCellsBackExcept:nil];

        [PZUtils delaySeconds:0.3 withCompletionBlock:^
        {
            [selfWeakRef.model.eventStore commit:nil];
        }];
    }];
}

#pragma mark Item Edit

- (void)showEditForReminderItem:(PZReminderItem *)reminderItem withTagItem:(PZTagItem *)tagItem
{
    PZReminderEditViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"vcEditReminder"];

    vc.listType = self.listItemsType;
    vc.parentTagItem = tagItem;
    
    if (reminderItem == nil)
    {
        NSLog(@"[PZItemsTableViewController] showEditForReminderItem for ADD");
        
        vc.itemEditMode = PZItemEditModeAdd;
            
        vc.item = [[PZReminderItem alloc] init];
    }
    else
    {
        NSLog(@"[PZItemsTableViewController] showEditForReminderItem for UPDATE:%@", reminderItem);

        vc.itemEditMode = PZItemEditModeUpdate;
        
        vc.item = reminderItem;
    }

    if (vc != nil)
    {
        vc.events = self;
        
        [self presentViewController:vc animated:YES completion:^
        {
        }];
    }
}

- (void)showEditForTagItem:(PZTagItem *)tagItem
{
    PZTagEditViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"vcEditTag"];
    
    vc.itemEditMode = PZItemEditModeAdd;

    if (tagItem == nil)
    {
        NSLog(@"[PZItemsTableViewController] showEditForTagItem for ADD item");
        
        vc.itemEditMode = PZItemEditModeAdd;
        
        vc.item = [[PZTagItem alloc] init];
    }
    else
    {
        NSLog(@"[PZItemsTableViewController] showReminderItemEdit for UPDATE item:%@", tagItem);
        
        vc.itemEditMode = PZItemEditModeUpdate;
        
        vc.item = tagItem;
    }
    
    if (vc != nil)
    {
        vc.events = self;
        
        [self presentViewController:vc animated:YES completion:^
        {
        }];
    }
}

#pragma mark Item Edit events

- (void)onLongPressWithCell:(PZTableViewCell *)cell
{
    NSLog(@"[PZItemsTableViewController] onLongPressWithCell: %@", cell);
    
}

- (void)onItemEditCancel
{
    NSLog(@"[PZItemsTableViewController] onItemEditCancel");
}

- (void)onItemEditAccept:(PZItem *)item
{
    NSLog(@"[PZItemsTableViewController] onItemEditAccept: %@", item.description);
    
}

@end
