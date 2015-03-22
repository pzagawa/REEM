//
//  PZEditViewControllerEvents.h
//  Reeminders
//
//  Created by Piotr on 20.08.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PZItem;

@protocol PZEditViewControllerEvents <NSObject>

- (void)onItemEditCancel;
- (void)onItemEditAccept:(PZItem *)item;

@end
