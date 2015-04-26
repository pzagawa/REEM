//
//  PZTableViewCell.m
//  REEM
//
//  Created by Piotr Zagawa on 13.11.2014.
//  Copyright (c) 2014 Piotr Zagawa. All rights reserved.
//

#import "PZTableViewCell.h"

//Swipe direction
typedef NS_ENUM(NSInteger, PZCellSwipeDirection)
{
    PZCellSwipeDirectionNone,
    PZCellSwipeDirectionLeft,
    PZCellSwipeDirectionRight,
};

//Swipe state
typedef NS_ENUM(NSInteger, PZCellSwipeState)
{
    PZCellSwipeStateNone,
    PZCellSwipeStateStart,
    PZCellSwipeStateEnd,
    PZCellSwipeStateLock,
    PZCellSwipeStateUnLock,
};

@interface PZTableViewCell ()

@property (readonly, weak) UIPanGestureRecognizer *panGestureRecognizer;

@property (readonly) CGPoint prevTranslation;

@property (readonly) int actionButtonSize;
@property (readonly) CGFloat rightActionButtonsWidth;

@property PZCellSwipeDirection swipeDirection;
@property PZCellSwipeState swipeState;

@property (weak) CALayer *layerEdgeL;
@property (weak) CALayer *layerEdgeR;
@property (weak) CALayer *layerEdgeT;
@property (weak) CALayer *layerEdgeB;

@property BOOL isShadowEnabled;

@property (weak) CALayer *layerLeftActionIcon;

@property NSArray *rightActionButtons;

@property BOOL isLeftActionTriggered;

@end

@implementation PZTableViewCell
{
    PZCellSwipeState _swipeState;
    NSArray *_rightActionButtons;
    UIImage *_leftActionIcon;
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.swipeDirection = PZCellSwipeDirectionNone;
    self.swipeState = PZCellSwipeStateNone;
    
    self.hasLeftSwipeAction = NO;
    self.rightActionButtons = @[];
    
    [self setLeftActionIconLayer];
    
    [self createShadowLayers];
    
    [self setupGestureRecognizers];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

- (void)setupGestureRecognizers
{
    //horizontal pan recognizer
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGesture:)];
    
    panGestureRecognizer.minimumNumberOfTouches = 1;
    panGestureRecognizer.maximumNumberOfTouches = 1;
    
    panGestureRecognizer.delegate = self;
    
    [self.contentView addGestureRecognizer:panGestureRecognizer];
    
    self->_panGestureRecognizer = panGestureRecognizer;
    
    //long press gesture recognizer
    UILongPressGestureRecognizer *longPressTapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressGesture:)];
    
    longPressTapGestureRecognizer.numberOfTouchesRequired = 1;
    
    [self.contentView addGestureRecognizer:longPressTapGestureRecognizer];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)recognizer
{
    if (recognizer == self.panGestureRecognizer)
    {
        CGPoint velocity = [self.panGestureRecognizer velocityInView:self.swipeView];
        
        //detect horizontal panning
        return ABS(velocity.x) > ABS(velocity.y);
    }
    else
    {
        return YES;
    }
}

- (void)onPanGesture:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        self->_prevTranslation.x = 0;
        self->_prevTranslation.y = 0;
        
        self.swipeDirection = PZCellSwipeDirectionNone;

        if (self.swipeState == PZCellSwipeStateNone)
        {
            self.swipeState = PZCellSwipeStateStart;
        }

        if (self.swipeState == PZCellSwipeStateLock)
        {
            self.swipeState = PZCellSwipeStateUnLock;
        }
        
        [self onSwipeStartAction];
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [recognizer translationInView:self];
        
        CGPoint delta;
        
        delta.x = translation.x - self->_prevTranslation.x;
        delta.y = translation.y - self->_prevTranslation.y;
        
        self->_prevTranslation = translation;

        if (self.swipeState == PZCellSwipeStateStart || self.swipeState == PZCellSwipeStateUnLock)
        {
            if (delta.x == 0)
            {
                self.swipeDirection = PZCellSwipeDirectionNone;
            }
            
            if (delta.x < 0)
            {
                self.swipeDirection = PZCellSwipeDirectionLeft;
            }

            if (delta.x > 0)
            {
                self.swipeDirection = PZCellSwipeDirectionRight;
            }
        }
        
        [self processRightSwipeWithOffset:translation.x];
        [self processLeftSwipeWithOffset:translation.x];
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        if (self.swipeState != PZCellSwipeStateLock)
        {
            self.swipeState = PZCellSwipeStateEnd;
        }

        [self scrollSwipeViewBack];
    }
    
    if (recognizer.state == UIGestureRecognizerStateCancelled)
    {
        if (self.swipeState != PZCellSwipeStateLock)
        {
            self.swipeState = PZCellSwipeStateEnd;
        }
        
        [self scrollSwipeViewBack];
    }
}

- (void)onLongPressGesture:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        if (self.delegate != nil)
        {
            [self.delegate onLongPressWithCell:self];
        }
    }
}

