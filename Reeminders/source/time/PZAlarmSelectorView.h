//
//  PZAlarmSelectorView.h
//  REEM
//
//  Created by Piotr Zagawa on 16.11.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PZReminderItem.h"

typedef void (^PZAlarmSelectorViewCompletionBlock)(NSDate *time, BOOL isCanceled);

@interface PZAlarmSelectorView : UIView

+ (PZAlarmSelectorView *)instanceWithViewController:(UIViewController *)viewController;

- (void)addToParentView:(UIView *)parentView;

+ (void)showForReminderItem:(PZReminderItem *)reminderItem withCompletion:(PZAlarmSelectorViewCompletionBlock)completionBlock;

@end
