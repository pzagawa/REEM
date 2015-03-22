//
//  PZItemsTableViewHeader.m
//  Reeminders
//
//  Created by Piotr on 28.09.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import "PZItemsTableViewHeader.h"

@implementation PZItemsTableViewHeader

- (UIView *)headerForTableView:(UITableView *)tableView withTitle:(NSString *)headerTitle
{
    float headerWidth = tableView.frame.size.width * 4;
    float headerHeight = tableView.sectionHeaderHeight;

    //create label with section title
    UIColor *textColor = [UIColor colorWithRed:0.6 green:0.5 blue:0.4 alpha:1.0];

    UILabel *label = [[UILabel alloc] init];

    label.frame = CGRectMake(10, 1, 320, headerHeight - 1);

    label.backgroundColor = [UIColor clearColor];
    
    label.backgroundColor = tableView.backgroundColor;

    label.textColor = textColor;

    label.opaque = NO;
    label.font = [UIFont systemFontOfSize:12];
    label.text = headerTitle;

    //create header view and add label as a subview
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10, 0, headerWidth, headerHeight)];

    float underLineHeight = 0.5;

    UIView *viewUnderLine = [[UIView alloc] initWithFrame:CGRectMake(0, headerHeight - underLineHeight, headerWidth, 0.5)];

    viewUnderLine.backgroundColor = [UIColor colorWithRed:0.8 green:0.7 blue:0.6 alpha:0.5];

    view.backgroundColor = tableView.backgroundColor;

    [view addSubview:label];

    [view addSubview:viewUnderLine];
    
    return view;
}

@end
