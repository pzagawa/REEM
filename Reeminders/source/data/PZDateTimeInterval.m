//
//  PZDateTimeInterval.m
//  Reeminders
//
//  Created by Piotr on 06.09.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import "PZDateTimeInterval.h"

static NSDateFormatter *_typeFormatter;
static NSCalendar *_calendar;

@interface PZDateTimeInterval ()

@property (readonly) NSDateFormatter *formatter;
@property (readonly) NSCalendar *calendar;

@end

@implementation PZDateTimeInterval

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        if (_typeFormatter == nil)
        {
            _typeFormatter = [NSDateFormatter new];

            [_typeFormatter setDateFormat:@"yyyy.MM.dd HH:mm:ss"];
        }

        if (_calendar == nil)
        {
            _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        }
    }
    
    return self;
}

- (NSDateFormatter *)formatter
{
    return _typeFormatter;
}

- (NSCalendar *)calendar
{
    return _calendar;
}

#pragma mark Dictionary utils methods

- (id)value
{
    if (self.timeInterval == nil)
    {
        return [NSNull null];
    }

    return self.timeInterval;
}

- (void)setValue:(id)value
{
    if (value == nil || value == [NSNull null])
    {
        self.timeInterval = nil;
    }
    else
    {
        self.timeInterval = value;
    }
}

#pragma mark Utils methods

- (NSDate *)dateFromString:(NSString *)text
{
    if (text == nil)
    {
        return nil;
    }

    return [self.formatter dateFromString:text];
}

- (NSString *)stringFromDate:(NSDate *)date
{
    if (date == nil)
    {
        return nil;
    }

    return [self.formatter stringFromDate:date];
}

- (NSDate *)dateFromTimeInterval:(NSNumber *)timeInterval
{
    if (timeInterval == nil)
    {
        return nil;
    }

    return [NSDate dateWithTimeIntervalSinceReferenceDate:[timeInterval doubleValue]];
}

- (NSNumber *)timeIntervalFromDate:(NSDate *)date
{
    if (date == nil)
    {
        return nil;
    }

    return [NSNumber numberWithDouble:[date timeIntervalSinceReferenceDate]];
}

#pragma mark Properties

- (BOOL)isValueSet
{
    return (self.timeInterval != nil);
}

- (NSDate *)date
{
    return [self dateFromTimeInterval:self.timeInterval];
}

- (void)setDate:(NSDate *)date
{
    self.timeInterval = [self timeIntervalFromDate:date];
}

- (NSString *)dateText
{
    return [self stringFromDate:self.date];
}

- (void)setDateText:(NSString *)dateText
{
    self.date = [self dateFromString:dateText];
}

#pragma mark Methods

- (void)setNowTime
{
    self.timeInterval = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSinceReferenceDate]];
}

@end
