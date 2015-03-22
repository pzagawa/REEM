//
//  PZColors.h
//  Reeminders
//
//  Created by Piotr on 02.08.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PZColors : NSObject

@property (readonly) UIColor *background;
@property (readonly) UIColor *tint;

@property (readonly) NSArray *defaultCalendarColors;

+ (PZColors *)instance;

- (CGFloat)averageDifferenceOfColor:(UIColor *)color1 withColor:(UIColor *)color2;

@end
