//
//  PZItem.h
//  Reeminders
//
//  Created by Piotr on 03.08.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PZUtils.h"

@import EventKit;

#define MAX_ITEM_TITLE_LENGTH   80
#define MAX_ITEM_NAME_LENGTH    80
#define MAX_ITEM_NOTES_LENGTH   4000

typedef NS_ENUM(NSInteger, PZDataItemType)
{
    PZDataItemType_NONE,
    PZDataItemType_REMINDER,
    PZDataItemType_TAG,
};

@interface PZItem : NSObject

@property NSString *itemUid;

@property (readonly) PZDataItemType itemType;

@property (readonly) NSString *itemTypeText;

@property (readonly) NSString *validationError;

- (BOOL)isStringEmpty:(NSString *)text;

- (void)commit;

- (void)rollback;

- (void)deleteItem;
- (void)saveItem;

@end