- (int)actionButtonSize
{
    return self.contentView.frame.size.height;
}

- (void)processRightSwipeWithOffset:(CGFloat)offset
{
    if (self.swipeDirection == PZCellSwipeDirectionRight)
    {
        if (self.swipeState == PZCellSwipeStateUnLock)
        {
            offset = offset - self.rightActionButtonsWidth;

            if (offset > 0)
            {
                offset = 0;
                
                self.swipeState = PZCellSwipeStateEnd;
            }
            
            self.layConstSwipeViewL.constant = +offset;
            self.layConstSwipeViewR.constant = -offset;
            
            return;
        }

        if (self.hasLeftSwipeAction == NO)
        {
            return;
        }
        
        if (self.swipeState != PZCellSwipeStateEnd)
        {
            float buttonSize = self.actionButtonSize;
            
            if (offset > buttonSize)
            {
                offset = buttonSize;
                
                self.swipeState = PZCellSwipeStateEnd;
                
                self.isLeftActionTriggered = YES;
            }
            
            self.layerLeftActionIcon.opacity = ((float)offset / buttonSize);
            
            self.layConstSwipeViewL.constant = +offset;
            self.layConstSwipeViewR.constant = -offset;
        }
    }
}

- (void)processLeftSwipeWithOffset:(CGFloat)offset
{
    NSArray *actionButtons = [self rightActionButtons];
    
    if (actionButtons.count == 0)
    {
        return;
    }

    if (self.swipeDirection == PZCellSwipeDirectionLeft)
    {
        if (self.swipeState == PZCellSwipeStateUnLock)
        {
            return;
        }

        if (self.swipeState != PZCellSwipeStateLock)
        {
            if (offset < (- self.rightActionButtonsWidth))
            {
                offset = (- self.rightActionButtonsWidth);
                
                self.swipeState = PZCellSwipeStateLock;
                
                [self onSwipeLeftLock];
            }
            
            self.layConstSwipeViewL.constant = +offset;
            self.layConstSwipeViewR.constant = -offset;
        }
    }
}

- (void)scrollSwipeViewBack
{
    if (self.swipeState != PZCellSwipeStateEnd)
    {
        return;
    }
    
    if (self.swipeState == PZCellSwipeStateLock)
    {
        return;
    }
    
    self.layConstSwipeViewL.constant = 0;
    self.layConstSwipeViewR.constant = 0;
    
    [UIView animateWithDuration:0.25 animations:^
    {
        [self.contentView layoutIfNeeded];
    }
    completion:^(BOOL finished)
    {
        self.swipeState = PZCellSwipeStateNone;
    }];
}

- (void)setScrollSwipeViewBack
{
    self.swipeState = PZCellSwipeStateEnd;

    [self scrollSwipeViewBack];
}

- (CGFloat)rightActionButtonsWidth
{
    NSArray *actionButtons = [self rightActionButtons];

    return (self.actionButtonSize * actionButtons.count);
}

- (void)createShadowLayers
{
    CALayer *layerEdgeL = [CALayer layer];
    CALayer *layerEdgeR = [CALayer layer];
    CALayer *layerEdgeT = [CALayer layer];
    CALayer *layerEdgeB = [CALayer layer];

    [self.contentView.layer addSublayer:layerEdgeL];
    [self.contentView.layer addSublayer:layerEdgeR];
    [self.contentView.layer addSublayer:layerEdgeT];
    [self.contentView.layer addSublayer:layerEdgeB];

    self.layerEdgeL = layerEdgeL;
    self.layerEdgeR = layerEdgeR;
    self.layerEdgeT = layerEdgeT;
    self.layerEdgeB = layerEdgeB;
}

- (void)updateShadowLayers
{
    CGFloat edge = 24;

    CGRect rect = self.contentView.bounds;

    [CATransaction begin];
    [CATransaction setDisableActions:YES];

    self.layerEdgeL.frame = CGRectMake(-edge, 0, edge, rect.size.height);
    self.layerEdgeR.frame = CGRectMake(rect.size.width, 0, edge, rect.size.height);
    self.layerEdgeT.frame = CGRectMake(0, -edge, rect.size.width, edge);
    self.layerEdgeB.frame = CGRectMake(0, rect.size.height, rect.size.width, edge);

    [CATransaction commit];
}

- (void)setShadowEnabled:(BOOL)enabled
{
    if (enabled)
    {
        if (self.isShadowEnabled)
        {
            return;
        }
        
        self.isShadowEnabled = YES;

        [self updateShadowLayers];

        [self setShadowToLayer:self.layerEdgeL];
        [self setShadowToLayer:self.layerEdgeR];
        [self setShadowToLayer:self.layerEdgeT];
        [self setShadowToLayer:self.layerEdgeB];
        
        //set shadow to swipe view layer
        self.swipeView.layer.masksToBounds = NO;
        self.swipeView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.swipeView.layer.shadowOffset = CGSizeMake(0, 0);
        self.swipeView.layer.shadowOpacity = 0.1f;
        self.swipeView.layer.shadowRadius = 4;
    }
    else
    {
        if (self.isShadowEnabled == NO)
        {
            return;
        }

        self.isShadowEnabled = NO;

        [self removeShadowFromLayer:self.layerEdgeL];
        [self removeShadowFromLayer:self.layerEdgeR];
        [self removeShadowFromLayer:self.layerEdgeT];
        [self removeShadowFromLayer:self.layerEdgeB];

        //set shadow to swipe view layer
        self.swipeView.layer.shadowColor = nil;
        self.swipeView.layer.shadowOpacity = 0.0f;
        self.swipeView.layer.shadowRadius = 0;
    }
}

