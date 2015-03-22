//
//  PZEditViewController.m
//  Reeminders
//
//  Created by Piotr on 20.08.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import "PZEditViewController.h"
#import "PZModel.h"
#import "PZReminderItem.h"
#import "PZTagItem.h"

@interface PZEditViewController ()

@end

@implementation PZEditViewController

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

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

- (void)editCancelWithCompletion:(PZEditCancelCompletionBlock)completionBlock
{
    [self.item rollback];
    
    if (self.events != nil)
    {
        [self.events onItemEditCancel];
    }
    
    [self dismissViewControllerAnimated:YES completion:^
    {
        completionBlock();
    }];
}

- (void)editAcceptWithCompletion:(PZEditAcceptCompletionBlock)completionBlock
{
    if (self.events != nil)
    {
        [self.events onItemEditAccept:self.item];
    }
    
    [self saveItemWithCompletion:^(NSString *error)
    {
        if (error == nil)
        {
            [self dismissViewControllerAnimated:YES completion:^
            {
                completionBlock();
            }];
        }
        else
        {
            NSString *title = @"Can't save";
            
            if (self.itemAsTag != nil)
            {
                title = @"Can't save tag";
            }

            if (self.itemAsReminder != nil)
            {
                title = @"Can't save reminder";
            }

            NSString *message = error;
            
            [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
}

- (NSString *)itemEditModeText
{
    if (self.itemEditMode == PZItemEditModeAdd)
    {
        return @"New";
    }

    if (self.itemEditMode == PZItemEditModeUpdate)
    {
        return @"Edit";
    }
    
    return @"";
}

- (PZReminderItem *)itemAsReminder
{
    if ([self.item isKindOfClass:PZReminderItem.class])
    {
        return (PZReminderItem *)self.item;
    }
    
    return nil;
}

- (PZTagItem *)itemAsTag
{
    if ([self.item isKindOfClass:PZTagItem.class])
    {
        return (PZTagItem *)self.item;
    }
    
    return nil;
}

- (void)updateUiStateFromData
{
    
}

- (void)updateDataItemWithUiState
{
    
}

- (NSInteger)indexOfTagItem:(PZTagItem *)tagItem withTagItems:(NSArray *)tagItems
{
    NSInteger index = 0;
    
    for (PZTagItem *item in tagItems)
    {
        if ([item.itemUid isEqualToString:tagItem.itemUid])
        {
            return index;
        }
        
        index++;
    }
    
    return -1;
}

- (void)saveItemWithCompletion:(PZEditFinishCompletionBlock)completionBlock
{
    [self updateDataItemWithUiState];
    
    if (self.item == nil)
    {
        NSLog(@"[PZEditViewController] item for edit not set");
        return;
    }
    
    NSString *errorMessage = self.item.validationError;
    
    if (errorMessage == nil)
    {
        [self.item saveItem];
        
        NSError *error = nil;
        
        if ([[PZModel instance].eventStore commit:&error])
        {
            completionBlock(nil);
        }
        else
        {
            NSLog(@"[PZItem] commit error: %@", error);

            completionBlock(error.localizedDescription);
        }

        return;
    }
    else
    {
        [self.item rollback];

        NSLog(@"[PZEditViewController] item:%@ save error:%@", self.item, errorMessage);
        
        completionBlock(errorMessage);
        return;
    }
}

@end
