//
//  PZRemindersTodayList.m
//  Reeminders
//
//  Created by Piotr on 17.08.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import "PZRemindersTodayList.h"
#import "PZTagsList.h"

@interface PZRemindersTodayList ()

@property (readonly) NSMutableDictionary *map;

@end

@implementation PZRemindersTodayList
{
    NSArray *_ekRemindersToDo;
    NSArray *_ekRemindersDone;
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

- (NSArray *)ekRemindersToDo
{
    return self->_ekRemindersToDo;
}

- (void)setEkRemindersToDo:(NSArray *)ekRemindersToDo
{
    self->_ekRemindersToDo = ekRemindersToDo;
    
    @synchronized(self)
    {
        self.itemsTodo = [self map:self.map reminderItemsFromEkReminders:ekRemindersToDo];
    }
    
    NSLog(@"[PZRemindersTodayList] ekRemindersToDo set (%li)", (long)self.itemsTodo.count);
}

- (NSArray *)ekRemindersDone
{
    return self->_ekRemindersDone;
}

- (void)setEkRemindersDone:(NSArray *)ekRemindersDone
{
    self->_ekRemindersDone = ekRemindersDone;
    
    @synchronized(self)
    {
        self.itemsDone = [self map:self.map reminderItemsFromEkReminders:ekRemindersDone withCompletedState:YES];
    }
    
    NSLog(@"[PZRemindersTodayList] ekRemindersDone set (%li)", (long)self.itemsDone.count);
}

- (void)fetchRemindersToday:(PZItemsFetchCompletionBlock)completionBlock
{
    NSDate *todayDate = [self nowDateWithDayOffset:0];
    NSDate *tomorrowDate = [self nowDateWithDayOffset:1];
    
    NSPredicate *predicateToDo = [self.eventStore predicateForIncompleteRemindersWithDueDateStarting:todayDate ending:tomorrowDate calendars:nil];
    NSPredicate *predicateDone = [self.eventStore predicateForCompletedRemindersWithCompletionDateStarting:todayDate ending:tomorrowDate calendars:nil];
    
    [self.eventStore fetchRemindersMatchingPredicate:predicateToDo completion:^(NSArray *reminders)
    {
        self.ekRemindersToDo = reminders;

        [self.eventStore fetchRemindersMatchingPredicate:predicateDone completion:^(NSArray *reminders)
        {
            self.ekRemindersDone = reminders;

            dispatch_async(dispatch_get_main_queue (), ^(void)
            {
                completionBlock();
            });
        }];
    }];
}

- (void)fetchRemindersTodayTodo:(PZItemsFetchCompletionBlock)completionBlock
{
    NSDate *todayDate = [self nowDateWithDayOffset:0];
    NSDate *tomorrowDate = [self nowDateWithDayOffset:1];
    
    NSPredicate *predicateToDo = [self.eventStore predicateForIncompleteRemindersWithDueDateStarting:todayDate ending:tomorrowDate calendars:nil];
    
    [self.eventStore fetchRemindersMatchingPredicate:predicateToDo completion:^(NSArray *reminders)
    {
        self.ekRemindersToDo = reminders;

        completionBlock();
    }];
}

 - (int)expiredAlarmsCount
{
    @synchronized(self)
    {
        int count = 0;
        
        for (PZReminderItem *item in self.itemsTodo)
        {
            if (item.isAlarmExpired && item.isCompleted == NO)
            {
                count++;
            }
        }
        
        return count;
    }
}

- (NSString *)expiredAlarmsCountText
{
    int count = self.expiredAlarmsCount;
    
    if (count == 0)
    {
        return nil;
    }
    
    return [NSString stringWithFormat:@"%i", count];
}

@end
