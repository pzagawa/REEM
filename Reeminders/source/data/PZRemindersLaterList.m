//
//  PZRemindersLaterList.m
//  Reeminders
//
//  Created by Piotr on 17.08.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import "PZRemindersLaterList.h"
#import "PZTagsList.h"

@interface PZRemindersLaterList ()

@property (readonly) NSMutableDictionary *map;

@end

@implementation PZRemindersLaterList
{
    NSArray *_ekRemindersPostponed;
    NSArray *_ekRemindersTomorrow;
    NSArray *_ekRemindersAfterTomorrow;
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self->_map = [NSMutableDictionary new];
    }
    
    return self;
}

- (PZDataItemType)itemType
{
    return PZDataItemType_REMINDER;
}

- (PZReminderItem *)itemWithUid:(NSString *)itemUid
{
    @synchronized(self)
    {
        return [self.map objectForKey:itemUid];
    }
}

- (NSArray *)ekRemindersPostponed
{
    return self->_ekRemindersPostponed;
}

- (void)setEkRemindersPostponed:(NSArray *)ekRemindersPostponed
{
    self->_ekRemindersPostponed = ekRemindersPostponed;
    
    @synchronized(self)
    {
        self.itemsPostponed = [self map:self.map reminderItemsFromEkReminders:ekRemindersPostponed];
    }
    
    NSLog(@"[PZRemindersLaterList] ekRemindersPostponed set (%li)", (long)self.itemsPostponed.count);
}

- (NSArray *)ekRemindersTomorrow
{
    return self->_ekRemindersTomorrow;
}

- (void)setEkRemindersTomorrow:(NSArray *)ekRemindersTomorrow
{
    self->_ekRemindersTomorrow = ekRemindersTomorrow;
    
    @synchronized(self)
    {
        self.itemsTomorrow = [self map:self.map reminderItemsFromEkReminders:ekRemindersTomorrow];
    }
    
    NSLog(@"[PZRemindersLaterList] ekRemindersTomorrow set (%li)", (long)self.itemsTomorrow.count);
}

- (NSArray *)ekRemindersAfterTomorrow
{
    return self->_ekRemindersAfterTomorrow;
}

- (void)setEkRemindersAfterTomorrow:(NSArray *)ekRemindersAfterTomorrow
{
    self->_ekRemindersAfterTomorrow = ekRemindersAfterTomorrow;
    
    @synchronized(self)
    {
        self.itemsAfterTomorrow = [self map:self.map reminderItemsFromEkReminders:ekRemindersAfterTomorrow];
    }
    
    NSLog(@"[PZRemindersLaterList] ekRemindersAfterTomorrow set (%li)", (long)self.itemsAfterTomorrow.count);
}

- (void)fetchRemindersLater:(PZItemsFetchCompletionBlock)completionBlock
{
    NSDate *firstDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
    
    NSDate *todayDate = [self nowDateWithDayOffset:0];
    NSDate *tomorrowDate = [self nowDateWithDayOffset:1];
    NSDate *afterTomorrowDate = [self nowDateWithDayOffset:2];
    NSDate *afterTomorrowPlusOneDate = [self nowDateWithDayOffset:3];

    NSPredicate *predicatePostponed = [self.eventStore predicateForIncompleteRemindersWithDueDateStarting:firstDate ending:todayDate calendars:nil];
    NSPredicate *predicateTomorrow = [self.eventStore predicateForIncompleteRemindersWithDueDateStarting:tomorrowDate ending:afterTomorrowDate calendars:nil];
    NSPredicate *predicateAfterTomorrow = [self.eventStore predicateForIncompleteRemindersWithDueDateStarting:afterTomorrowDate ending:afterTomorrowPlusOneDate calendars:nil];

    [self.eventStore fetchRemindersMatchingPredicate:predicatePostponed completion:^(NSArray *reminders)
    {
        self.ekRemindersPostponed = reminders;

        [self.eventStore fetchRemindersMatchingPredicate:predicateTomorrow completion:^(NSArray *reminders)
        {
            self.ekRemindersTomorrow = reminders;

            [self.eventStore fetchRemindersMatchingPredicate:predicateAfterTomorrow completion:^(NSArray *reminders)
            {
                self.ekRemindersAfterTomorrow = reminders;

                dispatch_async(dispatch_get_main_queue (), ^(void)
                {
                    completionBlock();
                });
            }];
        }];
    }];
}

- (NSString *)postponedItemsCountText
{
    int count = (int)self.itemsPostponed.count;
    
    if (count == 0)
    {
        return nil;
    }
    
    return [NSString stringWithFormat:@"%i", count];
}

@end
