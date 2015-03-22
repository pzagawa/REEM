//
//  PZReminderTableViewCell.m
//  Reeminders
//
//  Created by Piotr on 10.08.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import "PZReminderTableViewCell.h"

#define TODO_ALPHA 1.0f
#define DONE_ALPHA 0.7f

@interface PZReminderTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageChecked;
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UILabel *labTime;
@property (weak, nonatomic) IBOutlet UILabel *labDetails;
@property (weak, nonatomic) IBOutlet UILabel *labDate;
@property (weak, nonatomic) IBOutlet UIImageView *imageNote;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layConstTimeWidth;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layConstImageNoteWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layConstImageNoteRightMargin;

@end

@implementation PZReminderTableViewCell
{
    UIColor *_timeColorOntime;
    UIColor *_timeColorOvertime;

    __weak PZReminderItem *_dataItem;
    
    CGFloat _defaultTimeLabelWidth;

    CGFloat _defaultImageNoteWidth;
    CGFloat _defaultImageNoteRightMargin;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _timeColorOntime = [UIColor colorWithRed:0.3 green:0.4 blue:0.7 alpha:1];
    _timeColorOvertime = [UIColor colorWithRed:1 green:0.3 blue:0.5 alpha:1];
    
    _defaultTimeLabelWidth = self.layConstTimeWidth.constant;
    
    _defaultImageNoteWidth = self.layConstImageNoteWidth.constant;
    _defaultImageNoteRightMargin = self.layConstImageNoteRightMargin.constant;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
}

- (PZReminderItem *)dataItem
{
    return self->_dataItem;
}

- (UIImage *)statusImageIfCompleted:(BOOL)isCompleted andAlarmExpired:(BOOL)isAlarmExpired withPriority:(PZReminderItemPriority)priority

{
    UIImage *image = [UIImage imageNamed:@"list_item_reminder_state_todo"];
    
    if (isCompleted)
    {
        image = [UIImage imageNamed:@"list_item_reminder_state_done"];
    }
    else
    {
        if (isAlarmExpired)
        {
            image = [UIImage imageNamed:@"list_item_reminder_state_todo_expired"];
          
            if (priority == PZReminderItemPriority_LOW)
            {
                image = [UIImage imageNamed:@"list_item_reminder_state_pri1_expired"];
            }
            
            if (priority == PZReminderItemPriority_MEDIUM)
            {
                image = [UIImage imageNamed:@"list_item_reminder_state_pri2_expired"];
            }
            
            if (priority == PZReminderItemPriority_HIGH)
            {
                image = [UIImage imageNamed:@"list_item_reminder_state_pri3_expired"];
            }
        }
        else
        {
            if (priority == PZReminderItemPriority_LOW)
            {
                image = [UIImage imageNamed:@"list_item_reminder_state_pri1"];
            }
            
            if (priority == PZReminderItemPriority_MEDIUM)
            {
                image = [UIImage imageNamed:@"list_item_reminder_state_pri2"];
            }
            
            if (priority == PZReminderItemPriority_HIGH)
            {
                image = [UIImage imageNamed:@"list_item_reminder_state_pri3"];
            }
        }
    }

    return image;
}

- (void)setDataItem:(PZReminderItem *)dataItem
{
    self->_dataItem = dataItem;
    
    BOOL isAlarmExpired = dataItem.isAlarmExpired;
    BOOL isCompleted = dataItem.isCompleted;
    
    if (self.labDate != nil)
    {
        self.labDate.text = @"";
    }
    
    //set alpha and left action icon
    if (isCompleted)
    {
        self.labTitle.alpha = DONE_ALPHA;
        self.labDetails.alpha = DONE_ALPHA;
        self.labTime.alpha = DONE_ALPHA;
        
        self.leftActionIcon = [UIImage imageNamed:@"list_item_action_todo.png"];
    }
    else
    {
        self.labTitle.alpha = TODO_ALPHA;
        self.labDetails.alpha = TODO_ALPHA;
        self.labTime.alpha = TODO_ALPHA;
        
        self.leftActionIcon = [UIImage imageNamed:@"list_item_action_done.png"];
    }
    
    self.labTitle.text = dataItem.title;
    self.labDetails.text = dataItem.tagName;
    self.labTime.text = dataItem.alarmTimeText;

    //set status image
    self.imageChecked.image = [self statusImageIfCompleted:isCompleted andAlarmExpired:isAlarmExpired withPriority:dataItem.priorityType];
    
    //resize time label to match content
    [self.labTime sizeToFit];

    self.layConstTimeWidth.constant = self.labTime.bounds.size.width;

    //mark time by color
    self.labTime.textColor = isAlarmExpired ? _timeColorOvertime : _timeColorOntime;

    //set optional date label
    if (self.labDate != nil)
    {
        if (dataItem.isShowDateEnabled)
        {
            self.labDate.text = dataItem.alarmDateText;
        }
    }
    
    //set note image
    if (dataItem.hasNotes)
    {
        self.layConstImageNoteWidth.constant = _defaultImageNoteWidth;
        self.layConstImageNoteRightMargin.constant = _defaultImageNoteRightMargin;
        self.imageNote.hidden = NO;
    }
    else
    {
        self.layConstImageNoteWidth.constant = 0;
        self.layConstImageNoteRightMargin.constant = 0;
        self.imageNote.hidden = YES;
    }

    self.hasLeftSwipeAction = YES;
}

@end
