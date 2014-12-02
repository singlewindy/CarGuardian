//
//  PGAlertVO.m
//  CarGuard
//
//  Created by Stan on 11/21/14.
//  Copyright (c) 2014 PubGeek. All rights reserved.
//

#import "PGAlertVO.h"

@implementation PGAlertVO

+ (PGAlertVO *)alertWithInfo:(NSDictionary *)obj {
    return [[PGAlertVO alloc] initWithInfo:obj];
}

+ (NSArray *)alertsWithInfo:(NSArray *)array {
    if (0 == [array count]) return @[];
    
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:[array count]];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [results addObject:[[PGAlertVO alloc] initWithInfo:obj]];
    }];
    return results;
}

- (PGAlertVO *)initWithInfo:(NSDictionary *)obj {
    if (self = [super init]) {
        _aid       = obj[@"aid"];
        _address   = obj[@"address"];
        _message   = obj[@"message"];
        _photo     = obj[@"photo"];
        _username  = obj[@"username"];
        _avatar    = obj[@"avatar"];
        _uid       = obj[@"uid"];
        _time      = [NSDate dateWithTimeIntervalSince1970:[obj[@"time"] doubleValue]];
        _distance  = [obj[@"distance"] doubleValue];
        _latitude  = [obj[@"latitude"] doubleValue];
        _longitude = [obj[@"longitude"] doubleValue];
    }
    
    return self;
}

@end