- (void)setShadowToLayer:(CALayer *)layer
{
    layer.backgroundColor = [UIColor blackColor].CGColor;
    layer.masksToBounds = NO;
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOffset = CGSizeMake(0, 0);
    layer.shadowOpacity = 0.1f;
    layer.shadowRadius = 4;
    layer.zPosition = -1;
}

- (void)removeShadowFromLayer:(CALayer *)layer
{
    layer.shadowColor = nil;
    layer.shadowOpacity = 0.0f;
    layer.shadowRadius = 0;
}

- (void)setLeftActionIconLayer
{
    CALayer *iconLayer = [CALayer layer];

    iconLayer.contentsScale = self.contentView.layer.contentsScale;
    
    iconLayer.zPosition = -1;
    
    iconLayer.opacity = 0.5f;
    
    [self.contentView.layer addSublayer:iconLayer];
    
    self.layerLeftActionIcon = iconLayer;
    self.layerLeftActionIcon.opacity = 0;
}

- (UIImage *)leftActionIcon
{
    return self->_leftActionIcon;
}

- (void)setLeftActionIcon:(UIImage *)leftActionIcon
{
    self->_leftActionIcon = leftActionIcon;
    
    self.layerLeftActionIcon.contents = (__bridge id)self.leftActionIcon.CGImage;
    
    self.layerLeftActionIcon.frame = CGRectMake(0, 0, self.leftActionIcon.size.width, self.leftActionIcon.size.height);
}

- (PZCellSwipeState)swipeState
{
    @synchronized(self)
    {
        return self->_swipeState;
    }
}

- (void)setSwipeState:(PZCellSwipeState)swipeState
{
    @synchronized(self)
    {
        self->_swipeState = swipeState;

        if (swipeState == PZCellSwipeStateNone)
        {
            [self setShadowEnabled:NO];

            self.layerLeftActionIcon.opacity = 0;
            
            self.rightActionButtons = @[];
            
            if (self.isLeftActionTriggered)
            {
                self.isLeftActionTriggered = NO;
                
                [self onSwipeRightAction];
            }
        }
        else
        {
            [self setShadowEnabled:YES];

            if (swipeState == PZCellSwipeStateStart)
            {
                if (self.delegate != nil)
                {
                    self.rightActionButtons = [self.delegate rightActionButtonsWithCell:self];
                }
            }
        }
    }
}

#pragma mark Delegate communication

- (void)onSwipeStartAction
{
    NSLog(@"[PZTableViewCell] onSwipeStartAction");
    
    if (self.delegate != nil)
    {
        [self.delegate onSwipeStartActionWithCell:self];
    }
}

- (void)onSwipeRightAction
{
    NSLog(@"[PZTableViewCell] onSwipeRightAction");

    if (self.delegate != nil)
    {
        [self.delegate onSwipeRightActionWithCell:self];
    }
}

- (void)onSwipeLeftLock
{
    NSLog(@"[PZTableViewCell] onSwipeLeftLock");

    if (self.delegate != nil)
    {
        [self.delegate onSwipeLeftLockWithCell:self];
    }
}

#pragma mark Right action buttons management

+ (UIButton *)createCustomButtonWithImageNamed:(NSString *)imageName
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    
    UIImage *image = [UIImage imageNamed:imageName];
    
    [button setTitle:@"" forState:UIControlStateNormal];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    
    return button;
}

- (NSArray *)rightActionButtons
{
    return self->_rightActionButtons;
}

- (void)setRightActionButtons:(NSArray *)rightActionButtons
{
    self->_rightActionButtons = rightActionButtons;

    [self removeButtonsFromContentView];

    [self setButtonsToContentView:self->_rightActionButtons];
}

- (void)removeButtonsFromContentView
{
    NSArray *views = [NSArray arrayWithArray:self.contentView.subviews];
    
    for (UIView *view in views)
    {
        if ([view isKindOfClass:UIButton.class])
        {
            [view removeFromSuperview];
        }
    }
}

- (void)setButtonsToContentView:(NSArray *)buttons
{
    float buttonWidth = self.actionButtonSize;
    float totalWidth = buttonWidth * buttons.count;

    CGRect rect = CGRectMake(self.contentView.bounds.size.width - totalWidth, 0, buttonWidth, self.contentView.bounds.size.height);
    
    for (UIButton *button in buttons)
    {
        button.frame = rect;
        
        rect.origin.x += buttonWidth;
        
        [self.contentView insertSubview:button belowSubview:self.swipeView];
    }
}

@end
