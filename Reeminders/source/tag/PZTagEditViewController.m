//
//  PZTagEditViewController.m
//  Reeminders
//
//  Created by Piotr on 16.08.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import "PZTagEditViewController.h"
#import "PZTagItem.h"
#import "PZColors.h"

@interface PZTagEditViewController ()

@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UITextField *editName;

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIButton *btnColor1;
@property (weak, nonatomic) IBOutlet UIButton *btnColor2;
@property (weak, nonatomic) IBOutlet UIButton *btnColor3;
@property (weak, nonatomic) IBOutlet UIButton *btnColor4;
@property (weak, nonatomic) IBOutlet UIButton *btnColor5;
@property (weak, nonatomic) IBOutlet UIButton *btnColor6;
@property (weak, nonatomic) IBOutlet UIButton *btnColor7;

@property NSArray *colorButtons;

@property UIColor *selectedColor;

@property NSInteger selectedButtonIndex;

@end

@implementation PZTagEditViewController

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

    //setup color buttons
    self.colorButtons = @
    [
        self.btnColor1,
        self.btnColor2,
        self.btnColor3,
        self.btnColor4,
        self.btnColor5,
        self.btnColor6,
        self.btnColor7,
    ];
    
    [self setupColorButtons];

    [self updateUiStateFromData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
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

#pragma mark Color buttons

- (void)setupColorButtons
{
    NSInteger colorIndex = 0;
    
    NSArray *calendarColors = [PZColors instance].defaultCalendarColors;
    
    for (UIButton *button in self.colorButtons)
    {
        [self setupButton:button withColor:calendarColors[colorIndex]];
        
        colorIndex++;
    }
    
    //set default color
    [self selectColorButton:self.btnColor1];
}

- (void)setupButton:(UIButton *)button withColor:(UIColor *)color
{
    button.backgroundColor = color;

    button.layer.cornerRadius = 0;
    
    button.layer.borderWidth = 6;
    button.layer.borderColor = self.contentView.backgroundColor.CGColor;
}

- (void)selectColorButton:(UIButton *)selectedButton
{
    //clear colors to default
    for (UIButton *button in self.colorButtons)
    {
        button.layer.cornerRadius = 0;
        button.layer.borderColor = self.contentView.backgroundColor.CGColor;
        button.tag = 0;
    }

    //set selected button color
    selectedButton.layer.cornerRadius = 8;
    selectedButton.layer.borderColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5].CGColor;
    selectedButton.tag = 1;
}

- (NSInteger)selectedButtonIndex
{
    NSInteger buttonIndex = 0;

    for (UIButton *button in self.colorButtons)
    {
        if (button.tag == 1)
        {
            return buttonIndex;
        }
        
        buttonIndex++;
    }

    return 0;
}

- (void)setSelectedButtonIndex:(NSInteger)selectedButtonIndex
{
    UIButton *button = self.colorButtons[selectedButtonIndex];
    
    [self selectColorButton:button];
}

- (IBAction)onColorButtonTap:(id)sender
{
    UIButton *button = sender;
    
    [self selectColorButton:button];
}

- (UIColor *)selectedColor
{
    NSArray *calendarColors = [PZColors instance].defaultCalendarColors;
    
    NSInteger buttonIndex = [self selectedButtonIndex];
    
    return calendarColors[buttonIndex];
}

- (void)setSelectedColor:(UIColor *)selectedColor
{
    NSArray *calendarColors = [PZColors instance].defaultCalendarColors;

    for (int colorIndex = 0; colorIndex < calendarColors.count; colorIndex++)
    {
        UIColor *calendarColor = calendarColors[colorIndex];
        
        CGFloat difference = [[PZColors instance] averageDifferenceOfColor:calendarColor withColor:selectedColor];
        
        if (difference < 0.01f)
        {
            self.selectedButtonIndex = colorIndex;
            return;
        }
    }
}

#pragma mark Properties

- (NSString *)itemEditModeText
{
    return [NSString stringWithFormat:@"%@ tag", [super itemEditModeText]];
}

- (void)resignFirstResponderFromAllPages
{
    [self.editName resignFirstResponder];
}

- (void)becomeFirstResponderOnActivePage
{
    [self.editName becomeFirstResponder];
}

#pragma mark Restore data for UI

- (void)updateUiStateFromData
{
    PZTagItem *item = self.itemAsTag;
    
    self.editName.text = item.name;

    self.selectedColor = item.color;

    //default tag
    if (self.itemEditMode == PZItemEditModeAdd)
    {
        //new item
        PZTagItem *defaultTagItem = [PZModel instance].defaultTagItem;
        
        if (defaultTagItem != nil)
        {
            self.selectedColor = defaultTagItem.color;
        }
    }
}

- (void)updateDataItemWithUiState
{
    PZTagItem *item = self.itemAsTag;
    
    item.name = self.editName.text;

    item.color = self.selectedColor;
}

@end
