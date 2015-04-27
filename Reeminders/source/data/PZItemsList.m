//
//  PZItemsList.m
//  Reeminders
//
//  Created by Piotr on 17.08.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import "PZModel.h"
#import "PZItemsList.h"
#import "PZTagItem.h"
#import "PZReminderItem.h"

@interface PZItemsList ()

@property (readonly) NSCalendar *calendar;
@property (readonly) NSCalendarUnit calendarUnits;

@end

static NSOperationQueue *commonOperationQueue;

@implementation PZItemsList

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self->_calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

        self->_calendarUnits = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute);
    }

    return self;
}

- (NSOperationQueue *)operationQueue
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        commonOperationQueue = [NSOperationQueue new];

        commonOperationQueue.maxConcurrentOperationCount = 1;
    });

    return commonOperationQueue;
}

- (EKEventStore *)eventStore
{
    return [[PZModel instance] eventStore];
}

- (BOOL)isEventStoreAccessAuthorized
{
    EKAuthorizationStatus authStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    
    return (authStatus == EKAuthorizationStatusAuthorized);
}

- (PZDataItemType)itemType
{
    return PZDataItemType_NONE;
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

- (NSArray *)map:(NSMutableDictionary *)map reminderItemsFromEkReminders:(NSArray *)ekReminders
{
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:ekReminders.count];
    
    for (EKReminder *reminder in ekReminders)
    {
        PZReminderItem *item = [[PZReminderItem alloc] initWithReminder:reminder];
                
        [items addObject:item];
        
        [map setObject:item forKey:item.itemUid];
    }
    
    [self sortByTimeAsc:items];
    
    return [NSArray arrayWithArray:items];
}

- (NSArray *)map:(NSMutableDictionary *)map reminderItemsFromEkReminders:(NSArray *)ekReminders withCompletedState:(BOOL)isCompleted
{
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    for (EKReminder *reminder in ekReminders)
    {
        if (reminder.isCompleted == isCompleted)
        {
            PZReminderItem *item = [[PZReminderItem alloc] initWithReminder:reminder];
            
            [items addObject:item];
            
            [map setObject:item forKey:item.itemUid];
        }
    }
    
    [self sortByTimeAsc:items withCompletedState:isCompleted];
    
    return [NSArray arrayWithArray:items];
}

- (void)sortByTimeAsc:(NSMutableArray *)items
{
    [items sortUsingComparator:^NSComparisonResult(PZReminderItem *obj1, PZReminderItem *obj2)
    {
        NSDate *date1 = obj1.alarmDate;
        NSDate *date2 = obj2.alarmDate;
        
        return [date1 compare:date2];
    }];
}

- (void)sortByTimeAsc:(NSMutableArray *)items withCompletedState:(BOOL)isCompleted
{
    [items sortUsingComparator:^NSComparisonResult(PZReminderItem *obj1, PZReminderItem *obj2)
    {
        NSDate *date1 = obj1.alarmDate;
        NSDate *date2 = obj2.alarmDate;

        //items with alarm put first
        if (date1 != nil && date2 != nil)
        {
            return [date1 compare:date2];
        }
        
        //items without alarm sort by last modified first
        if (date1 == nil)
        {
            date1 = obj1.lastModifiedDate;
        }
        
        if (date2 == nil)
        {
            date2 = obj2.lastModifiedDate;
        }

        return [date2 compare:date1];
    }];
}

- (NSArray *)sortCalendars:(NSArray *)ekCalendars
{
    NSMutableArray *list = [[NSMutableArray alloc] initWithArray:ekCalendars];
    
    [list sortUsingComparator:^NSComparisonResult(EKCalendar *obj1, EKCalendar *obj2)
    {
        NSString *title1 = obj1.title;
        NSString *title2 = obj2.title;

        return [title1 caseInsensitiveCompare:title2];
    }];
    
    return [NSArray arrayWithArray:list];
}

@end
