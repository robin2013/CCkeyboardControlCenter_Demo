//
//  CCKeyboardControlCenter.m
//  KeyboardCenter
//
//  Created by cuiRobim on 16/2/29.
//  Copyright © 2016年 cuiRobin. All rights reserved.
//

#import "CCKeyboardControlCenter.h"

#import <UIKit/UIKit.h>
@interface CCKeyboardControlCenter()
@property(strong, nonatomic,readwrite) NSArray *fields;
@property(strong, nonatomic,readwrite) UIView *locationView;
@property(assign, nonatomic) CGRect locationViewFrame;

@property(assign, nonatomic) CGRect keyboardEndRect;
@property(assign, nonatomic) CGRect keyboardBeginRect;
@property(assign, nonatomic) NSTimeInterval showAnimationTime;
@property(assign, nonatomic) UIViewAnimationCurve showAnimationCurve;
@property(strong, nonatomic) UIView *viewWaitToAdjust;

- (void)subscribeNotifications;
- (void)unsubscribeNotifications;
- (UITextField *)currentTextField;
- (BOOL)isNeedAdjustView:(UIView *)view;
- (void)adjustRootViewForView:(UIView *)view;
@end
@implementation CCKeyboardControlCenter
+ (instancetype)controlCenterWithFields:(NSArray *)fields inLocationView:(UIView *)view {
    return [[ self alloc] initWithFields:fields inLocationView:view];
}

+ (instancetype)controlCenterWithField:(id)field inLocationView:(UIView *)view {
    NSAssert(field != nil, @"接受管理的UITextFied不能为空");
    return [[self alloc] initWithFields:@[field] inLocationView:view];
}

- (id)initWithFields:(NSArray *)fields inLocationView:(UIView *)view {
    self = [super init];
    if (self) {
        NSAssert(fields != nil, @"接受管理的UITextFied不能为nil");
        NSAssert(view != nil, @"UITextFied的容器视图不能为nil");
        self.keyboardEndRect = CGRectZero;
        self.keyboardBeginRect = CGRectZero;
        
        self.fields = fields;
        self.locationViewFrame = view.frame;
        self.locationView = view;
        self.buttonDisableColor = [UIColor grayColor];
        self.buttonEnableColor = [UIColor whiteColor];
        [self subscribeNotifications];
    }
    return self;
}

- (id) init {
    NSAssert(YES,@"接受管理的UITextFied不能为空");
    return nil;
}

- (void)dealloc {
    [self unsubscribeNotifications];
}
#pragma mark - Subscribe And Unsubscribe
- (void)subscribeNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    [center addObserver:self selector:@selector(keyboardWillBeShown:) name:UIKeyboardWillShowNotification object:nil];
}


- (void)unsubscribeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Change First Responser
- (UITextField *)currentTextField {
    for (UITextField *field in self.fields) {
        if ([field isEditing])
            return field;
    }
    return nil;
}

- (BOOL)canMoveToPreviousField {
    UITextField *current = [self currentTextField];
    if (current) {
        NSInteger index = [self.fields indexOfObject:current];
        if (index!=0) {
            UITextField *previous = [self.fields objectAtIndex:index -1];
            if ([previous canBecomeFirstResponder])
                return YES;
        }
    }
    return NO;
}

- (BOOL)canMoveToNextField {
    UITextField *current = [self currentTextField];
    if (current) {
        NSInteger index = [self.fields indexOfObject:current];
        if (index!=self.fields.count -1 && self.fields.count >1) {
            UITextField *next = [self.fields objectAtIndex:index +1];
            if ([next canBecomeFirstResponder])
                return YES;
        }
    }
    return NO;
}

- (BOOL)moveToPreviousField {
    UITextField *current = [self currentTextField];
    if (current) {
        NSInteger index = [self.fields indexOfObject:current];
        if (index!=0) {
            UITextField *previous = [self.fields objectAtIndex:index -1];
            if ([previous canBecomeFirstResponder]&& [previous becomeFirstResponder])
                [self adjustRootViewForView:previous];
            [self changeButtonStatusForViewAtIndex:[self.fields indexOfObject:previous]];
            
            return YES;
        }
    }
    return NO;
}

