//
//  PZDateTimeInterval.h
//  Reeminders
//
//  Created by Piotr on 06.09.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PZDateTimeInterval : NSObject

@property id value;

@property NSDate *date;
@property NSString *dateText;
@property NSNumber *timeInterval;

- (BOOL)isValueSet;

- (void)setNowTime;

@end
