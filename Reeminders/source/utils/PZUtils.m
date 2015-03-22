//
//  PZUtils.m
//  Reeminders
//
//  Created by Piotr on 02.08.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import "PZUtils.h"

static BOOL _is24HourClockFormat;

@implementation PZUtils

+ (void)initialize
{
    if (self == [PZUtils class])
    {
        _is24HourClockFormat = [PZUtils checkIs24HourClockFormat];
    }
}

+ (BOOL)isStringEmpty:(NSString *)text
{
    if ((NSNull *)text == [NSNull null])
    {
        return YES;
    }
    
    if (text == nil)
    {
        return YES;
    }
    else if ([text length] == 0)
    {
        return YES;
    }
    else
    {
        NSString *newText = [text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([newText length] == 0)
        {
            return YES;
        }
    }

    return NO;
}

+ (NSString *)trimString:(NSString *)text
{
    if ((NSNull *)text == [NSNull null])
    {
        return text;
    }
    
    if (text == nil)
    {
        return text;
    }
    
    if ([text length] == 0)
    {
        return text;
    }
    
    return [text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
}

+ (NSString *)trimStringWithNewline:(NSString *)text
{
    if ((NSNull *)text == [NSNull null])
    {
        return text;
    }
    
    if (text == nil)
    {
        return text;
    }
    
    if ([text length] == 0)
    {
        return text;
    }
    
    return [text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSString *)trimStringForTitleLine:(NSString *)text
{
    if ((NSNull *)text == [NSNull null])
    {
        return @"";
    }
    
    if (text == nil)
    {
        return @"";
    }
    
    if ([text length] == 0)
    {
        return @"";
    }
    
    text = [text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    text = [text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
    
    return text;
}

+ (NSString *)trimString:(NSString *)text toLength:(NSUInteger)length
{
    if (text != nil)
    {
        if (text.length > length)
        {
            return [NSString stringWithFormat:@"%@..", [text substringToIndex:(length - 1)]];
        }
    }
    
    return text;
}

+ (NSString *)appTitle
{
    static NSString *value = nil;
    
    if (value == nil)
    {
        NSBundle *bundle = [NSBundle mainBundle];
        NSDictionary *map = [bundle infoDictionary];
        value = [map objectForKey:(NSString *)kCFBundleNameKey];
    }
    
    return value;
}

+ (void)delaySeconds:(float)seconds withCompletionBlock:(PZUtilsDelayCompletionBlock)completionBlock
{
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC);

    dispatch_after(delayTime, dispatch_get_main_queue(), ^(void)
    {
        completionBlock();
    });
}

+ (BOOL)checkIs24HourClockFormat
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setLocale:[NSLocale currentLocale]];
    
    [formatter setDateStyle:NSDateFormatterNoStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSString *dateString = [formatter stringFromDate:[NSDate date]];

    NSRange amRange = [dateString rangeOfString:[formatter AMSymbol]];
    NSRange pmRange = [dateString rangeOfString:[formatter PMSymbol]];
    
    return (amRange.location == NSNotFound && pmRange.location == NSNotFound);
}

+ (BOOL)is24HourClockFormat
{
    return _is24HourClockFormat;
}

@end
