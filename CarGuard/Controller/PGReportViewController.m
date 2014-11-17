//
//  PGReportViewController.m
//  CarGuard
//
//  Created by Stan on 11/16/14.
//  Copyright (c) 2014 PubGeek. All rights reserved.
//

#import "PGReportViewController.h"
#import "SZTextView.h"
#import "PGGlobal.h"
#import "PGService.h"

#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import "SVProgressHUD.h"

@interface PGReportViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, MAMapViewDelegate, AMapSearchDelegate> {
    MAMapView *_mapView;
}


@property (strong, nonatomic) IBOutlet SZTextView *textView;
@property (nonatomic) UIImage *photo;
@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic) CGFloat latitude;
@property (nonatomic) CGFloat longitude;
@property (nonatomic) NSString *address;
@property (strong, nonatomic) IBOutlet UILabel *labelCurrentAddr;

@end

@implementation PGReportViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    self.search.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    _mapView.delegate = nil;
    self.search.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.textView.placeholder = @"想说点什么？";
    [self.textView becomeFirstResponder];
    
    [self.tableView setTableFooterView:[UIView new]];
    
    _mapView = [[MAMapView alloc] init];
    
    _mapView.showsUserLocation = YES;//开始定位
    self.search = [[AMapSearchAPI alloc] initWithSearchKey:AMAP_API_KEY Delegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Events

- (IBAction)btnAddPhotoTapped:(id)sender {
    [self takePhoto];
}

- (IBAction)btnSubmitTapped:(id)sender {
    
    [SVProgressHUD showWithStatus:@"上报中"];
    
    [[PGService service] reportWithLatitude:self.latitude longtitude:self.longitude address:self.address photo:self.photo success:^{
        [SVProgressHUD showSuccessWithStatus:@"上报成功！"];
        [self.navigationController popViewControllerAnimated:YES];
    } failed:^(NSString *error) {
        [SVProgressHUD showSuccessWithStatus:@"上报失败，请重试！"];
    }];
}

#pragma mark - TableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1.f;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:^{
        self.photo = [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImageView *imageView = (UIImageView *)[self.tableView viewWithTag:100];
        imageView.image = self.photo;
        [self.tableView reloadData];
    }];
}

#pragma mark - Helper Functions

- (void)takePhoto {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    
    // image picker needs a delegate,
    [imagePickerController setDelegate:self];
    
    // Place image picker on the screen
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)searchReGeocodeWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude
{
    AMapReGeocodeSearchRequest *regeoRequest = [[AMapReGeocodeSearchRequest alloc] init];
    regeoRequest.searchType = AMapSearchType_ReGeocode;
    regeoRequest.location = [AMapGeoPoint locationWithLatitude:latitude longitude:longitude];
    regeoRequest.radius = 1000;
    regeoRequest.requireExtension = YES;
    [self.search AMapReGoecodeSearch: regeoRequest];
}

#pragma mark - 地图模块 Delegate

- (void)mapView:(MAMapView*)mapView didUpdateUserLocation:(MAUserLocation*)userLocation updatingLocation:(BOOL)updatingLocation
{
    if (userLocation != nil) {
        NSLog(@"%f %f", userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
        _mapView.showsUserLocation = NO;//关闭定位
        
        self.latitude = userLocation.location.coordinate.latitude;
        self.longitude = userLocation.location.coordinate.longitude;
        
        [self searchReGeocodeWithLatitude:self.latitude longitude:self.longitude];
    }
}

-(void)mapView:(MAMapView*)mapView didFailToLocateUserWithError:(NSError*)error
{
    NSLog(@"location error");
}

- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    AMapPOI *currentPoi = [response.regeocode.pois firstObject];
    self.address = currentPoi.name;
    
    self.labelCurrentAddr.text = self.address;
    [self.tableView reloadData];
    
    NSLog(@"ReGeo: %@", self.address);
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
