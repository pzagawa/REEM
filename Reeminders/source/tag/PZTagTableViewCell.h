//
//  PZTagTableViewCell.h
//  Reeminders
//
//  Created by Piotr on 10.08.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PZTagItem.h"
#import "PZTableViewCell.h"

@interface PZTagTableViewCell : PZTableViewCell

@property (weak, nonatomic) IBOutlet UIView *swipeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layConstSwipeViewL;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layConstSwipeViewR;

@property PZTagItem *dataItem;

@end
