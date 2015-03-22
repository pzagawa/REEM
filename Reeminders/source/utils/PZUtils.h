//
//  PZUtils.h
//  Reeminders
//
//  Created by Piotr on 02.08.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^PZUtilsDelayCompletionBlock) ();

@interface PZUtils : NSObject

+ (BOOL)isStringEmpty:(NSString *)text;

+ (NSString *)trimString:(NSString *)text;
+ (NSString *)trimStringWithNewline:(NSString *)text;
+ (NSString *)trimStringForTitleLine:(NSString *)text;
+ (NSString *)trimString:(NSString *)text toLength:(NSUInteger)length;

+ (NSString *)appTitle;

+ (void)delaySeconds:(float)seconds withCompletionBlock:(PZUtilsDelayCompletionBlock)completionBlock;

+ (BOOL)is24HourClockFormat;

@end
