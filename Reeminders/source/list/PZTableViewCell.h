//
//  PZTableViewCell.h
//  REEM
//
//  Created by Piotr Zagawa on 13.11.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PZTableViewCell;

@protocol PZTableViewCellDelegate <NSObject>

- (void)onSwipeStartActionWithCell:(PZTableViewCell *)cell;
- (void)onSwipeRightActionWithCell:(PZTableViewCell *)cell;
- (void)onSwipeLeftLockWithCell:(PZTableViewCell *)cell;
- (void)onLongPressWithCell:(PZTableViewCell *)cell;

- (NSArray *)rightActionButtonsWithCell:(PZTableViewCell *)cell;

@end

@interface PZTableViewCell : UITableViewCell<UIGestureRecognizerDelegate>

@property (weak, nonatomic) UIView *swipeView;
@property (weak, nonatomic) NSLayoutConstraint *layConstSwipeViewL;
@property (weak, nonatomic) NSLayoutConstraint *layConstSwipeViewR;

@property NSIndexPath *indexPath;

@property BOOL hasLeftSwipeAction;

@property UIImage *leftActionIcon;

@property (weak) id<PZTableViewCellDelegate> delegate;

- (void)setScrollSwipeViewBack;

+ (UIButton *)createCustomButtonWithImageNamed:(NSString *)imageName;

@end
