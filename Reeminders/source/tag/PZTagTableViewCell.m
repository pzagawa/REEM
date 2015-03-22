//
//  PZTagTableViewCell.m
//  Reeminders
//
//  Created by Piotr on 10.08.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import "PZTagTableViewCell.h"

@interface PZTagTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *labTitle;

@end

@implementation PZTagTableViewCell
{
    __weak PZTagItem *_dataItem;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.iconView.layer.backgroundColor = [UIColor redColor].CGColor;
    self.iconView.layer.cornerRadius = 3;
}

- (PZTagItem *)dataItem
{
    return self->_dataItem;
}

- (void)setDataItem:(PZTagItem *)dataItem
{
    self->_dataItem = dataItem;

    self.hasLeftSwipeAction = NO;

    self.labTitle.text = dataItem.name;
    
    self.iconView.backgroundColor = dataItem.color;
}

@end
