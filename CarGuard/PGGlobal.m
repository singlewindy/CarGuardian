//
//  PGGlobal.m
//  soccer
//
//  Created by Stan Zhang on 4/26/14.
//  Copyright (c) 2014 greferry-pro. All rights reserved.
//

#import "PGGlobal.h"

NSString *API_BASE = @"http://guardapi.pubgeek.com/";

NSString *AMAP_API_KEY = @"ce7b004969167c93cb2720febfcfbb4b";
NSString *UMENG_APPKEY = @"53b6686956240b45d6029f3e";

#pragma mark - 帐号模块

NSString *API_LOGIN = @"api/login/";
NSString *API_LOGOUT = @"api/logout/";
NSString *API_REGISTER = @"api/register/";
NSString *API_CHANGE_PASSWORD = @"api/changepassword/";

#pragma mark - 地图模块

NSString *API_SEND_ALERT = @"api/sendalert/";


#pragma mark - 用户模块

NSString *API_UPDATE_LOCATION = @"api/user/updatelocation/";
NSString *API_UPDATE_AVATAR = @"api/user/updateavatar/";
NSString *API_UPDATE_USER_INFO = @"api/user/updateprofile/";

#pragma mark - Notifications

NSString *NOTIFICATION_UPDATE_CURRENT_USER_LOCATION_RESULT = @"NOTIFICATION_UPDATE_CURRENT_USER_LOCATION_RESULT";
NSString *NOTIFICATION_UPDATE_CURRENT_USER_LOCATION_ERROR = @"NOTIFICATION_UPDATE_CURRENT_USER_LOCATION_ERROR";

#pragma mark - 常量

NSUInteger SIZE_NEARBY_PAGE = 20;

