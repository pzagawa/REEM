//
//  PZItem.m
//  Reeminders
//
//  Created by Piotr on 03.08.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import "PZItem.h"
#import "PZUtils.h"
#import "PZModel.h"
#import "PZReminderItem.h"
#import "PZTagItem.h"

@implementation PZItem

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
    }
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@: %@", self.itemTypeText, self.itemUid];
}

#pragma mark Properties

- (PZDataItemType)itemType
{
    return PZDataItemType_NONE;
}

- (NSString *)itemTypeText
{
    return [PZItem textFromItemType:self.itemType];
}

- (NSString *)validationError
{
    return nil;
}

- (BOOL)isStringEmpty:(NSString *)text
{
    return [PZUtils isStringEmpty:text];
}

+ (PZItem *)createItemWithType:(PZDataItemType)itemType
{
    PZItem *item = nil;

    if (itemType == PZDataItemType_REMINDER)
    {
        item = [[PZReminderItem alloc] init];
    }

    if (itemType == PZDataItemType_TAG)
    {
        item = [[PZTagItem alloc] init];
    }

    return item;
}

+ (NSString *)textFromItemType:(PZDataItemType)itemType
{
    if (itemType == PZDataItemType_REMINDER)
    {
        return @"REMINDER";
    }

    if (itemType == PZDataItemType_TAG)
    {
        return @"TAG";
    }

    return @"NONE";
}

- (void)commit
{
    NSError *error = nil;

    if ([[PZModel instance].eventStore commit:&error] == NO)
    {
        NSLog(@"[PZItem] commit error: %@", error);
    }
}

- (void)rollback
{
}

- (void)deleteItem
{
    
}

- (void)saveItem
{
}

@end
