//
//  PZReminderItem.h
//  Reeminders
//
//  Created by Piotr on 02.08.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PZItem.h"

typedef NS_ENUM(NSInteger, PZReminderItemPriority)
{
    PZReminderItemPriority_NONE,
    PZReminderItemPriority_LOW,
    PZReminderItemPriority_MEDIUM,
    PZReminderItemPriority_HIGH,
};

@class PZTagItem;

@interface PZReminderItem : PZItem

@property EKReminder *reminder;

@property NSString *title;

@property PZReminderItemPriority priorityType;

@property PZTagItem *refTagItem;

@property (readonly) NSString *tagName;

@property NSDate *alarmDate;

@property (readonly) EKStructuredLocation *alarmLocation;

@property (readonly) NSString *alarmTimeText;
@property (readonly) NSString *alarmDateText;

@property BOOL isShowDateEnabled;

@property BOOL isCompleted;

@property (readonly) NSDate *completionDate;

@property (readonly) NSDate *lastModifiedDate;

@property (readonly) BOOL isAlarmExpired;

@property NSString *notes;

@property (readonly) BOOL hasNotes;

- (instancetype)initWithReminder:(EKReminder *)reminder;

@end
