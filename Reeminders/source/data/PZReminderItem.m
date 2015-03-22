//
//  PZReminderItem.m
//  Reeminders
//
//  Created by Piotr on 02.08.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import "PZReminderItem.h"
#import "PZTagItem.h"
#import "PZModel.h"
#import "PZTagsList.h"

static NSDateFormatter *alarmTimeFormatter24 = nil;
static NSDateFormatter *alarmTimeFormatter12 = nil;
static NSDateFormatter *alarmDateFormatter = nil;

@interface PZReminderItem ()

@property (readonly) NSTimeZone *timeZone;
@property (readonly) EKAlarm *alarm;

@end

@implementation PZReminderItem
{
    NSString *_cachedTitle;
    NSNumber *_cachedPriority;
    __weak PZTagItem *_refTagItem;
    NSDate *_cachedAlarmDate;
    NSNumber *_cachedIsCompleted;
    NSNumber *_cachedHasNotes;
}

+ (void)initialize
{
    if (self == [PZReminderItem class])
    {
        alarmTimeFormatter24 = [NSDateFormatter new];
        alarmTimeFormatter12 = [NSDateFormatter new];
        alarmDateFormatter = [NSDateFormatter new];
        
        [alarmTimeFormatter24 setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
        [alarmTimeFormatter12 setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
        [alarmDateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
        
        [alarmTimeFormatter24 setDateFormat:@"H:mm"];
        [alarmTimeFormatter12 setDateFormat:@"h:mma"];
        [alarmDateFormatter setDateFormat:@"dd.MM.yyyy"];
    }
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.reminder = [[PZModel instance] createNewReminderItem];
    }
    
    return self;
}

- (instancetype)initWithReminder:(EKReminder *)reminder
{
    self = [super init];
    
    if (self)
    {
        self.reminder = reminder;
        
        self.itemUid = [reminder.calendarItemIdentifier copy];

        //precache values
        self->_cachedTitle = self.title;
        self->_cachedPriority = @(self.priorityType);
        self->_refTagItem = self.refTagItem;
        self->_cachedAlarmDate = self.alarmDate;
        self->_cachedIsCompleted = @(self.isCompleted);
        self->_cachedHasNotes = @(self.hasNotes);
    }
    
    return self;
}

- (void)dealloc
{
    self.reminder = nil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@. %@.", super.description, self.title];
}

#pragma mark Properties

- (PZDataItemType)itemType
{
    return PZDataItemType_REMINDER;
}

- (NSString *)validationError
{
    NSString *error = [super validationError];
    
    if (error != nil)
    {
        return error;
    }
    
    if ([self isStringEmpty:self.title])
    {
        return @"title is empty";
    }
    
    return nil;
}

- (NSString *)title
{
    if (self->_cachedTitle == nil)
    {
        self->_cachedTitle = [PZUtils trimStringForTitleLine:self.reminder.title];
    }
    
    return self->_cachedTitle;
}

- (void)setTitle:(NSString *)title
{
    self.reminder.title = [PZUtils trimStringForTitleLine:title];

    self->_cachedTitle = nil;
}

- (PZReminderItemPriority)priorityTypeFromPriorityValue:(NSInteger)value
{
    if (self.reminder.priority == 0)
    {
        return PZReminderItemPriority_NONE;
    }
    
    if (self.reminder.priority >= 6 && self.reminder.priority <= 9)
    {
        return PZReminderItemPriority_LOW;
    }
    
    if (self.reminder.priority == 5)
    {
        return PZReminderItemPriority_MEDIUM;
    }
    
    if (self.reminder.priority >= 1 && self.reminder.priority <= 4)
    {
        return PZReminderItemPriority_HIGH;
    }
    
    return PZReminderItemPriority_NONE;
}

- (PZReminderItemPriority)priorityType
{
    if (self->_cachedPriority == nil)
    {
        self->_cachedPriority = @([self priorityTypeFromPriorityValue:self.reminder.priority]);
    }
    
    return self->_cachedPriority.integerValue;
}

- (void)setPriorityType:(PZReminderItemPriority)priorityType
{
    self->_cachedPriority = nil;
    
    if (priorityType == PZReminderItemPriority_LOW)
    {
        self.reminder.priority = 9;
        return;
    }

    if (priorityType == PZReminderItemPriority_MEDIUM)
    {
        self.reminder.priority = 5;
        return;
    }

    if (priorityType == PZReminderItemPriority_HIGH)
    {
        self.reminder.priority = 1;
        return;
    }
    
    self.reminder.priority = 0;
}

- (PZTagItem *)refTagItem
{
    if (self->_refTagItem == nil)
    {
        EKCalendar *calendar = self.reminder.calendar;
        
        NSString *refTagItemUid = calendar.calendarIdentifier;
        
        self->_refTagItem = [[PZModel instance].tagsAll itemWithUid:refTagItemUid];
    }

    return self->_refTagItem;
}

- (void)setRefTagItem:(PZTagItem *)refTagItem
{
    self.reminder.calendar = refTagItem.calendar;
    
    self->_refTagItem = nil;
}

- (NSString *)tagName
{
    if (self.refTagItem == nil)
    {
        return @"";
    }
    
    return [self.refTagItem.name uppercaseString];
}

- (NSString *)alarmTimeText
{
    if (self.alarmDate != nil)
    {
        if ([PZUtils is24HourClockFormat])
        {
            return [alarmTimeFormatter24 stringFromDate:self.alarmDate];
        }
        else
        {
            return [alarmTimeFormatter12 stringFromDate:self.alarmDate];
        }
    }

    if (self.alarmLocation != nil)
    {
        return @"LOC";
    }
    
    return @"";
}

- (NSString *)alarmDateText
{
    if (self.alarmDate != nil)
    {
        return [alarmDateFormatter stringFromDate:self.alarmDate];
    }

    return @"";
}

- (NSTimeZone *)timeZone
{
    return self.reminder.timeZone;
}

- (EKAlarm *)alarm
{
    NSArray *alarms = self.reminder.alarms;
    
    if (alarms != nil && alarms.count > 0)
    {
        return alarms[0];
    }

    return nil;
}

- (NSDate *)alarmDate
{
    if (self->_cachedAlarmDate == nil)
    {
        EKAlarm *alarm = self.alarm;
        
        if (alarm != nil && alarm.absoluteDate != nil)
        {
            self->_cachedAlarmDate = alarm.absoluteDate;
        }
    }

    return self->_cachedAlarmDate;
}

- (void)setAlarmDate:(NSDate *)alarmDate
{
    if (alarmDate == nil)
    {
        //new date is nil, reset alarm
        if (self.alarm != nil)
        {
            [self.reminder removeAlarm:self.alarm];
        }

        self.reminder.dueDateComponents = nil;
    }
    else
    {
        //new date is not nil
        if (self.reminder.alarms == nil || self.reminder.alarms.count == 0)
        {
            [self.reminder addAlarm:[EKAlarm alarmWithAbsoluteDate:alarmDate]];
        }
        else
        {
            EKAlarm *alarm = self.reminder.alarms[0];
            
            alarm.absoluteDate = alarmDate;
        }
        
        //set due date to the same alarm date for proper filtering
        NSCalendarUnit units = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute);
        
        self.reminder.dueDateComponents = [[NSCalendar currentCalendar] components:units fromDate:alarmDate];
    }
    
    self->_cachedAlarmDate = nil;
}

- (EKStructuredLocation *)alarmLocation
{
    EKAlarm *alarm = self.alarm;
    
    if (alarm != nil && alarm.structuredLocation != nil)
    {
        return alarm.structuredLocation;
    }

    return nil;
}

- (BOOL)isCompleted
{
    if (self->_cachedIsCompleted == nil)
    {
        self->_cachedIsCompleted = @(self.reminder.isCompleted);
    }
    
    return self->_cachedIsCompleted.boolValue;
}

- (void)setIsCompleted:(BOOL)isCompleted
{
    self.reminder.completed = isCompleted;

    self->_cachedIsCompleted = nil;

    NSError *error = nil;
    
    if ([[PZModel instance].eventStore saveReminder:self.reminder commit:NO error:&error] == NO)
    {
        NSLog(@"[PZReminderItem] setIsCompleted error: %@", error);
    }
}

- (NSDate *)completionDate
{
    return self.reminder.completionDate;
}

- (NSDate *)lastModifiedDate
{
    return self.reminder.lastModifiedDate;
}

- (BOOL)isAlarmExpired
{
    NSComparisonResult compare = [[NSDate date] compare:self.alarmDate];
    
    if (compare == NSOrderedSame || compare == NSOrderedAscending)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (NSString *)notes
{
    if ([self.reminder hasNotes])
    {
        return self.reminder.notes;
    }
    
    return @"";
}

- (void)setNotes:(NSString *)notes
{
    self.reminder.notes = notes;

    self->_cachedHasNotes = nil;
}

- (BOOL)hasNotes
{
    if (self->_cachedHasNotes == nil)
    {
        self->_cachedHasNotes = @(self.reminder.hasNotes);
    }

    return self->_cachedHasNotes.boolValue;
}

- (void)rollback
{
    [self.reminder rollback];
}

- (void)deleteItem
{
    NSError *error = nil;
    
    if ([[PZModel instance].eventStore removeReminder:self.reminder commit:NO error:&error] == NO)
    {
        NSLog(@"[PZReminderItem] deleteReminder error: %@", error);
    }
}

- (void)saveItem
{
    NSError *error = nil;
    
    if ([[PZModel instance].eventStore saveReminder:self.reminder commit:NO error:&error] == NO)
    {
        NSLog(@"[PZReminderItem] deleteReminder error: %@", error);
    }
}


@end
