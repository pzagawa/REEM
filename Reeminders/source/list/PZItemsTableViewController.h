//
//  PZItemsTableViewController.h
//  Reeminders
//
//  Created by Piotr on 02.08.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PZModel.h"
#import "PZTableViewCell.h"
#import "PZEditViewControllerEvents.h"

//List items type
typedef NS_ENUM(NSInteger, PZDataListItemsType)
{
    PZDataListItemsTypeRemindersToday,
    PZDataListItemsTypeRemindersLater,
    PZDataListItemsTypeReminders,
    PZDataListItemsTypeTags,
};

//List items section type
typedef NS_ENUM(NSInteger, PZDataListItemsSectionType)
{
    PZDataListItemsSectionTypeToDo,
    PZDataListItemsSectionTypeDone,
    PZDataListItemsSectionTypePostponed,
    PZDataListItemsSectionTypeTomorrow,
    PZDataListItemsSectionTypeAfterTomorrow,
    PZDataListItemsSectionTypeAfterTomorrowMore,
    PZDataListItemsSectionTypeAllTags,
    PZDataListItemsSectionTypeAllTagReminders,
};

typedef void (^PZTableViewItemRemoveCompletion) ();

@class PZItemsTableViewHeader;
@class PZReminderTableViewCell;

@interface PZItemsTableViewController : UITableViewController<PZTableViewCellDelegate, PZEditViewControllerEvents>

@property (weak, readonly) PZModel *model;

@property (readonly) PZDataListItemsType listItemsType;

@property (readonly) PZItemsTableViewHeader *tableViewHeader;

@property (readonly) UIButton *cellRightActionButtonDelete;
@property (readonly) UIButton *cellRightActionButtonSetTime;

@property (weak) PZTableViewCell *swipedCell;

- (void)reloadDataItems;

- (NSString *)titleForSection:(PZDataListItemsSectionType)sectionType;

- (void)scrollSwipeViewCellsBackExcept:(PZTableViewCell *)cell;

- (NSArray *)removeItemFromArray:(NSArray *)array atIndex:(NSInteger)index;

- (void)removeItemAtIndexPath:(NSIndexPath *)indexPath withCompletion:(PZTableViewItemRemoveCompletion)completionBlock;
- (void)insertItemAtIndexPath:(NSIndexPath *)indexPath withCompletion:(PZTableViewItemRemoveCompletion)completionBlock;

- (void)showAlarmSelectorForReminderCell:(PZReminderTableViewCell *)reminderCell;

- (void)showEditForReminderItem:(PZReminderItem *)reminderItem withTagItem:(PZTagItem *)tagItem;
- (void)showEditForTagItem:(PZTagItem *)tagItem;

- (void)restoreScrollOffset;
- (void)resetScrollOffset;

@end
