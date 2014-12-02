//
//  PGAlertVO.h
//  CarGuard
//
//  Created by Stan on 11/21/14.
//  Copyright (c) 2014 PubGeek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PGAlertVO : NSObject

@property (nonatomic) NSNumber *aid;
@property (nonatomic) NSString *address;
@property (nonatomic) NSString *message;
@property (nonatomic) NSString *photo;
@property (nonatomic) NSString *username;
@property (nonatomic) NSNumber *uid;
@property (nonatomic) NSString *avatar;
@property (nonatomic) NSDate *time;

@property (nonatomic) double distance;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

+ (PGAlertVO *)alertWithInfo:(id)obj;
+ (NSArray *)alertsWithInfo:(id)array;
- (PGAlertVO *)initWithInfo:(id)obj;

@end
