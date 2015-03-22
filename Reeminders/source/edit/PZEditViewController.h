//
//  PZEditViewController.h
//  Reeminders
//
//  Created by Piotr on 20.08.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PZEditViewControllerEvents.h"
#import "PZItemsTableViewController.h"

typedef NS_ENUM(NSInteger, PZItemEditMode)
{
    PZItemEditModeAdd,
    PZItemEditModeUpdate,
};

typedef void (^PZEditCancelCompletionBlock) ();
typedef void (^PZEditAcceptCompletionBlock) ();

typedef void (^PZEditFinishCompletionBlock) (NSString *error);

@class PZItem;
@class PZReminderItem;
@class PZTagItem;

@interface PZEditViewController : UIViewController

@property PZDataListItemsType listType;

@property PZItemEditMode itemEditMode;

@property (readonly) NSString *itemEditModeText;

@property PZItem *item;

@property (readonly) PZReminderItem *itemAsReminder;
@property (readonly) PZTagItem *itemAsTag;

@property (weak) id<PZEditViewControllerEvents> events;

- (void)updateUiStateFromData;
- (void)updateDataItemWithUiState;

- (NSInteger)indexOfTagItem:(PZTagItem *)tagItem withTagItems:(NSArray *)tagItems;

- (void)editCancelWithCompletion:(PZEditCancelCompletionBlock)completionBlock;
- (void)editAcceptWithCompletion:(PZEditAcceptCompletionBlock)completionBlock;

- (void)saveItemWithCompletion:(PZEditFinishCompletionBlock)completionBlock;

@end
