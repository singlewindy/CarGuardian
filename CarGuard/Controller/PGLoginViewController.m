//
//  ViewController.m
//  CarGuard
//
//  Created by Stan on 11/9/14.
//  Copyright (c) 2014 PubGeek. All rights reserved.
//

#import "PGLoginViewController.h"
#import "PGFunction.h"
#import "PGService.h"
#import "PGAppDelegate.h"

#import "SVProgressHUD.h"

@interface PGLoginViewController ()

@property (weak, nonatomic) IBOutlet UIView *emailView;
@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UIButton *btnRegister;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation PGLoginViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[PGFunction function] initCornerOfViews:@[self.emailView, self.passwordView, self.btnRegister, self.btnLogin]];
    [[PGFunction function] initBorderOfViews:@[self.emailView, self.passwordView]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Events

- (IBAction)btnLoginTapped:(id)sender {
    NSString *username = _usernameTextField.text;
    NSString *password = _passwordTextField.text;
    
    if ([username length] && [password length]) {
        PGAppDelegate *delegate = (PGAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        [SVProgressHUD showWithStatus:@"登录中"];
        
        [delegate.service loginWithUserName:_usernameTextField.text password:_passwordTextField.text  success:^{
            
            [SVProgressHUD showSuccessWithStatus:@"登录成功"];
            [self presentViewController:delegate.viewDeckController animated:YES completion:nil];
            
        } failed:^(NSString *error) {
            [SVProgressHUD showErrorWithStatus:error];
        }];
    } else {
        [self showAlertViewWithMessage:@"信息输入不完整，请重新输入！"];
    }
}


#pragma mark - Helper Functions

- (void)showAlertViewWithMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}



@end
