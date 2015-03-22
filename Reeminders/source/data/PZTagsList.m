//
//  PZTagsList.m
//  Reeminders
//
//  Created by Piotr on 17.08.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import "PZTagsList.h"

@interface PZTagsList ()

@property (readonly) NSMutableDictionary *map;

@end

@implementation PZTagsList
{
    NSArray *_ekCalendars;
}

- (instancetype)initWithEventStore:(EKEventStore *)eventStore
{
    self = [super initWithEventStore:eventStore];
    
    if (self)
    {
        self->_map = [NSMutableDictionary new];
    }
    
    return self;
}

- (PZDataItemType)itemType
{
    return PZDataItemType_TAG;
}

- (PZTagItem *)itemWithUid:(NSString *)itemUid
{
    @synchronized(self)
    {
        return [self.map objectForKey:itemUid];
    }
}

- (NSArray *)ekCalendars
{
    @synchronized(self)
    {
        return _ekCalendars;
    }
}

- (void)setEkCalendars:(NSArray *)ekCalendars
{
    @synchronized(self)
    {
        self->_ekCalendars = [self sortCalendars:ekCalendars];

        NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:self.ekCalendars.count];

        for (EKCalendar *calendar in self->_ekCalendars)
        {
            PZTagItem *item = [[PZTagItem alloc] initWithCalendar:calendar];
            
            [items addObject:item];
            
            [self.map setObject:item forKey:item.itemUid];
        }
        
        self.items = [NSArray arrayWithArray:items];
    }

    NSLog(@"[PZTagsList] ekCalendars set (%li)", (long)self.items.count);
}

- (void)fetchTags:(PZTagItemsFetchCompletionBlock)completionBlock
{
    [self.operationQueue addOperation:[NSBlockOperation blockOperationWithBlock:^
    {
        self.ekCalendars = [self.eventStore calendarsForEntityType:EKEntityTypeReminder];

        dispatch_async(dispatch_get_main_queue (), ^(void)
        {
            completionBlock();
        });
    }]];
}

- (PZTagItem *)defaultTagItem
{
    EKCalendar *defaultCalendar = [self.eventStore defaultCalendarForNewReminders];

    if (defaultCalendar != nil)
    {
        NSString *defaultCalendarItemUid = defaultCalendar.calendarIdentifier;
        
        return [self itemWithUid:defaultCalendarItemUid];
    }
    
    return nil;
}

@end
