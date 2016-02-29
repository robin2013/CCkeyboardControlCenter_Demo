//
//  ViewController.m
//  KeyboardCenter
//
//  Created by cuiRobim on 16/2/26.
//  Copyright © 2016年 cuiRobin. All rights reserved.
//

#import "ViewController.h"
#import "CCKeyboardControlCenter.h"
@interface ViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtField0;

@property (weak, nonatomic) IBOutlet UITextField *txtField1;

@property (weak, nonatomic) IBOutlet UITextField *txtField2;

@property (weak, nonatomic) IBOutlet UITextField *txtField3;
@property (strong, nonatomic)CCKeyboardControlCenter *center;;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.center = [CCKeyboardControlCenter controlCenterWithFields:@[self.txtField0,self.txtField1,self.txtField2,self.txtField3] inLocationView:self.view];
    self.center.offset = 20;
    [self createInputAccessView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self.center focusOnView:textField];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (![self.center moveToNextField]) {
        [textField resignFirstResponder];
        [self.center restoreLocationView];
    }
    return    YES;
}
- (void)createInputAccessView {
  UIView *view =  [self.center createInputAccessoryViewWithItems:@[
                                                                  [ self.center buttonCancel],
                                                                  [self.center flexibleSpace],
                                                                  [self.center buttonPrevious],
                                                                  [self.center flexibleSpace],
                                                                  [self.center buttonNext],
                                                                 [ self.center flexibleSpace],
                   [self.center buttonDone]
                                                                   ]];
    
    self.txtField0.inputAccessoryView = view;
    self.txtField1.inputAccessoryView = view;
    self.txtField2.inputAccessoryView = view;
    self.txtField3.inputAccessoryView = view;

}
@end
