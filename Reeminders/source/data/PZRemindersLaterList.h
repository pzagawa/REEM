//
//  PZRemindersLaterList.h
//  Reeminders
//
//  Created by Piotr on 17.08.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PZItemsList.h"
#import "PZReminderItem.h"

@interface PZRemindersLaterList : PZItemsList

@property NSArray *ekRemindersPostponed;
@property NSArray *ekRemindersTomorrow;
@property NSArray *ekRemindersAfterTomorrow;

@property NSArray *itemsPostponed;
@property NSArray *itemsTomorrow;
@property NSArray *itemsAfterTomorrow;

@property (readonly) NSString *postponedItemsCountText;

- (PZReminderItem *)itemWithUid:(NSString *)itemUid;

- (void)fetchRemindersLater:(PZItemsFetchCompletionBlock)completionBlock;

@end
