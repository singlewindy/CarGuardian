//
//  PGMessageViewController.m
//  CarGuard
//
//  Created by Stan on 11/17/14.
//  Copyright (c) 2014 PubGeek. All rights reserved.
//

#import "PGMessageViewController.h"
#import "PGMessageDetailViewController.h"
#import "PGService.h"
#import "PGFunction.h"

#import "PGAlertVO.h"

#import "IIViewDeckController.h"
#import "MJRefresh.h"
#import "NSDate+NVTimeAgo.h"
#import "APService.h"

@interface PGMessageViewController ()

@property (nonatomic) NSMutableArray *data;
@property (nonatomic) NSUInteger page;

@end

@implementation PGMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([UIApplication sharedApplication].applicationIconBadgeNumber) {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        [APService resetBadge];
    }
    
    [self.tableView addHeaderWithTarget:self action:@selector(pullToRefreshTriggered)];
    [self.tableView addFooterWithTarget:self action:@selector(bottomPullToRefreshTriggered)];
    [self.tableView headerBeginRefreshing];
    [self.tableView setTableFooterView:[UIView new]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"c0"];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1000];
    UILabel *name = (UILabel *)[cell viewWithTag:1001];
    UILabel *detail = (UILabel *)[cell viewWithTag:1002];
    UILabel *time = (UILabel *)[cell viewWithTag:1003];
    
    PGAlertVO *avo = _data[indexPath.row];
    name.text = avo.username;
    detail.text = [NSString stringWithFormat:@"在距您%.2fkm的%@被开了罚单", avo.distance, avo.address];
    time.text = [avo.time formattedAsTimeAgo];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_data count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self performSegueWithIdentifier:@"detailSegue" sender:_data[indexPath.row]];
}

#pragma mark - Button Events

- (IBAction)btnMenuTapped:(id)sender {
    [self.viewDeckController openLeftViewAnimated:YES];
}

#pragma mark - Helper Functions

- (void)pullToRefreshTriggered {
    _page = 1;
    
    [[PGService service] getAlertListOfPage:_page size:20 success:^(NSArray *data) {
        _data = [data mutableCopy];
        [self.tableView reloadData];
        [self.tableView headerEndRefreshing];
    } failed:^(NSString *error) {
        [[PGFunction function] showAlertViewWithMessage:error];
        [self.tableView headerEndRefreshing];
    }];
}

- (void)bottomPullToRefreshTriggered {
    _page += 1;
    
    [[PGService service] getAlertListOfPage:_page size:20 success:^(NSArray *data) {
        [_data addObjectsFromArray:data];
        [self.tableView reloadData];
        [self.tableView footerEndRefreshing];
    } failed:^(NSString *error) {
        [[PGFunction function] showAlertViewWithMessage:error];
        [self.tableView footerEndRefreshing];
    }];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"detailSegue"]) {
        PGMessageDetailViewController *vc = [segue destinationViewController];
        vc.data = sender;
    }
}


@end
