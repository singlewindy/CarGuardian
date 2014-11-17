//
//  User.h
//  CarGuard
//
//  Created by Stan on 11/10/14.
//  Copyright (c) 2014 PubGeek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * uid;

@end
