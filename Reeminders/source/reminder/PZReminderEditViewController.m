//
//  PZReminderEditViewController.m
//  Reeminders
//
//  Created by Piotr on 14.08.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import "PZReminderEditViewController.h"
#import "PZReminderItem.h"
#import "PZTagsList.h"
#import "PZTagItem.h"
#import "PZModel.h"

typedef void (^PZReminderEditAnimationCompletionBlock) ();

@interface PZReminderEditViewController ()

@property (weak, nonatomic) IBOutlet UILabel *labTitle;

@property (weak, nonatomic) IBOutlet UISegmentedControl *pageSelector;

@property (weak, nonatomic) IBOutlet UITextField *editTitle;
@property (weak, nonatomic) IBOutlet UISegmentedControl *prioritySwitch;

@property (weak, nonatomic) IBOutlet UIPickerView *tagPicker;

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UISwitch *alarmSwitch;

@property (weak, nonatomic) IBOutlet UITextView *noteEdit;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layConstBottomPage3;

@property (weak, nonatomic) IBOutlet UILabel *alarmDisabledLabel;

@property (weak, nonatomic) IBOutlet UIView *pageTitle;
@property (weak, nonatomic) IBOutlet UIView *pageTag;
@property (weak, nonatomic) IBOutlet UIView *pageAlarm;
@property (weak, nonatomic) IBOutlet UIView *pageNote;

@property NSArray *tagItems;

@property NSDate *selectedAlarmTime;

@end

@implementation PZReminderEditViewController
{
    CGFloat _defaultBottomPage3;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.labTitle.text = self.itemEditModeText;
    
    self->_defaultBottomPage3 = self.layConstBottomPage3.constant;
    
    self.noteEdit.layer.borderWidth = 0.5f;
    self.noteEdit.layer.borderColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1].CGColor;
    
    self.tagItems = @[];
    self.tagPicker.dataSource = self;
    self.tagPicker.delegate = self;
    
    self.tagItems = [[PZModel instance].tagsAll.items copy];

    [self.tagPicker reloadAllComponents];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self updateUiStateFromData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self becomeFirstResponderOnActivePage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

- (IBAction)actionCancel:(id)sender
{
    [self resignFirstResponderFromAllPages];

    [self editCancelWithCompletion:^
    {
        //finish
    }];
}

- (IBAction)actionAccept:(id)sender
{
    [self resignFirstResponderFromAllPages];
    
    [self editAcceptWithCompletion:^
    {
        //finish
    }];
}

- (NSString *)itemEditModeText
{
    return [NSString stringWithFormat:@"%@ reminder", [super itemEditModeText]];
}

#pragma mark Keyboard handling

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    
    CGRect rectKeyboard = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    self.layConstBottomPage3.constant = (rectKeyboard.size.height + self->_defaultBottomPage3);
    
    [UIView animateWithDuration:0.2 animations:^
    {
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.layConstBottomPage3.constant = self->_defaultBottomPage3;
    
    [UIView animateWithDuration:0.2 animations:^
    {
        [self.view layoutIfNeeded];
    }];
}

#pragma mark UI pages visibility

- (void)resignFirstResponderFromAllPages
{
    [self.editTitle resignFirstResponder];
    [self.noteEdit resignFirstResponder];
}

- (void)becomeFirstResponderOnActivePage
{
    if (self.pageSelector.selectedSegmentIndex == 0)
    {
        [self.editTitle becomeFirstResponder];
    }
    
    if (self.pageSelector.selectedSegmentIndex == 1)
    {
    }
    
    if (self.pageSelector.selectedSegmentIndex == 2)
    {
        [self.noteEdit becomeFirstResponder];
    }
}

- (void)viewContainer:(UIView *)view visibilityEnable:(BOOL)enable
{
    view.hidden = !enable;
    view.userInteractionEnabled = enable;
    view.alpha = enable ? 1 : 0;
}

- (void)hideAllPageViews:(BOOL)hide
{
    [self viewContainer:self.pageTitle visibilityEnable:NO];
    [self viewContainer:self.pageTag visibilityEnable:NO];
    [self viewContainer:self.pageAlarm visibilityEnable:NO];
    [self viewContainer:self.pageNote visibilityEnable:NO];
}

- (void)hideAllPageViewsWithCompletion:(PZReminderEditAnimationCompletionBlock)completion
{
    [UIView animateWithDuration:0.1 animations:^
    {
        self.pageTitle.alpha = 0;
        self.pageTag.alpha = 0;
        self.pageAlarm.alpha = 0;
        self.pageNote.alpha = 0;
    }
    completion:^(BOOL finished)
    {
        [self viewContainer:self.pageTitle visibilityEnable:NO];
        [self viewContainer:self.pageTag visibilityEnable:NO];
        [self viewContainer:self.pageAlarm visibilityEnable:NO];
        [self viewContainer:self.pageNote visibilityEnable:NO];
        
        completion();
    }];
}

- (void)showPageView:(UIView *)pageView withCompletion:(PZReminderEditAnimationCompletionBlock)completion
{
    pageView.hidden = NO;
    
    [UIView animateWithDuration:0.1 animations:^
    {
        pageView.alpha = 1;
    }
    completion:^(BOOL finished)
    {
        pageView.userInteractionEnabled = YES;

        completion();
    }];
}

- (IBAction)onPageSelectorChange:(id)sender
{
    UISegmentedControl *control = sender;
 
    [self resignFirstResponderFromAllPages];

    [self hideAllPageViewsWithCompletion:^
    {
        if (control.selectedSegmentIndex == 0)
        {
            [self showPageView:self.pageTitle withCompletion:^
            {
                [self.editTitle becomeFirstResponder];
            }];
        }

        if (control.selectedSegmentIndex == 1)
        {
            [self showPageView:self.pageTag withCompletion:^
            {
            }];
        }

        if (control.selectedSegmentIndex == 2)
        {
            [self showPageView:self.pageAlarm withCompletion:^
            {
            }];
        }
        
        if (control.selectedSegmentIndex == 3)
        {
            [self showPageView:self.pageNote withCompletion:^
            {
                [self.noteEdit becomeFirstResponder];
            }];
        }
    }];
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
        
        self.selectedAlarmTime = [self startDateForNewReminder];
    }];
}

