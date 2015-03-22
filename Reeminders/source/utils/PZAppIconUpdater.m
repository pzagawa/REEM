//
//  PZAppIconUpdater.m
//  REEM
//
//  Created by Piotr Zagawa on 09.11.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import "PZAppIconUpdater.h"
#import "PZModel.h"
#import "PZRemindersTodayList.h"

@implementation PZAppIconUpdater

+ (void)initPermissions
{
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)])
    {
        NSLog(@"[PZAppIconUpdater] handling for iOS8");
        
        UIUserNotificationType types = UIUserNotificationTypeBadge;
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    else
    {
        NSLog(@"[PZAppIconUpdater] handling for iOS7");
    }
}

+ (void)updateBadgeNumber
{
    [PZAppIconUpdater updateBadgeNumberWithCompletion:^
    {
    }];
}

+ (void)updateBadgeNumberWithCompletion:(PZAppIconUpdateCompletionBlock)completionBlock
{
    PZRemindersTodayList *remindersToday = [[PZRemindersTodayList alloc] initWithEventStore:[PZModel instance].eventStore];

    __weak PZRemindersTodayList *this = remindersToday;
    
    [remindersToday fetchRemindersTodayTodo:^
    {
        int expiredAlarmsCount = this.expiredAlarmsCount;
        
        [UIApplication sharedApplication].applicationIconBadgeNumber = expiredAlarmsCount;
        
        completionBlock();
    }];
}

@end
