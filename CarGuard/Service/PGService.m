//
//  PGService.m
//  CarGuard
//
//  Created by Stan on 11/9/14.
//  Copyright (c) 2014 PubGeek. All rights reserved.
//

#import "PGService.h"
#import "PGGlobal.h"
#import "PGFunction.h"
#import "PGAppDelegate.h"

#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"
#import "APService.h"

#import "User.h"
#import "PGAlertVO.h"

@interface PGService()

@property (nonatomic, copy) SimpleSuccessBlock updateLocationSuccess;
@property (nonatomic, copy) SimpleFailedBlock updateLocationFailed;

@end

@implementation PGService

+ (instancetype)service {
    PGAppDelegate *delegate = (PGAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    return [delegate service];
}

- (id)init {
    self = [super init];
    
    if (self) {
        _appModel = [AppModel MR_findFirst];
        _token = _appModel.token;
        _networkCount = @0;
        _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
        _mapView.delegate = self;
        _mapView.showsUserLocation = YES;
    }
    
    return self;
}


#pragma mark - 帐号模块

//- (void)loginWithDeviceToken:(NSString *)deviceToken
//                     success:(ObjSuccessBlock)success
//                      failed:(SimpleFailedBlock)failed {
//    
//    NSString *baseURL = [API_BASE stringByAppendingString:API_LOGIN];
//    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    
//    NSDictionary *params = @{@"device_token":deviceToken};
//    
//    [self setNetworkCount:@([_networkCount integerValue] + 1)];
//    
//    [manager POST:baseURL parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
//        
//        NSLog(@"login::: %@", JSON);
//        
//        [self setNetworkCount:@([_networkCount integerValue] - 1)];
//        
//        [AppModel MR_truncateAll];
//        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
//        
//        if ([JSON[@"status"] boolValue]) {
//            _token = JSON[@"token"];
//            
//            [self appModelWithInfo:JSON];
//            
//            success(JSON[@"uid"]);
//        } else {
//            failed(JSON[@"error"]);
//        }
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [self setNetworkCount:@([_networkCount integerValue] - 1)];
//        failed(@"网络连接错误！");
//    }];
//    
//}

- (void)loginWithUserName:(NSString *)username
                 password:(NSString *)password
                  success:(SimpleSuccessBlock)success
                   failed:(SimpleFailedBlock)failed {
    
    NSString *baseURL = [API_BASE stringByAppendingString:API_LOGIN];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *params = @{@"username":username, @"password":password};
    
    [self setNetworkCount:@([_networkCount integerValue] + 1)];
    
    [manager POST:baseURL parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        NSLog(@"login::: %@", JSON);
        
        [self setNetworkCount:@([_networkCount integerValue] - 1)];
        
        [AppModel MR_truncateAll];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        
        if ([JSON[@"status"] boolValue]) {
            _token = JSON[@"token"];
            
            [self appModelWithInfo:JSON password:password];
            
            success();
        } else {
            failed(JSON[@"error"]);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self setNetworkCount:@([_networkCount integerValue] - 1)];
        failed(@"网络连接错误！");
    }];
    
}

- (void)logoutComplete:(SimpleSuccessBlock)complete {
    _token = nil;
    [AppModel MR_truncateAll];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    complete();
}

- (void)registerWithUserName:(NSString *)username
                       email:(NSString *)email
                    password:(NSString *)password
                     success:(SimpleSuccessBlock)success
                      failed:(SimpleFailedBlock)failed {
    
    NSString *baseURL = [API_BASE stringByAppendingString:API_REGISTER];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *params = @{@"username":username, @"email":email, @"password1":password, @"password2":password};
    
    [self setNetworkCount:@([_networkCount integerValue] + 1)];
    
    [manager POST:baseURL parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        NSLog(@"register::: %@", JSON);
        
        [self setNetworkCount:@([_networkCount integerValue] - 1)];
        
        if([JSON[@"status"] boolValue])
        {
            _token = JSON[@"token"];
            [self appModelWithInfo:JSON password:password];
            
            success();
            
        }else{
            failed(JSON[@"error"]);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self setNetworkCount:@([_networkCount integerValue] - 1)];
        
        failed(@"网络连接错误");
    }];
    
}

#pragma mark - 用户模块

- (void)updateAvatarWithPhotoData:(NSData *)imageData
                          success:(SimpleSuccessBlock)success
                           failed:(SimpleFailedBlock)failed {
    
    NSString *baseURL = [API_BASE stringByAppendingString:API_UPDATE_AVATAR];
    
    NSString *fileName = [NSString stringWithFormat:@"%ld%c%c.jpg", (long)[[NSDate date] timeIntervalSince1970], arc4random_uniform(26) + 'a', arc4random_uniform(26) + 'a'];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *parameters = @{@"token": _token};
    
    [manager POST:baseURL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"avatar" fileName:fileName mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"JSON: %@", JSON);
        if (JSON[@"status"]) {
            User *user = [User MR_findFirst];
            user.avatar = JSON[@"avatar"];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            
            success();
        } else {
            failed(JSON[@"error"]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        failed(error.localizedDescription);
    }];
    
}

