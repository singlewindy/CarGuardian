//
//  PGMapViewController.m
//  CarGuard
//
//  Created by Stan on 11/10/14.
//  Copyright (c) 2014 PubGeek. All rights reserved.
//

#import "PGMapViewController.h"
#import "PGFunction.h"
#import "PGService.h"

#import <MAMapKit/MAMapKit.h>
#import "IIViewDeckController.h"

@interface PGMapViewController () <MAMapViewDelegate> {
    MAMapView *_mapView;
    BOOL isSetMapSpan;
}

@property (strong, nonatomic) IBOutlet UIView *mapBgView;
@property (strong, nonatomic) IBOutlet UIView *onOffBtnView;
@property (strong, nonatomic) IBOutlet UIView *reportBtnView;

@end

@implementation PGMapViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _mapView.delegate = nil; // 此处记得不用的时候需要置nil，否则影响内存的释放
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _mapView = [[MAMapView alloc] initWithFrame:self.mapBgView.frame];
    [_mapView setCustomizeUserLocationAccuracyCircleRepresentation:YES];
    _mapView.compassOrigin= CGPointMake(_mapView.frame.size.width - 50, 30);
    _mapView.scaleOrigin = CGPointMake(10, 30);

    [self.mapBgView addSubview:_mapView];
    
    [@[_reportBtnView, _onOffBtnView] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        view.layer.cornerRadius = 7;
        view.layer.borderColor = [UIColor blackColor].CGColor;
        view.layer.borderWidth = 0.2f;
        view.layer.masksToBounds = YES;
    }];
    
    [self startLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Events

- (IBAction)btnReportTapped:(id)sender {
    [self performSegueWithIdentifier:@"reportSegue" sender:self];
}

- (IBAction)btnMenuTapped:(id)sender {
    [self.viewDeckController openLeftViewAnimated:YES];
}

#pragma mark - Helper Functions

//普通态
-(IBAction)startLocation
{
    NSLog(@"Start Location!");
    
    _mapView.showsUserLocation = NO;//先关闭显示的定位图层
    [_mapView setUserTrackingMode:MAUserTrackingModeFollowWithHeading animated:YES];
    _mapView.showsUserLocation = YES;//显示定位图层
}


#pragma mark - Delegate

-(void)mapView:(MAMapView*)mapView didUpdateUserLocation:(MAUserLocation*)userLocation
updatingLocation:(BOOL)updatingLocation {
    if (!isSetMapSpan) {
        MACoordinateRegion region = MACoordinateRegionMake(CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude), MACoordinateSpanMake(0.01, 0.01));
        [_mapView setRegion:region animated:YES];
        isSetMapSpan = YES;
    }
    
}

-(void)mapView:(MAMapView*)mapView didFailToLocateUserWithError:(NSError*)error {
    NSLog(@"%@", error.description);
}

- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id <MAOverlay>)overlay
{
    return nil;
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
