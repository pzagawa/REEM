//
//  PZRemindersList.m
//  Reeminders
//
//  Created by Piotr on 17.08.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import "PZRemindersList.h"
#import "PZTagsList.h"

@interface PZRemindersList ()

@property (readonly) NSMutableDictionary *map;

@end

@implementation PZRemindersList
{
    NSArray *_ekReminders;
}

- (instancetype)initWithEventStore:(EKEventStore *)eventStore
{
    self = [super initWithEventStore:eventStore];
    
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

- (NSArray *)ekReminders
{
    return self->_ekReminders;
}

- (void)setEkReminders:(NSArray *)ekReminders
{
    self->_ekReminders = ekReminders;
    
    @synchronized(self)
    {
        self.itemsTodo = [self map:self.map reminderItemsFromEkReminders:ekReminders withCompletedState:NO];
        self.itemsDone = [self map:self.map reminderItemsFromEkReminders:ekReminders withCompletedState:YES];
    }
    
    NSLog(@"[PZRemindersList] ekReminders set (%li)", (long)self.ekReminders.count);
}

- (void)fetchRemindersForCalendar:(EKCalendar *)calendar withCompletion:(PZItemsFetchCompletionBlock)completionBlock
{
    NSPredicate *predicate = [self.eventStore predicateForRemindersInCalendars:@[ calendar ]];

    [self.eventStore fetchRemindersMatchingPredicate:predicate completion:^(NSArray *reminders)
    {
        self.ekReminders = reminders;
        
        dispatch_async(dispatch_get_main_queue (), ^(void)
        {
            completionBlock();
        });
    }];
}

@end
