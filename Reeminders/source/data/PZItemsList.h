//
//  PZItemsList.h
//  Reeminders
//
//  Created by Piotr on 17.08.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PZItem.h"

@import EventKit;

typedef void (^PZItemsFetchCompletionBlock) ();

@interface PZItemsList : NSObject

@property (weak, readonly) EKEventStore *eventStore;

@property (readonly) NSOperationQueue *operationQueue;

@property (readonly) BOOL isEventStoreAccessAuthorized;

@property (readonly) PZDataItemType itemType;

- (instancetype)initWithEventStore:(EKEventStore *)eventStore;

- (NSArray *)map:(NSMutableDictionary *)map reminderItemsFromEkReminders:(NSArray *)ekReminders;
- (NSArray *)map:(NSMutableDictionary *)map reminderItemsFromEkReminders:(NSArray *)ekReminders withCompletedState:(BOOL)isCompleted;

- (NSDate *)nowDateWithDayOffset:(NSUInteger)dayOffset;

- (NSArray *)sortCalendars:(NSArray *)ekCalendars;

@end
