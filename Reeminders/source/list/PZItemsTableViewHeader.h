//
//  PZItemsTableViewHeader.h
//  Reeminders
//
//  Created by Piotr on 28.09.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PZItemsTableViewHeader : UIView

- (UIView *)headerForTableView:(UITableView *)tableView withTitle:(NSString *)headerTitle;

@end
