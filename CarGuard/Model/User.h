//
//  User.h
//  CarGuard
//
//  Created by Stan on 12/1/14.
//  Copyright (c) 2014 PubGeek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * isGetOff;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSNumber * sex;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * avatar;

@end
