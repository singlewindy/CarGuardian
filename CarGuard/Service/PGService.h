//
//  PGService.h
//  CarGuard
//
//  Created by Stan on 11/9/14.
//  Copyright (c) 2014 PubGeek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppModel.h"

@interface PGService : NSObject

typedef void(^SimpleSuccessBlock)();
typedef void(^ObjSuccessBlock)(NSObject *data);

typedef void(^SimpleFailedBlock)(NSString *error);

+ (instancetype)service;

@property (nonatomic) NSString *token;
@property (nonatomic) AppModel *appModel;
@property (nonatomic) NSNumber *networkCount;

#pragma mark - 帐号模块

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

#pragma mark - 地图模块

- (void)reportWithLatitude:(CGFloat)latitude
                longtitude:(CGFloat)longitude
                   address:(NSString *)address
                     photo:(UIImage *)photo
                   success:(SimpleSuccessBlock)success
                    failed:(SimpleFailedBlock)failed;

@end
