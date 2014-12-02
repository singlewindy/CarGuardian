//
//  PGEditInfoViewController.m
//  CarGuard
//
//  Created by Stan on 12/1/14.
//  Copyright (c) 2014 PubGeek. All rights reserved.
//

#import "PGEditInfoViewController.h"
#import "PGService.h"
#import "PGFunction.h"
#import "User.h"

#import "SVProgressHUD.h"

@interface PGEditInfoViewController ()

@property (strong, nonatomic) IBOutlet UILabel *labelKey;
@property (strong, nonatomic) IBOutlet UITextField *valueTextField;

@property (nonatomic) User *user;

@end

@implementation PGEditInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.user = [User MR_findFirst];
    self.valueTextField.text = self.user.username;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Events

- (IBAction)btnSubmitTapped:(id)sender {
    
    [SVProgressHUD showWithStatus:@"提交中"];
    
    [[PGService service] updateUserInfoForKey:@"username" value:self.valueTextField.text success:^{
        self.user.username = self.valueTextField.text;
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        
        [SVProgressHUD showSuccessWithStatus:@"修改成功"];
        [self.navigationController popViewControllerAnimated:YES];
    } failed:^(NSString *error) {
        [[PGFunction function] showAlertViewWithMessage:error];
    }];
}

@end
