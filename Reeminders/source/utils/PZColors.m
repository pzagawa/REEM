//
//  PZColors.m
//  Reeminders
//
//  Created by Piotr on 02.08.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import "PZColors.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

static PZColors *colors;

@implementation PZColors

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self->_background = UIColorFromRGB(0x341B04);
        self->_tint = UIColorFromRGB(0xFFDFC2);
        
        self->_defaultCalendarColors = @
        [
            UIColorFromRGB(0xFF2968),
            UIColorFromRGB(0xFF9500),
            UIColorFromRGB(0xFFCC00),
            UIColorFromRGB(0x63DA38),
            UIColorFromRGB(0x1BADF8),
            UIColorFromRGB(0xCC73E1),
            UIColorFromRGB(0xA2845E),
        ];
    }
    
    return self;
}

+ (PZColors *)instance
{
    if (colors == nil)
    {
        colors = [PZColors new];
    }
    
    return colors;
}

- (CGFloat)averageDifferenceOfColor:(UIColor *)color1 withColor:(UIColor *)color2
{
    CGFloat r1, g1, b1, a1;
    CGFloat r2, g2, b2, a2;

    [color1 getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    [color2 getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
    
    CGFloat r = fabs(r2 - r1);
    CGFloat g = fabs(g2 - g1);
    CGFloat b = fabs(b2 - b1);
    CGFloat a = fabs(a2 - a1);
    
    return ((r + g + b + a) / 4.0f);
}

@end
