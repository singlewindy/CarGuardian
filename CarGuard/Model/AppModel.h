//
//  AppModel.h
//  CarGuard
//
//  Created by Stan on 11/10/14.
//  Copyright (c) 2014 PubGeek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface AppModel : NSManagedObject

@property (nonatomic, retain) NSString * token;
@property (nonatomic, retain) User *user;

@end
