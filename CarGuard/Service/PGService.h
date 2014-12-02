//
//  PGService.h
//  CarGuard
//
//  Created by Stan on 11/9/14.
//  Copyright (c) 2014 PubGeek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppModel.h"

#import <MAMapKit/MAMapKit.h>

typedef void(^SimpleSuccessBlock)();
typedef void(^ObjSuccessBlock)(id data);
typedef void(^SimpleFailedBlock)(NSString *error);


@interface PGService : NSObject <MAMapViewDelegate>

+ (instancetype)service;

@property (nonatomic) NSString *token;
@property (nonatomic) AppModel *appModel;
@property (nonatomic) NSNumber *networkCount;

@property (nonatomic, strong) MAMapView *mapView;

#pragma mark - 帐号模块

//- (void)loginWithDeviceToken:(NSString *)deviceToken
//                     success:(ObjSuccessBlock)success
//                      failed:(SimpleFailedBlock)failed;

- (void)loginWithUserName:(NSString *)username
                 password:(NSString *)password
                  success:(SimpleSuccessBlock)success
                   failed:(SimpleFailedBlock)failed;

- (void)logoutComplete:(SimpleSuccessBlock)complete;

- (void)registerWithUserName:(NSString *)username
                       email:(NSString *)email
                    password:(NSString *)password
                     success:(SimpleSuccessBlock)success
                      failed:(SimpleFailedBlock)failed;

#pragma mark - 用户模块

- (void)updateAvatarWithPhotoData:(NSData *)imageData
                          success:(SimpleSuccessBlock)success
                           failed:(SimpleFailedBlock)failed;

- (void)updateUserInfoForKey:(NSString *)key
                       value:(id)value
                     success:(SimpleSuccessBlock)success
                      failed:(SimpleFailedBlock)failed;

#pragma mark - 地图模块

- (void)reportWithLatitude:(CGFloat)latitude
                longtitude:(CGFloat)longitude
                   address:(NSString *)address
                   message:(NSString *)message
                     photo:(UIImage *)photo
                   success:(SimpleSuccessBlock)success
                    failed:(SimpleFailedBlock)failed;

- (void)getOnOffWithType:(NSUInteger)type
                 success:(SimpleSuccessBlock)success
                  failed:(SimpleFailedBlock)failed;

#pragma mark - 警告模块

- (void)getAlertListOfPage:(NSUInteger)page
                      size:(NSUInteger)size
                   success:(ObjSuccessBlock)success
                    failed:(SimpleFailedBlock)failed;

- (void)getAlertOfAid:(NSNumber *)aid
              success:(ObjSuccessBlock)success
               failed:(SimpleFailedBlock)failed;

- (void)getAllAlertsSuccess:(ObjSuccessBlock)success
                     failed:(SimpleFailedBlock)failed;

#pragma mark - 定位模块

- (void)updateCurrentUserLocationSuccess:(SimpleSuccessBlock)success
                                  Failed:(SimpleFailedBlock)failed;

@end
