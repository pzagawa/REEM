//
//  PZReminderEditViewController.h
//  Reeminders
//
//  Created by Piotr on 14.08.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PZEditViewController.h"

@interface PZReminderEditViewController : PZEditViewController<UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak) PZTagItem *parentTagItem;

@end
