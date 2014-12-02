//
//  PGUserInfoViewController.m
//  CarGuard
//
//  Created by Stan on 12/1/14.
//  Copyright (c) 2014 PubGeek. All rights reserved.
//

#import "PGUserInfoViewController.h"
#import "PGService.h"
#import "PGFunction.h"

#import "UIImageView+WebCache.h"
#import "IIViewDeckController.h"
#import "SVProgressHUD.h"
#import "User.h"

@interface PGUserInfoViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *avatarView;
@property (strong, nonatomic) IBOutlet UILabel *nickname;
@property (strong, nonatomic) IBOutlet UILabel *sex;
@property (strong, nonatomic) IBOutlet UILabel *city;

@property (nonatomic) User *user;

@end

@implementation PGUserInfoViewController

- (void)viewWillAppear:(BOOL)animated {
    [self updateUserInfo];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[PGFunction function] initRoundViews:@[self.avatarView]];
    self.user = [User MR_findFirst];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateUserInfo {
    [self.avatarView sd_setImageWithURL:[NSURL URLWithString:self.user.avatar]];
    self.nickname.text = self.user.username;
    self.sex.text = [self.user.sex integerValue] ? @"男" : @"女";
    self.city.text = self.user.city;
}

#pragma mark - UITableView

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!indexPath.section) {
        if (!indexPath.row) {   // 修改头像
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"从相册选择", nil];
            actionSheet.tag = 0;
            [actionSheet showInView:self.view];
        } else if (indexPath.row == 1) {
            [self performSegueWithIdentifier:@"editSegue" sender:nil];
        } else if (indexPath.row == 2) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"男", @"女", nil];
            actionSheet.tag = 1;
            [actionSheet showInView:self.view];
        } else if (indexPath.row == 3) {
            
        }
    }
    
}

#pragma mark - Button Events

- (IBAction)btnMenuTapped:(id)sender {
    [self.viewDeckController openLeftViewAnimated:YES];
}

#pragma mark - IBActionSheet/UIActionSheet Delegate Method

// the delegate method to receive notifications is exactly the same as the one for UIActionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (!actionSheet.tag) {
        if (buttonIndex == 0) {
            UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.delegate = self;
            [self presentViewController:imagePicker animated:YES completion:nil];
        } else if (buttonIndex == 1) {
            UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.delegate = self;
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
    } else if (actionSheet.tag == 1) {
        NSNumber *value = buttonIndex ? @(0) : @(1);
        [[PGService service] updateUserInfoForKey:@"sex" value:value success:^{
            self.user.sex = value;
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            
            [self updateUserInfo];
        } failed:^(NSString *error) {
            [[PGFunction function] showAlertViewWithMessage:error];
        }];
    }
    
}

#pragma mark -
#pragma mark imagePickerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [SVProgressHUD showWithStatus:@"上传中"];
    
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    
    NSData *photoData = [[PGFunction function] compressImage:originalImage];
    
    [[PGService service] updateAvatarWithPhotoData:photoData success:^{
        [SVProgressHUD showSuccessWithStatus:@"上传成功"];
        [self updateUserInfo];
    } failed:^(NSString *error) {
        [SVProgressHUD showErrorWithStatus:error];
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
