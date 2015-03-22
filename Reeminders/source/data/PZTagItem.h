//
//  PZTagItem.h
//  Reeminders
//
//  Created by Piotr on 15.08.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PZItem.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface PZTagItem : PZItem

@property EKCalendar *calendar;

@property NSString *name;

@property UIColor *color;

- (instancetype)initWithCalendar:(EKCalendar *)calendar;

@end
