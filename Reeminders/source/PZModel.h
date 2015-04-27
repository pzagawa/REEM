//
//  PZModel.h
//  Reeminders
//
//  Created by Piotr on 11.08.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PZItemsList.h"
#import "PZTagsList.h"
#import "PZRemindersTodayList.h"
#import "PZRemindersLaterList.h"
#import "PZRemindersList.h"

//Notifications
#define NOTIFICATION_MODEL_EVENT_STORE_INITIALIZED  @"NOTIFICATION_MODEL_EVENT_STORE_INITIALIZED"

#define NOTIFICATION_MODEL_EVENT_STORE_FETCHING_STARTED        @"NOTIFICATION_MODEL_EVENT_STORE_FETCHING_STARTED"
#define NOTIFICATION_MODEL_EVENT_STORE_FETCHING_FINISHED       @"NOTIFICATION_MODEL_EVENT_STORE_FETCHING_FINISHED"

//Operation completion blocks
typedef void (^PZEventStoreInitializeCompletionBlock) (BOOL granted, NSError *error);

//Model class
@interface PZModel : NSObject

@property (readonly) EKEventStore *eventStore;

@property (readonly) BOOL isEventStoreAccessAuthorized;

@property (readonly) PZTagsList *tagsAll;

@property (readonly) PZTagItem *defaultTagItem;

+ (void)createInstance;

+ (PZModel *)instance;

- (void)initializeEventStore:(PZEventStoreInitializeCompletionBlock)completionBlock;

- (EKCalendar *)createNewCalendarItem;
- (EKReminder *)createNewReminderItem;

- (void)fetchTags;

@end
