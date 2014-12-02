//
//  PGGlobal.h
//  soccer
//
//  Created by Stan Zhang on 4/26/14.
//  Copyright (c) 2014 greferry-pro. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString *API_BASE;

NSString *AMAP_API_KEY;         //高德地图API Key
NSString *UMENG_APPKEY;

#pragma mark - 帐号模块

NSString *API_LOGIN;
NSString *API_LOGOUT;
NSString *API_REGISTER;

#pragma mark - 主模块

NSString *API_SEND_ALERT;
NSString *API_GET_ON;
NSString *API_GET_OFF;

#pragma mark - 警告模块

NSString *API_GET_ALERT_LIST;
NSString *API_GET_ALERT;
NSString *API_GET_ALL_ALERTS;


#pragma mark - 用户模块

NSString *API_UPDATE_AVATAR;
NSString *API_UPDATE_USER_INFO;


#pragma mark - Notifications

NSString *NOTIFICATION_UPDATE_CURRENT_USER_LOCATION_RESULT;
NSString *NOTIFICATION_UPDATE_CURRENT_USER_LOCATION_ERROR;


#pragma mark - 常量

NSUInteger SIZE_NEARBY_PAGE;
