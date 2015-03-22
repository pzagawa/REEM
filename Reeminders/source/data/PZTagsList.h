//
//  PZTagsList.h
//  Reeminders
//
//  Created by Piotr on 17.08.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PZItemsList.h"
#import "PZTagItem.h"

typedef void (^PZTagItemsFetchCompletionBlock) ();

@interface PZTagsList : PZItemsList

@property NSArray *ekCalendars;

@property NSArray *items;

@property (readonly) PZTagItem *defaultTagItem;

- (PZTagItem *)itemWithUid:(NSString *)itemUid;

- (void)fetchTags:(PZTagItemsFetchCompletionBlock)completionBlock;

@end
