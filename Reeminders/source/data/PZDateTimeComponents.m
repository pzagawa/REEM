//
//  PZDateTimeComponents.m
//  Reeminders
//
//  Created by Piotr on 06.09.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import "PZDateTimeComponents.h"

static NSDateFormatter *_typeFormatter;
static NSCalendar *_calendar;

@interface PZDateTimeComponents ()

@property (readonly) NSDateFormatter *formatter;
@property (readonly) NSCalendar *calendar;

@end

@implementation PZDateTimeComponents

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
    if (self.dateText == nil)
    {
        return [NSNull null];
    }

    return self.dateText;
}

- (void)setValue:(id)value
{
    if (value == nil || value == [NSNull null])
    {
        self.dateText = nil;
    }
    else
    {
        self.dateText = value;
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

- (NSDateComponents *)dateComponentsFromDate:(NSDate *)date
{
    unsigned flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;

    return [self.calendar components:flags fromDate:date];
}

- (NSDate *)dateFromDateComponents:(NSDateComponents *)dateComponents
{
    return [self.calendar dateFromComponents:dateComponents];
}

#pragma mark Properties

- (BOOL)isValueSet
{
    return (self.dateText != nil);
}

- (NSDate *)date
{
    return [self dateFromString:self.dateText];
}

- (void)setDate:(NSDate *)date
{
    self.dateText = [self stringFromDate:date];
}

- (NSDateComponents *)dateComponents
{
    return [self dateComponentsFromDate:self.date];
}

- (void)setDateComponents:(NSDateComponents *)dateComponents
{
    self.date = [self dateFromDateComponents:dateComponents];
}

@end
