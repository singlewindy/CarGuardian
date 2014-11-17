//
//  ViewController.m
//  CarGuard
//
//  Created by Stan on 11/9/14.
//  Copyright (c) 2014 PubGeek. All rights reserved.
//

#import "PGRegisterViewController.h"
#import "PGFunction.h"
#import "PGService.h"
#import "PGAppDelegate.h"

#import "UIAlertView+Blocks.h"

@interface PGRegisterViewController ()

@property (weak, nonatomic) IBOutlet UIView *usernameView;
@property (weak, nonatomic) IBOutlet UIView *emailView;
@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UIView *repeatPSWView;
@property (weak, nonatomic) IBOutlet UIButton *btnRegister;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *repeatPSWTextField;

@end

@implementation PGRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[PGFunction function] initCornerOfViews:@[self.usernameView, self.emailView, self.passwordView, self.repeatPSWView, self.btnRegister]];
    [[PGFunction function] initBorderOfViews:@[self.usernameView, self.emailView, self.passwordView, self.repeatPSWView]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Events

- (IBAction)btnRegisterTapped:(id)sender {
    NSString *username = _usernameTextField.text;
    NSString *email = _emailTextField.text;
    NSString *password = _passwordTextField.text;
    NSString *repeatPassword = _repeatPSWTextField.text;
    
    if ([username length] && [email length] && [password length] && [repeatPassword length]) {
        if ([password isEqualToString:repeatPassword]) {
            
            PGAppDelegate *delegate = (PGAppDelegate *)[[UIApplication sharedApplication] delegate];
            
            [[PGService service] registerWithUserName:username email:email password:password success:^{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"注册成功！"
                                                                    message:nil
                                                           cancelButtonItem:nil
                                                           otherButtonItems:[RIButtonItem itemWithLabel:@"确定" action:^{
                    [self presentViewController:delegate.viewDeckController animated:YES completion:nil];
                }], nil];
                
                [alertView show];
                
            } failed:^(NSString *error) {
                [self showAlertViewWithMessage:error];
            }];
        } else {
            [self showAlertViewWithMessage:@"密码不一致，请重新输入！"];
        }
    } else {
        [self showAlertViewWithMessage:@"信息不完整，请重新输入！"];
    }
}

#pragma mark - Helper Functions

- (void)showAlertViewWithMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

@end
