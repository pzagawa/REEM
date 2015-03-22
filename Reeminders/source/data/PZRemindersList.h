//
//  PZRemindersList.h
//  Reeminders
//
//  Created by Piotr on 17.08.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PZItemsList.h"
#import "PZReminderItem.h"

@interface PZRemindersList : PZItemsList

@property NSArray *ekReminders;

@property NSArray *itemsTodo;
@property NSArray *itemsDone;

- (PZReminderItem *)itemWithUid:(NSString *)itemUid;

- (void)fetchRemindersForCalendar:(EKCalendar *)calendar withCompletion:(PZItemsFetchCompletionBlock)completionBlock;

@end
