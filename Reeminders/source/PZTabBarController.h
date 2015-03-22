//
//  PZTabBarController.h
//  REEM
//
//  Created by Piotr Zagawa on 02.11.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PZItemsTableViewController.h"

@interface PZTabBarController : UITabBarController<UITabBarControllerDelegate>

@property (readonly) PZDataListItemsType selectedListItemsType;

@end
