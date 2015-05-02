//
//  PZRemindersTodayList.h
//  Reeminders
//
//  Created by Piotr on 17.08.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PZItemsList.h"
#import "PZReminderItem.h"

@interface PZRemindersTodayList : PZItemsList

@property NSArray *itemsTodo;
@property NSArray *itemsDone;

@property (readonly) int expiredAlarmsCount;
@property (readonly) NSString *expiredAlarmsCountText;

- (PZReminderItem *)itemWithUid:(NSString *)itemUid;

- (void)fetchRemindersToday:(PZItemsFetchCompletionBlock)completionBlock;

- (void)fetchRemindersTodayTodo:(PZItemsFetchCompletionBlock)completionBlock;

@end