- (void)updateUserInfoForKey:(NSString *)key
                       value:(id)value
                     success:(SimpleSuccessBlock)success
                      failed:(SimpleFailedBlock)failed {
    
    // type -- 1 上岗, type -- 0 下岗
    NSString *baseURL = [API_BASE stringByAppendingString:API_UPDATE_USER_INFO];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *params = @{@"key":key, @"value":value, @"token":_token};
    
    [self setNetworkCount:@([_networkCount integerValue] + 1)];
    
    [manager POST:baseURL parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        NSLog(@"updateUserInfo::: %@", JSON);
        
        [self setNetworkCount:@([_networkCount integerValue] - 1)];
        
        if([JSON[@"status"] boolValue])
        {
            success();
        }else{
            failed(JSON[@"error"]);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self setNetworkCount:@([_networkCount integerValue] - 1)];
        
        failed(@"网络连接错误");
    }];
}


#pragma mark - 主模块

- (void)reportWithLatitude:(CGFloat)latitude
                longtitude:(CGFloat)longitude
                   address:(NSString *)address
                   message:(NSString *)message
                     photo:(UIImage *)photo
                   success:(SimpleSuccessBlock)success
                    failed:(SimpleFailedBlock)failed {
    
    NSString *baseURL = [API_BASE stringByAppendingString:API_SEND_ALERT];
    
    NSString *fileName = [NSString stringWithFormat:@"%ld%c%c.jpg", (long)[[NSDate date] timeIntervalSince1970], arc4random_uniform(26) + 'a', arc4random_uniform(26) + 'a'];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *parameters = @{@"latitude":@(latitude),
                                 @"longitude":@(longitude),
                                 @"address":address,
                                 @"message":message,
                                 @"time":@((long)[[NSDate date] timeIntervalSince1970]),
                                 @"token":_token};
    
    [manager POST:baseURL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (photo) {
            [formData appendPartWithFileData:[[PGFunction function] compressImage:photo] name:@"photo" fileName:fileName mimeType:@"image/jpeg"];
        }
    } success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"JSON: %@", JSON);
        if (JSON[@"status"]) {
            success();
        } else {
            failed(JSON[@"error"]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        failed(error.description);
    }];
    
}

- (void)getOnOffWithType:(NSUInteger)type
                 success:(SimpleSuccessBlock)success
                  failed:(SimpleFailedBlock)failed {
    // type -- 1 上岗, type -- 0 下岗
    if (type == 1) {
        [self updateCurrentUserLocationSuccess:^{
            [self onOffWithType:type success:success failed:failed];
        } Failed:^(NSString *error) {
            NSLog(@"%@", error);
        }];
    } else {
        [self onOffWithType:type success:success failed:failed];
    }
}

- (void)onOffWithType:(NSUInteger)type
              success:(SimpleSuccessBlock)success
               failed:(SimpleFailedBlock)failed {
    
    // type -- 1 上岗, type -- 0 下岗
    NSString *baseURL = type ? [API_BASE stringByAppendingString:API_GET_OFF] : [API_BASE stringByAppendingString:API_GET_ON];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    User *user = [User MR_findFirst];
    
    NSDictionary *params = @{@"latitude":user.latitude, @"longitude":user.longitude, @"token":_token};
    
    [self setNetworkCount:@([_networkCount integerValue] + 1)];
    
    [manager GET:baseURL parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        NSLog(@"getOnOff::: %@", JSON);
        
        [self setNetworkCount:@([_networkCount integerValue] - 1)];
        
        if([JSON[@"status"] boolValue])
        {
            User *user = [User MR_findFirst];
            user.isGetOff = @(type);
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            success();
        }else{
            failed(JSON[@"error"]);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self setNetworkCount:@([_networkCount integerValue] - 1)];
        
        failed(@"网络连接错误");
    }];
}

#pragma mark - 警告模块

- (void)getAlertListOfPage:(NSUInteger)page
                      size:(NSUInteger)size
                   success:(ObjSuccessBlock)success
                    failed:(SimpleFailedBlock)failed {
    
    if (page == 1) {
        [self updateCurrentUserLocationSuccess:^{
            [self alertListOfPage:page size:size success:success failed:failed];
        } Failed:^(NSString *error) {
            NSLog(@"%@", error);
        }];
    } else {
        [self alertListOfPage:page size:size success:success failed:failed];
    }
    
}

