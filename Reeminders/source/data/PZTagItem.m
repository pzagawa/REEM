//
//  PZTagItem.m
//  Reeminders
//
//  Created by Piotr on 15.08.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import "PZTagItem.h"
#import "PZModel.h"

@interface PZTagItem ()

@end

@implementation PZTagItem

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.calendar = [[PZModel instance] createNewCalendarItem];
    }
    
    return self;
}

- (instancetype)initWithCalendar:(EKCalendar *)calendar
{
    self = [super init];
    
    if (self)
    {
        self.calendar = calendar;

        self.itemUid = [calendar.calendarIdentifier copy];
    }
    
    return self;
}

- (void)dealloc
{
    self.calendar = nil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@. %@.", super.description, self.name];
}

#pragma mark Properties

- (PZDataItemType)itemType
{
    return PZDataItemType_TAG;
}

- (NSString *)validationError
{
    NSString *error = [super validationError];
    
    if (error != nil)
    {
        return error;
    }
    
    if ([self isStringEmpty:self.name])
    {
        return @"name is empty";
    }
    
    return nil;
}

- (NSString *)name
{
    return [PZUtils trimStringForTitleLine:self.calendar.title];
}

- (void)setName:(NSString *)name
{
    NSString *text = [PZUtils trimStringForTitleLine:name];

    self.calendar.title = text;
}

- (UIColor *)color
{
    CGColorRef color = self.calendar.CGColor;
    
    return (color == nil) ? [UIColor lightGrayColor] : [UIColor colorWithCGColor:color];
}

- (void)setColor:(UIColor *)color
{
    self.calendar.CGColor = color.CGColor;
}

- (void)rollback
{
    [self.calendar rollback];
}

- (void)deleteItem
{
    NSError *error = nil;
    
    if ([[PZModel instance].eventStore removeCalendar:self.calendar commit:NO error:&error] == NO)
    {
        NSLog(@"[PZReminderItem] deleteCalendar error: %@", error);
    }
}

- (void)saveItem
{
    NSError *error = nil;
    
    if ([[PZModel instance].eventStore saveCalendar:self.calendar commit:NO error:&error] == NO)
    {
        NSLog(@"[PZReminderItem] saveCalendar error: %@", error);
    }
}

@end
