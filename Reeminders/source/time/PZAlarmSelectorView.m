//
//  PZAlarmSelectorView.m
//  REEM
//
//  Created by Piotr Zagawa on 16.11.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import "PZAlarmSelectorView.h"

__weak static PZAlarmSelectorView *this = nil;

@interface PZAlarmSelectorView ()

@property (weak) UIViewController *parentViewController;

@property (weak, nonatomic) IBOutlet UIView *mainView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UISwitch *alarmSwitch;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UILabel *alarmDisabledLabel;

@property (weak) PZReminderItem *reminderItem;

@property (copy) PZAlarmSelectorViewCompletionBlock completionBlock;

@property NSDate *selectedTime;

@end

@implementation PZAlarmSelectorView

+ (PZAlarmSelectorView *)instanceWithViewController:(UIViewController *)viewController
{
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"PZAlarmSelectorView" owner:nil options:nil];
    
    PZAlarmSelectorView *view = [nibContents lastObject];
        
    [view initializeWithViewController:viewController];
    
    this = view;
    
    return view;
}

- (void)initializeWithViewController:(UIViewController *)viewController
{
    self.parentViewController = viewController;
    
    self.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.hidden = YES;
    
    //single tap gesture detector
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onMainViewTap:)];
    
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    singleTapGestureRecognizer.numberOfTouchesRequired = 1;
    
    [self addGestureRecognizer:singleTapGestureRecognizer];
}

- (void)addToParentView:(UIView *)parentView
{
    CGSize size = parentView.frame.size;
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    self.frame = rect;
    
    [parentView addSubview:self];
}

- (IBAction)onAlarmSwitchChange:(id)sender
{
    [self setWithAnimationDatePickerEnabled:self.alarmSwitch.isOn];
}

- (void)setDatePickerEnabled:(BOOL)enabled
{
    self.datePicker.enabled = enabled;
    self.datePicker.userInteractionEnabled = enabled;

    self.datePicker.alpha = enabled ? 1 : 0;
    self.alarmDisabledLabel.alpha = enabled ? 0 : 1;

    self.datePicker.hidden = !enabled;
    self.alarmDisabledLabel.hidden = enabled;
}

- (void)setWithAnimationDatePickerEnabled:(BOOL)enabled
{
    self.datePicker.enabled = enabled;
    self.datePicker.userInteractionEnabled = enabled;
    
    [UIView animateWithDuration:0.1 animations:^
    {
        if (enabled)
        {
            self.datePicker.alpha = 1;
            self.alarmDisabledLabel.alpha = 0;
        }
        else
        {
            self.datePicker.alpha = 0;
            self.alarmDisabledLabel.alpha = 1;
        }
    }
    completion:^(BOOL finished)
    {
        self.datePicker.hidden = !enabled;
        self.alarmDisabledLabel.hidden = enabled;
    }];
}

- (IBAction)onTapDoneButton:(id)sender
{
    if (self.completionBlock != nil)
    {
        NSDate *date = nil;
        
        if (self.alarmSwitch.isOn)
        {
            date = self.selectedTime;
        }
        
        NSLog(@"[PZAlarmSelectorView] done: %@", date);
        
        self.completionBlock(date, NO);
        
        self.completionBlock = nil;
    }
    
    [self hideSelector];
}

- (void)hideSelector
{
    [UIView animateWithDuration:0.2 animations:^
    {
        this.alpha = 0;
    }
    completion:^(BOOL finished)
    {
        self.hidden = YES;
    }];
}

- (void)showSelector
{
    NSLog(@"[PZAlarmSelectorView] showForReminderItem:%@", this.reminderItem);

    [self updateStateWithData];
    
    this.alpha = 0;
    this.hidden = NO;
    
    [UIView animateWithDuration:0.2 animations:^
    {
        this.alpha = 1;
    }];
}

- (void)updateStateWithData
{
    self.titleLabel.text = self.reminderItem.title;
    
    if (self.reminderItem.alarmDate == nil)
    {
        [this setDatePickerEnabled:NO];
        [self.alarmSwitch setOn:NO];

        self.selectedTime = nil;
    }
    else
    {
        [this setDatePickerEnabled:YES];
        [self.alarmSwitch setOn:YES];
        
        NSLog(@"[PZAlarmSelectorView] updateStateWithData: %@", self.reminderItem.alarmDate);

        self.selectedTime = self.reminderItem.alarmDate;
    }
}

- (NSDate *)selectedTime
{
    NSCalendarUnit units = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute);
    
    NSDateComponents *nowDateComponents = [[NSCalendar currentCalendar] components:units fromDate:self.datePicker.date];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    components.year = nowDateComponents.year;
    components.month = nowDateComponents.month;
    components.day = nowDateComponents.day;
    components.hour = nowDateComponents.hour;
    components.minute = (nowDateComponents.minute / 5) * 5;
    components.second = 0;
    
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

- (void)setSelectedTime:(NSDate *)selectedTime
{
    if (selectedTime == nil)
    {
        selectedTime = [NSDate date];
    }
    
    NSCalendarUnit units = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute);
    
    NSDateComponents *nowDateComponents = [[NSCalendar currentCalendar] components:units fromDate:selectedTime];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    components.year = nowDateComponents.year;
    components.month = nowDateComponents.month;
    components.day = nowDateComponents.day;
    components.hour = nowDateComponents.hour;
    components.minute = (nowDateComponents.minute / 5) * 5;
    components.second = 0;
    
    self.datePicker.date = [[NSCalendar currentCalendar] dateFromComponents:components];
}

+ (void)showForReminderItem:(PZReminderItem *)reminderItem withCompletion:(PZAlarmSelectorViewCompletionBlock)completionBlock
{
    if (this != nil)
    {
        this.reminderItem = reminderItem;
        this.completionBlock = completionBlock;
        
        [this showSelector];
    }
}

- (void)onMainViewTap:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        //hide view if tapped outside MainView
        CGPoint point = [recognizer locationInView:self];
        CGFloat mainViewTop = self.mainView.frame.origin.y;
        CGFloat mainViewBottom = self.mainView.frame.origin.y + self.mainView.frame.size.height;

        //process when touch outside MainView
        if (point.y < mainViewTop || point.y > mainViewBottom)
        {
            self.completionBlock(nil, YES);
            
            self.completionBlock = nil;

            [self hideSelector];
        }
    }
}

@end