- (BOOL)moveToNextField {
    UITextField *current = [self currentTextField];
    if (current) {
        NSInteger index = [self.fields indexOfObject:current];
        if (index!=self.fields.count -1 && self.fields.count >1) {
            UITextField *next = [self.fields objectAtIndex:index +1];
            if ([next canBecomeFirstResponder]&& [next becomeFirstResponder])
                [self adjustRootViewForView:next];
            [self changeButtonStatusForViewAtIndex:[self.fields indexOfObject:next]];
            return YES;
        }
    }
    return NO;
}

- (BOOL)moveToFieldAfter:(UIView*)view {
    if([self.fields containsObject:view]) {
        NSInteger index = [self.fields indexOfObject:view];
        if (index !=self.fields.count-1) {
            UITextField *next = [self.fields objectAtIndex:index +1];
            if ([next canBecomeFirstResponder]) {
                [self adjustRootViewForView:next];
                [self changeButtonStatusForViewAtIndex:[self.fields indexOfObject:next]];
            }
            return [next becomeFirstResponder];
        }
    }
    return NO;
}

- (BOOL)moveToFieldBefore:(UIView*)view {
    if([self.fields containsObject:view]) {
        NSInteger index = [self.fields indexOfObject:view];
        if (index >0) {
            UITextField *previous = [self.fields objectAtIndex:index -1];
            if ([previous canBecomeFirstResponder]) {
                [self adjustRootViewForView:previous];
                [self changeButtonStatusForViewAtIndex:[self.fields indexOfObject:previous]];
            }
            return [previous becomeFirstResponder];
        }
    }
    return NO;
}

#pragma mark - View Position
- (CGRect )unvisbaleRect {
    CGRect coverRect = (CGRect){self.keyboardEndRect.origin.x,
        self.keyboardEndRect.origin.y-self.offset,
        self.keyboardEndRect.size.width,
        self.keyboardEndRect.size.height+self.offset};
    return coverRect;
}

- (CGPoint)bottomPointInScreenOfView:(UIView*)view {
    CGRect frameInScreen = [[self.locationView window] convertRect:view.frame fromView:self.locationView];
    CGPoint bottomPoint = (CGPoint){CGRectGetMidX(frameInScreen),CGRectGetMaxY(frameInScreen)};
    return bottomPoint;
}

- (CGPoint)topPointInScreenOfView:(UIView*)view {
    CGRect frameInScreen = [[self.locationView window] convertRect:view.frame fromView:self.locationView];
    CGPoint topPoint = (CGPoint){CGRectGetMidX(frameInScreen),CGRectGetMinY(frameInScreen)};
    return topPoint;
}


#pragma mark - KeyboardNotification

