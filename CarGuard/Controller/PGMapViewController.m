//
//  PGMapViewController.m
//  CarGuard
//
//  Created by Stan on 11/10/14.
//  Copyright (c) 2014 PubGeek. All rights reserved.
//

#import "PGMapViewController.h"
#import "PGMessageDetailViewController.h"
#import "PGFunction.h"
#import "PGService.h"
#import "PGFunction.h"

#import <MAMapKit/MAMapKit.h>
#import "IIViewDeckController.h"
#import "SVProgressHUD.h"

#import "User.h"
#import "PGAlertVO.h"

#define Rgb2UIColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]

@interface PGMapViewController () <MAMapViewDelegate> {
    MAMapView *_mapView;
    BOOL isSetMapSpan;
}

@property (strong, nonatomic) IBOutlet UIView *mapBgView;
@property (strong, nonatomic) IBOutlet UIView *onOffBtnView;
@property (strong, nonatomic) IBOutlet UIView *reportBtnView;
@property (strong, nonatomic) IBOutlet UILabel *labelOnOff;
@property (strong, nonatomic) IBOutlet UIButton *btnOnOff;
@property (strong, nonatomic) IBOutlet UIButton *btnReport;

@property (nonatomic) NSMutableArray *annotations;

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
    
    if (self.data || self.type) {
        if (!self.type) {
            [self.navigationItem setLeftBarButtonItem:nil];
        }
        self.navigationItem.title = self.type ? @"警情地图" : @"地图详情";
        self.onOffBtnView.hidden = YES;
        self.reportBtnView.hidden = YES;
        
        if (self.type) {
            [[PGService service] getAllAlertsSuccess:^(NSArray *data) {
                self.data = data;
                
                [self initAnnotations];
            } failed:^(NSString *error) {
                [[PGFunction function] showAlertViewWithMessage:error];
            }];
        } else {
            [self initAnnotations];
        }
    }
    
    [self initGetOnOffView];
    
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

- (IBAction)btnGetOnOffTapped:(UIButton *)sender {
    User *user = [User MR_findFirst];
    
    if ([user.isGetOff boolValue]) {
        
        [[PGService service] getOnOffWithType:0 success:^{
            [SVProgressHUD showSuccessWithStatus:@"小哨兵已休息，推送关闭"];
            _onOffBtnView.backgroundColor = [UIColor whiteColor];
            _labelOnOff.textColor = [UIColor blackColor];
            _labelOnOff.text = @"放哨";
            [_btnOnOff setImage:[UIImage imageNamed:@"main_updown"] forState:UIControlStateNormal];
            
        } failed:^(NSString *error) {
            [[PGFunction function] showAlertViewWithMessage:error];
        }];
    } else {
        [[PGService service] getOnOffWithType:1 success:^{
            [SVProgressHUD showSuccessWithStatus:@"小哨兵已上岗，推送开启"];
            _onOffBtnView.backgroundColor = Rgb2UIColor(56, 168, 124);
            _labelOnOff.textColor = [UIColor whiteColor];
            _labelOnOff.text = @"休息";
            [_btnOnOff setImage:[UIImage imageNamed:@"main_updown_hl"] forState:UIControlStateNormal];
            
        } failed:^(NSString *error) {
            [[PGFunction function] showAlertViewWithMessage:error];
        }];
        
        [sender setSelected:YES];
        
    }
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

- (void)initGetOnOffView {
    User *user = [User MR_findFirst];
    
    if ([user.isGetOff boolValue]) {
        _onOffBtnView.backgroundColor = Rgb2UIColor(56, 168, 124);
        _labelOnOff.textColor = [UIColor whiteColor];
        _labelOnOff.text = @"休息";
        [_btnOnOff setImage:[UIImage imageNamed:@"main_updown_hl"] forState:UIControlStateNormal];
    } else {
        _onOffBtnView.backgroundColor = [UIColor whiteColor];
        _labelOnOff.textColor = [UIColor blackColor];
        _labelOnOff.text = @"放哨";
        [_btnOnOff setImage:[UIImage imageNamed:@"main_updown"] forState:UIControlStateNormal];
    }
}

- (void)initAnnotations
{
    self.annotations = [NSMutableArray array];
    
    [self.data enumerateObjectsUsingBlock:^(PGAlertVO *obj, NSUInteger idx, BOOL *stop) {
        MAPointAnnotation *point = [[MAPointAnnotation alloc] init];
        point.coordinate = CLLocationCoordinate2DMake(obj.latitude, obj.longitude);
        point.title  = obj.address;
        [self.annotations addObject:point];
    }];

    //添加annotations数组中的标注到地图上
    
    [_mapView addAnnotations: self.annotations];
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

-(MAAnnotationView*)mapView:(MAMapView *)mapView viewForAnnotation:(id)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
        MAPinAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
            annotationView.canShowCallout= YES;      //设置气泡可以弹出，默认为NO
            annotationView.animatesDrop = YES;       //设置标注动画显示，默认为NO
            annotationView.draggable = YES;           //设置标注可以拖动，默认为NO
            annotationView.rightCalloutAccessoryView=[UIButton buttonWithType:UIButtonTypeDetailDisclosure];  //设置气泡右侧按钮
        }
        annotationView.pinColor = MAPinAnnotationColorRed;
        return annotationView;
    }
    return nil;
}

- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id <MAOverlay>)overlay
{
    return nil;
}

- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
//    [self performSegueWithIdentifier:@"DetailsIphone" sender:view];
    NSUInteger index = [self.annotations indexOfObject:view.annotation];
    [self performSegueWithIdentifier:@"detailSegue" sender:self.data[index]];
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
