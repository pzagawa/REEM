//
//  PZAlarmSelectorView.m
//  REEM
//
//  Created by Piotr Zagawa on 16.11.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import "PZAlarmSelectorView.h"

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

@property (weak) UITapGestureRecognizer *singleTapGestureRecognizer;

@end

@implementation PZAlarmSelectorView

+ (PZAlarmSelectorView *)instanceWithViewController:(UIViewController *)viewController
{
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"PZAlarmSelectorView" owner:nil options:nil];
    
    PZAlarmSelectorView *view = [nibContents lastObject];
        
    [view initializeWithViewController:viewController];

    [view addToParentView:viewController.view];

    return view;
}

- (void)dealloc
{
    self.completionBlock = nil;
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

    self.singleTapGestureRecognizer = singleTapGestureRecognizer;
    
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
    __weak PZAlarmSelectorView *selfWeakRef = self;

    self.datePicker.enabled = enabled;
    self.datePicker.userInteractionEnabled = enabled;
    
    [UIView animateWithDuration:0.1 animations:^
    {
        if (enabled)
        {
            selfWeakRef.datePicker.alpha = 1;
            selfWeakRef.alarmDisabledLabel.alpha = 0;
        }
        else
        {
            selfWeakRef.datePicker.alpha = 0;
            selfWeakRef.alarmDisabledLabel.alpha = 1;
        }
    }
    completion:^(BOOL finished)
    {
        selfWeakRef.datePicker.hidden = !enabled;
        selfWeakRef.alarmDisabledLabel.hidden = enabled;
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
    __weak PZAlarmSelectorView *selfWeakRef = self;

    [UIView animateWithDuration:0.2 animations:^
    {
        selfWeakRef.alpha = 0;
    }
    completion:^(BOOL finished)
    {
        selfWeakRef.hidden = YES;

        [selfWeakRef cleanup];
    }];
}

- (void)cleanup
{
    [self removeGestureRecognizer:self.singleTapGestureRecognizer];

    [self removeFromSuperview];
}

- (void)showSelector
{
    __weak PZAlarmSelectorView *selfWeakRef = self;

    NSLog(@"[PZAlarmSelectorView] showForReminderItem:%@", self.reminderItem);

    [self updateStateWithData];
    
    self.alpha = 0;
    self.hidden = NO;
    
    [UIView animateWithDuration:0.1 animations:^
    {
        selfWeakRef.alpha = 1;
    }];
}

- (void)updateStateWithData
{
    self.titleLabel.text = self.reminderItem.title;
    
    if (self.reminderItem.alarmDate == nil)
    {
        [self setDatePickerEnabled:NO];
        [self.alarmSwitch setOn:NO];

        self.selectedTime = nil;
    }
    else
    {
        [self setDatePickerEnabled:YES];
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

- (void)showForReminderItem:(PZReminderItem *)reminderItem withCompletion:(PZAlarmSelectorViewCompletionBlock)completionBlock
{
    self.reminderItem = reminderItem;
    self.completionBlock = completionBlock;

    [self showSelector];
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