- (void)keyboardWillBeShown:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    
    self.showAnimationTime = animationDuration;
    self.showAnimationCurve =animationCurve;
    self.keyboardBeginRect =[[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    self.keyboardEndRect =[[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    ;
    if (self.viewWaitToAdjust) {
        [self adjustRootViewForView:self.viewWaitToAdjust];
    }
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    
    self.showAnimationTime = animationDuration;
    self.showAnimationCurve =animationCurve;
    self.keyboardBeginRect =[[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    self.keyboardEndRect =[[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    ;
    
}

#pragma mark - Adjust
- (void)focusOnView:(UIView *)view {
    if (CGRectIsEmpty(self.keyboardEndRect) || CGRectIsEmpty(self.keyboardBeginRect)) {
        self.viewWaitToAdjust = view;
    } else {
        [self adjustRootViewForView:view];
    }
}

- (void)adjustRootViewForView:(UIView *)view {
    if ([self isNeedUponAdjustView:view]) {
        [self uponAdjustRootViewForView:view];
    }else if([self isNeedBelowAdjustView:view]) {
        [self belowAdjustRootViewForView:view];
    }
}

/**
 *  向上适配控件
 *
 *  @param view 需要适配的控件
 */
- (void)uponAdjustRootViewForView:(UIView *)view {
    CGRect unvisbaleRect = [self unvisbaleRect];
    CGPoint bottomPoint = [self bottomPointInScreenOfView:view];
    CGFloat keyboardRange = CGRectGetMinY(self.keyboardBeginRect) - CGRectGetMinY(self.keyboardEndRect);
    
    CGFloat viewRange = bottomPoint.y - CGRectGetMinY(unvisbaleRect);
    NSTimeInterval animationTime =self.viewWaitToAdjust? viewRange/keyboardRange*self.showAnimationTime:self.showAnimationTime;
    
    [self moveView:self.locationView
           toFrame:CGRectOffset(self.locationView.frame, 0, -viewRange)
withAnimationCurve:self.showAnimationCurve
withAnimationDuration:animationTime];
    
    if (self.viewWaitToAdjust) {
        self.viewWaitToAdjust = nil;
    }
}
/**
 *  向下适配控件
 *
 *  @param view 需要适配的控件
 */
- (void)belowAdjustRootViewForView:(UIView *)view {
    CGRect frameInScreen = [[UIScreen mainScreen] bounds];
    CGFloat screenRange = CGRectGetMinY(frameInScreen) - CGRectGetMinY(self.locationView.frame);
    
    [self moveView:self.locationView
           toFrame:CGRectOffset(self.locationView.frame, 0,screenRange)
withAnimationCurve:self.showAnimationCurve
withAnimationDuration:self.showAnimationTime];
    if (self.viewWaitToAdjust) {
        self.viewWaitToAdjust = nil;
    }
}

- (void)moveView:(UIView*)view toFrame:(CGRect)frame
withAnimationCurve:(UIViewAnimationCurve)curve
withAnimationDuration:(NSTimeInterval)duration {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    [view setFrame:frame];
    [UIView commitAnimations];
}

- (BOOL)isNeedAdjustView:(UIView *)view {
    ;
    return [self isNeedBelowAdjustView:view]|| [self isNeedUponAdjustView:view];
}

/**
 *  是否需要向上适配
 *
 *  @param view 需要适配的控件
 *
 *  @return 结果
 */
- (BOOL)isNeedUponAdjustView:(UIView *)view {
    CGRect unvisbaleRect = [self unvisbaleRect];
    CGPoint bottomPoint = [self bottomPointInScreenOfView:view];
    return CGRectContainsPoint(unvisbaleRect, bottomPoint);
}

/**
 *  是否需要向下适配
 *
 *  @param view 需要适配的控件
 *
 *  @return 结果
 */
- (BOOL)isNeedBelowAdjustView:(UIView *)view {
    CGPoint topPoint = [self topPointInScreenOfView:view];
    return topPoint.y<0;
}

- (void)restoreLocationView {
    CGFloat keyboardRange = CGRectGetMaxY(self.keyboardEndRect) - CGRectGetMaxY(self.keyboardBeginRect);
    CGFloat viewRange = CGRectGetMaxY(self.locationViewFrame) - CGRectGetMaxY(self.locationView.frame);
    NSTimeInterval animationTime = viewRange/keyboardRange*self.showAnimationTime;
    
    [self moveView:self.locationView
           toFrame:self.locationViewFrame
withAnimationCurve:self.showAnimationCurve
withAnimationDuration:animationTime];
    self.keyboardBeginRect = CGRectZero;
    self.keyboardEndRect = CGRectZero;
}

#pragma mark - ToolBar
- (UIView *)createInputAccessoryViewWithItems:(NSArray *)items {
    return [self createInputAccessoryViewWithItems:items buttonPrevious:self.btnPrevious    buttonNext:self.btnNext];
}
- (UIView *)createInputAccessoryViewWithItems:(NSArray *)items buttonPrevious:(UIButton *)previous buttonNext:(UIButton *)next {
    NSAssert(items&&items.count, @"Items in toolbar should not be none");
    UIToolbar  *inputAccessoryView = [[UIToolbar alloc] init];
    inputAccessoryView.barStyle = UIBarStyleBlackTranslucent;
    inputAccessoryView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [inputAccessoryView sizeToFit];
    [inputAccessoryView setItems:items];
    self.btnNext = next;
    self.btnPrevious = previous;
    return inputAccessoryView;
}

- (UIButton*)createButtonWithTitle:(NSString *)title action:(SEL)selector colorEnable:(UIColor*)colorEnable colorDisable:(UIColor *)colorDisable {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:colorEnable forState:UIControlStateNormal];
    [btn setTitleColor:colorDisable forState:UIControlStateDisabled];
    [btn sizeToFit];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (UIBarButtonItem*)createBarButtonWithTitle:(NSString *)title action:(SEL)selector colorEnable:(UIColor*)colorEnable colorDisable:(UIColor *)colorDisable {
    UIColor *colEnable = colorEnable?colorEnable:[UIColor whiteColor];
    UIColor *colDisable = colorDisable?colorDisable:[UIColor grayColor];
    UIButton *btn =[self createButtonWithTitle:title action:@selector(moveToPreviousField) colorEnable:colEnable colorDisable:colDisable];
    UIBarButtonItem *barBtn =[[UIBarButtonItem alloc] initWithCustomView:btn];
    return barBtn;
}

- (UIBarButtonItem *)buttonDone {
    UIBarButtonItem *doneBtn =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    
    return doneBtn;
}

- (void)done:(id)sender {
    UITextField *current = [self currentTextField];
    [current resignFirstResponder];
    [self restoreLocationView];
}

- (UIBarButtonItem *)buttonCancel {
    UIBarButtonItem *cancelBtn =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(done:)];
    return cancelBtn;
}

- (UIBarButtonItem *)buttonPrevious {
    UIColor *colorEnable = self.buttonEnableColor?self.buttonEnableColor:[UIColor whiteColor];
    UIColor *colorDisable = self.buttonDisableColor?self.buttonDisableColor:[UIColor grayColor];
    UIButton *btn =[self createButtonWithTitle:@"  <  " action:@selector(moveToPreviousField) colorEnable:colorEnable colorDisable:colorDisable];
    UIBarButtonItem *previousBtn =[[UIBarButtonItem alloc] initWithCustomView:btn];
    self.btnPrevious = btn;
    
    return previousBtn;
}

- (UIBarButtonItem *)buttonNext {
    UIColor *colorEnable = self.buttonEnableColor?self.buttonEnableColor:[UIColor whiteColor];
    UIColor *colorDisable = self.buttonDisableColor?self.buttonDisableColor:[UIColor grayColor];
    
    UIButton *btn =[self createButtonWithTitle:@"  >  " action:@selector(moveToNextField) colorEnable:colorEnable colorDisable:colorDisable];
    
    UIBarButtonItem *nextBtn =[[UIBarButtonItem alloc] initWithCustomView:btn];
    self.btnNext = btn;
    return nextBtn;
}

- (UIBarButtonItem *)flexibleSpace {
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    return flexibleSpace;
}


- (void)changeButtonStatusForViewAtIndex:(NSInteger)index {
    NSInteger count = self.fields.count;
    if (count > 1) {
        if (index == count-1) {
            if (self.btnNext&&[self.btnNext isEnabled]) self.btnNext.enabled = NO;
            if (self.btnPrevious&&![self.btnPrevious isEnabled]) self.btnPrevious.enabled = YES;
        } else if(index == 0) {
            if (self.btnNext&&![self.btnNext isEnabled]) self.btnNext.enabled = YES;
            if (self.btnPrevious&&[self.btnPrevious isEnabled]) self.btnPrevious.enabled = NO;
        } else {
            if (self.btnNext&&![self.btnNext isEnabled]) self.btnNext.enabled = YES;
            if (self.btnPrevious&&![self.btnPrevious isEnabled]) self.btnPrevious.enabled = YES;
        }
    }
}


@end
