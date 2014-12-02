//
//  PGMenuViewController.m
//  CarGuard
//
//  Created by Stan on 11/17/14.
//  Copyright (c) 2014 PubGeek. All rights reserved.
//

#import "PGMenuViewController.h"
#import "PGService.h"
#import "PGMapViewController.h"
#import "PGFunction.h"

#import "IIViewDeckController.h"
#import "UIImageView+WebCache.h"
#import "User.h"

@interface PGMenuViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) NSArray *menuArray;

@end

@implementation PGMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _menuArray = @[@"UserInfo", @"Map", @"Message", @"Map", @"Logout", @"Setting"];
    [self.tableView setTableFooterView:[UIView new]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UITableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellID = [NSString stringWithFormat:@"c%ld", (long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!indexPath.row) {
        UILabel *name = (UILabel *)[cell viewWithTag:1001];
        UIImageView *avatar = (UIImageView *)[cell viewWithTag:1000];
        [[PGFunction function] initRoundViews:@[avatar]];
        
        User *user = [User MR_findFirst];
        name.text = user.username;
        [avatar sd_setImageWithURL:[NSURL URLWithString:user.avatar]];
        
    } else if (indexPath.row == 2) {
        UILabel *new = (UILabel *)[cell viewWithTag:1001];
        new.hidden = ![UIApplication sharedApplication].applicationIconBadgeNumber;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_menuArray count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    
    return cell.frame.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.viewDeckController.closeSlideAnimationDuration = 0.3f;
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    if (indexPath.row < 4) {
        [self.viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller) {
            
            UINavigationController *navController = [mainStoryboard instantiateViewControllerWithIdentifier:_menuArray[indexPath.row]];
            
            self.viewDeckController.centerController = navController;
            if (indexPath.row == 3) {
                PGMapViewController *vc = navController.viewControllers[0];
                vc.type = 1;
            }
        }];
    } else if (indexPath.row == 4) {
        [[PGService service] logoutComplete:^{
            [self performSegueWithIdentifier:@"loginSegue" sender:self];
        }];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
