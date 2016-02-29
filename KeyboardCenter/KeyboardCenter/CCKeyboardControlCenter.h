//
//  CCKeyboardControlCenter.h
//  KeyboardCenter
//
//  Created by cuiRobim on 16/2/29.
//  Copyright © 2016年 cuiRobin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIView;
@class UIBarButtonItem;
@class UIButton;
@class UIColor;
@interface CCKeyboardControlCenter : NSObject
@property(strong, nonatomic,readonly) NSArray *fields;
@property(assign, nonatomic) double offset;
@property(strong, nonatomic) UIColor * buttonEnableColor;
@property(strong, nonatomic) UIColor * buttonDisableColor;
@property(strong, nonatomic) UIButton * btnNext;
@property(strong, nonatomic) UIButton * btnPrevious;

+ (instancetype)controlCenterWithFields:(NSArray *)fields inLocationView:(UIView *)view;
+ (instancetype)controlCenterWithField:(id)field inLocationView:(UIView *)view;

- (BOOL)canMoveToPreviousField;
- (BOOL)canMoveToNextField;
- (BOOL)moveToPreviousField;
- (BOOL)moveToNextField;
- (BOOL)moveToFieldAfter:(UIView*)view;
- (BOOL)moveToFieldBefore:(UIView*)view;
/**
 *  选中输入框
 *
 *  @param view 输入框
 */
- (void)focusOnView:(UIView *)view;
/**
 *  还原视图
 */
- (void)restoreLocationView;

- (UIView *)createInputAccessoryViewWithItems:(NSArray *)items;
/**
 *  创建键盘工具条
 *
 *  @param items    UIBarButtonItem 数组
 *  @param previous 上一个 按钮
 *  @param next     下一个 按钮
 *
 *  @return 工具条
 */
- (UIView *)createInputAccessoryViewWithItems:(NSArray *)items
                               buttonPrevious:(UIButton *)previous
                                   buttonNext:(UIButton *)next;

- (UIButton*)createButtonWithTitle:(NSString *)title
                            action:(SEL)selector
                       colorEnable:(UIColor*)colorEnable
                      colorDisable:(UIColor *)colorDisable;

- (UIBarButtonItem*)createBarButtonWithTitle:(NSString *)title action:(SEL)selector colorEnable:(UIColor*)colorEnable colorDisable:(UIColor *)colorDisable;

- (UIBarButtonItem *)buttonDone;
- (UIBarButtonItem *)buttonCancel;
- (UIBarButtonItem *)buttonPrevious;
- (UIBarButtonItem *)buttonNext;
- (UIBarButtonItem *)flexibleSpace;
@end
