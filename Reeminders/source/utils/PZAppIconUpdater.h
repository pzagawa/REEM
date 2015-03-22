//
//  PZAppIconUpdater.h
//  REEM
//
//  Created by Piotr Zagawa on 09.11.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^PZAppIconUpdateCompletionBlock) ();

@interface PZAppIconUpdater : NSObject

+ (void)initPermissions;

+ (void)updateBadgeNumber;

+ (void)updateBadgeNumberWithCompletion:(PZAppIconUpdateCompletionBlock)completionBlock;

@end