- (NSDate *)startDateForNewReminder
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];

    NSDate *now = [NSDate date];
    
    if (self.listType == PZDataListItemsTypeRemindersToday)
    {
        [dateComponents setMinute:15];

        now = [calendar dateByAddingComponents:dateComponents toDate:now options:0];
    }

    if (self.listType == PZDataListItemsTypeRemindersLater)
    {
        [dateComponents setDay:1];
        [dateComponents setMinute:15];
        
        now = [calendar dateByAddingComponents:dateComponents toDate:now options:0];
    }

    if (self.listType == PZDataListItemsTypeReminders)
    {
        [dateComponents setMinute:15];
        
        now = [calendar dateByAddingComponents:dateComponents toDate:now options:0];
    }
    
    return now;
}

#pragma mark PickerView for Tag list

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.tagItems.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    PZTagItem *tagItem = [self.tagItems objectAtIndex:row];
    
    return tagItem.name;
}

#pragma mark Restore data for UI

- (NSDate *)selectedAlarmTime
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

- (void)setSelectedAlarmTime:(NSDate *)selectedAlarmTime
{
    if (selectedAlarmTime == nil)
    {
        selectedAlarmTime = [NSDate date];
    }
    
    NSCalendarUnit units = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute);
    
    NSDateComponents *nowDateComponents = [[NSCalendar currentCalendar] components:units fromDate:selectedAlarmTime];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    components.year = nowDateComponents.year;
    components.month = nowDateComponents.month;
    components.day = nowDateComponents.day;
    components.hour = nowDateComponents.hour;
    components.minute = (nowDateComponents.minute / 5) * 5;
    components.second = 0;
    
    self.datePicker.date = [[NSCalendar currentCalendar] dateFromComponents:components];
}

- (void)updateUiStateFromData
{
    PZReminderItem *item = self.itemAsReminder;
    
    //title
    self.editTitle.text = item.title;
    
    //priority
    self.prioritySwitch.selectedSegmentIndex = item.priorityType;
    
    //tag
    PZTagItem *tagItem = nil;

    if (self.itemEditMode == PZItemEditModeAdd)
    {
        //new item
        tagItem = self.parentTagItem;
    }
    else
    {
        //edit item
        tagItem = item.refTagItem;
    }
    
    if (tagItem == nil)
    {
        tagItem = [PZModel instance].defaultTagItem;
    }

    NSInteger tagItemIndex = 0;
    
    if (tagItem != nil)
    {
        tagItemIndex = [self indexOfTagItem:tagItem withTagItems:self.tagItems];
    }
    
    [self.tagPicker selectRow:tagItemIndex inComponent:0 animated:NO];

    //alarm date
    if (item.alarmDate == nil)
    {
        self.alarmSwitch.on = NO;
        [self setDatePickerEnabled:NO];
    }
    else
    {
        self.selectedAlarmTime = item.alarmDate;
        self.alarmSwitch.on = YES;
        [self setDatePickerEnabled:YES];
    }
    
    //note
    self.noteEdit.text = item.notes;
}

- (void)updateDataItemWithUiState
{
    PZReminderItem *item = self.itemAsReminder;

    //title
    item.title = self.editTitle.text;

    //priority
    item.priorityType = self.prioritySwitch.selectedSegmentIndex;

    //tag
    NSInteger selectedIndex = [self.tagPicker selectedRowInComponent:0];
    
    item.refTagItem = [self.tagItems objectAtIndex:selectedIndex];
    
    //alarm date
    if (self.alarmSwitch.isOn)
    {
        item.alarmDate = self.selectedAlarmTime;
    }
    else
    {
        item.alarmDate = nil;
    }

    //note
    item.notes = self.noteEdit.text;
}

@end