- (void)alertListOfPage:(NSUInteger)page
                   size:(NSUInteger)size
                success:(ObjSuccessBlock)success
                 failed:(SimpleFailedBlock)failed {
    
    NSString *baseURL = [API_BASE stringByAppendingString:API_GET_ALERT_LIST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    User *user = [User MR_findFirst];
    
    NSDictionary *params = @{@"latitude":user.latitude, @"longitude":user.longitude, @"page":@(page), @"size":@(size), @"token":_token};
    
    [self setNetworkCount:@([_networkCount integerValue] + 1)];
    
    [manager GET:baseURL parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        NSLog(@"getAlertList::: %@", JSON);
        
        [self setNetworkCount:@([_networkCount integerValue] - 1)];
        
        if([JSON[@"status"] boolValue])
        {
            success([PGAlertVO alertsWithInfo:JSON[@"data"]]);
        }else{
            failed(JSON[@"error"]);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self setNetworkCount:@([_networkCount integerValue] - 1)];
        
        failed(@"网络连接错误");
    }];
    
}

- (void)getAlertOfAid:(NSNumber *)aid
              success:(ObjSuccessBlock)success
               failed:(SimpleFailedBlock)failed {
    
    [self updateCurrentUserLocationSuccess:^{
        
        NSString *baseURL = [API_BASE stringByAppendingString:API_GET_ALERT];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        User *user = [User MR_findFirst];
        
        NSDictionary *params = @{@"latitude":user.latitude, @"longitude":user.longitude, @"aid":aid, @"token":_token};
        
        [self setNetworkCount:@([_networkCount integerValue] + 1)];
        
        [manager GET:baseURL parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
            
            NSLog(@"getAlert::: %@", JSON);
            
            [self setNetworkCount:@([_networkCount integerValue] - 1)];
            
            if([JSON[@"status"] boolValue])
            {
                success([PGAlertVO alertWithInfo:JSON[@"data"]]);
            }else{
                failed(JSON[@"error"]);
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self setNetworkCount:@([_networkCount integerValue] - 1)];
            
            failed(@"网络连接错误");
        }];
        
    } Failed:^(NSString *error) {
        NSLog(@"%@", error);
    }];
}

- (void)getAllAlertsSuccess:(ObjSuccessBlock)success
                     failed:(SimpleFailedBlock)failed {
    
    [self updateCurrentUserLocationSuccess:^{
        
        NSString *baseURL = [API_BASE stringByAppendingString:API_GET_ALL_ALERTS];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        User *user = [User MR_findFirst];
        
        NSDictionary *params = @{@"latitude":user.latitude, @"longitude":user.longitude, @"token":_token};
        
        [self setNetworkCount:@([_networkCount integerValue] + 1)];
        
        [manager GET:baseURL parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
            
            NSLog(@"getAlert::: %@", JSON);
            
            [self setNetworkCount:@([_networkCount integerValue] - 1)];
            
            if([JSON[@"status"] boolValue])
            {
                success([PGAlertVO alertsWithInfo:JSON[@"data"]]);
            }else{
                failed(JSON[@"error"]);
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self setNetworkCount:@([_networkCount integerValue] - 1)];
            
            failed(@"网络连接错误");
        }];
        
    } Failed:^(NSString *error) {
        NSLog(@"%@", error);
    }];
}

#pragma mark - 定位模块

//更新位置
//---------------
- (void)updateCurrentUserLocationSuccess:(SimpleSuccessBlock)success
                                  Failed:(SimpleFailedBlock)failed {
    
    _mapView.showsUserLocation = YES;//开始定位
    self.updateLocationSuccess = success;
    self.updateLocationFailed = failed;
}

- (void)mapView:(MAMapView*)mapView didUpdateUserLocation:(MAUserLocation*)userLocation updatingLocation:(BOOL)updatingLocation
{
    if (userLocation != nil) {
        NSLog(@"%f %f", userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
        _mapView.showsUserLocation = NO;//关闭定位
        
        User *user = [User MR_findFirst];
        user.latitude = @(userLocation.location.coordinate.latitude);
        user.longitude = @(userLocation.location.coordinate.longitude);
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        
        if (self.updateLocationSuccess) {
            self.updateLocationSuccess();
            self.updateLocationSuccess = nil;
        }
        
    }
}

-(void)mapView:(MAMapView*)mapView didFailToLocateUserWithError:(NSError*)error
{
    NSLog(@"location error");
    if (self.updateLocationFailed) {
        self.updateLocationFailed(error.description);
        self.updateLocationFailed = nil;
    }
}


#pragma mark - CoreData Functions

- (void)appModelWithInfo:(NSDictionary *)obj password:(NSString *)password {
    
    AppModel *appModel = [AppModel MR_createEntity];
    appModel.token = obj[@"token"];
    
    User *user = [User MR_createEntity];
    user.uid = obj[@"uid"];
    user.username = obj[@"username"];
    user.password = password;
    user.email = obj[@"email"];
    user.isGetOff = obj[@"isgetoff"];
    user.avatar = obj[@"avatar"];
    user.sex = obj[@"sex"];
    user.city = obj[@"city"];
    
    appModel.user = user;
    _appModel = appModel;
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    [APService setAlias:[user.uid stringValue] callbackSelector:nil object:nil];
}


@end
