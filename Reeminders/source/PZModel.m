//
//  PZModel.m
//  Reeminders
//
//  Created by Piotr on 11.08.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import "PZModel.h"

@import EventKit;

static PZModel *model = nil;

@interface PZModel ()

@property (readonly) BOOL isEventStoreAccessGranted;
@property (readonly) NSError *eventStoreAccessError;

@property (readonly) NSOperationQueue *operationQueue;

@property NSArray *ekCalendars;

@end

#pragma mark Initialization

@implementation PZModel
{
    EKEventStore *_eventStore;
    NSObject *_eventStoreLock;
    PZTagItem *_defaultTagItem;
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self->_eventStoreLock = [NSObject new];

        [self recreateEventStore];

        self->_operationQueue = [[NSOperationQueue alloc] init];
        
        self.operationQueue.maxConcurrentOperationCount = 1;

        self.ekCalendars = @[];
        
        self->_tagsAll = [[PZTagsList alloc] init];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onModelNotification:) name:NOTIFICATION_MODEL_EVENT_STORE_INITIALIZED object:self];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (void)createInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        model = [PZModel new];
    });
}

+ (PZModel *)instance
{
    return model;
}

- (EKEventStore *)eventStore
{
    @synchronized(self->_eventStoreLock)
    {
        return self->_eventStore;
    }
}

//recreate event store (to avoid EKCADErrorDomain error 1013)
- (void)recreateEventStore
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EKEventStoreChangedNotification object:self.eventStore];

    @synchronized(self->_eventStoreLock)
    {
        self->_eventStore = [[EKEventStore alloc] init];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onEventStoreNotification:) name:EKEventStoreChangedNotification object:self.eventStore];
}

- (void)initializeEventStore:(PZEventStoreInitializeCompletionBlock)completionBlock
{
    NSLog(@"[PZModel] initializeEventStore..");

    [self.eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error)
    {
        self->_isEventStoreAccessGranted = granted;
        self->_eventStoreAccessError = [error copy];

        if (granted)
        {
            [self recreateEventStore];
        }
        
        NSLog(@"[PZModel] event store initialized (access granted: %@, error: %@)", (granted ? @"Y" : @"N"), error);

        NSDictionary *userInfo = @{ @"granted": @(granted) };
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MODEL_EVENT_STORE_INITIALIZED object:self userInfo:userInfo];

        completionBlock(granted, error);
    }];
}

- (BOOL)isEventStoreAccessAuthorized
{
    EKAuthorizationStatus authStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];

    return (authStatus == EKAuthorizationStatusAuthorized);
}

#pragma mark Event when model data update

- (void)onModelNotification:(NSNotification *)notification
{
    if ([notification.name isEqual:NOTIFICATION_MODEL_EVENT_STORE_INITIALIZED])
    {
        [self fetchTags];
    }
}

#pragma mark Event when store data change

- (void)onEventStoreNotification:(NSNotification *)notification
{
    [self fetchTags];
}

- (void)fetchTags
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MODEL_EVENT_STORE_FETCHING_STARTED object:self userInfo:nil];
    
    [self.tagsAll fetchTags:^
    {
        self->_defaultTagItem = self.tagsAll.defaultTagItem;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MODEL_EVENT_STORE_FETCHING_FINISHED object:self userInfo:nil];
    }];
}

- (EKSource *)eventStoreCloudSource
{
    NSArray *sources = self.eventStore.sources;
    
    for (EKSource *source in sources)
    {
        if (source.sourceType == EKSourceTypeCalDAV)
        {
            return source;
        }
    }

    for (EKSource *source in sources)
    {
        if (source.sourceType == EKSourceTypeLocal)
        {
            return source;
        }
    }

    return nil;
}

- (EKCalendar *)createNewCalendarItem
{
    EKSource *source = [self eventStoreCloudSource];
    
    EKCalendar *calendar = [EKCalendar calendarForEntityType:EKEntityTypeReminder eventStore:self.eventStore];

    calendar.source = source;
    
    return calendar;
}

- (EKReminder *)createNewReminderItem
{
    EKReminder *reminder = [EKReminder reminderWithEventStore:self.eventStore];
    
    return reminder;
}

- (PZTagItem *)defaultTagItem
{
    return self->_defaultTagItem;
}

@end
