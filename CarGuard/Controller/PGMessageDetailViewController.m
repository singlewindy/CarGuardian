//
//  PGMessageDetailViewController.m
//  CarGuard
//
//  Created by Stan on 11/22/14.
//  Copyright (c) 2014 PubGeek. All rights reserved.
//

#import "PGMessageDetailViewController.h"
#import "PGMessageDetailCell.h"
#import "PGMapViewController.h"

#import "PGFunction.h"
#import "PGService.h"

@interface PGMessageDetailViewController () <UIViewControllerTransitioningDelegate>

@end

@implementation PGMessageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setAid:(NSNumber *)aid {
    _aid = aid;
    
    [[PGService service] getAlertOfAid:aid success:^(id data) {
        self.data = data;
        [self.tableView reloadData];
    } failed:^(NSString *error) {
        [[PGFunction function] showAlertViewWithMessage:error];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data ? 2 : 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!indexPath.row) {
        PGMessageDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detailCell"];
        cell.data = self.data;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mapCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    
    return indexPath.row ? 44.f : [[PGFunction function] calculateHeightForConfiguredSizingCell:cell tableView:tableView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row) {
        [self performSegueWithIdentifier:@"mapSegue" sender:nil];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    PGMapViewController *vc = [segue destinationViewController];
    vc.data = @[self.data];
}

@end
