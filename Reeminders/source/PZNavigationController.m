//
//  PZNavigationController.m
//  Reeminders
//
//  Created by Piotr on 27.07.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import "PZNavigationController.h"
#import "PZAlarmSelectorView.h"

@interface PZNavigationController ()

@property (readonly) PZAlarmSelectorView *alarmSelectorView;

@end

@implementation PZNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self->_alarmSelectorView = [PZAlarmSelectorView instanceWithViewController:self];
    
    [self.alarmSelectorView addToParentView:self.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

@end
