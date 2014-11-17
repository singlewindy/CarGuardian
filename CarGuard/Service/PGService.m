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

#import "User.h"

@interface PGService()

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
    }
    
    return self;
}


#pragma mark - 帐号模块

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
        
        if ([JSON[@"status"] boolValue]) {
            _token = JSON[@"token"];
            
            [self appModelWithInfo:JSON];
            
            success();
        } else {
            [AppModel MR_truncateAll];
            
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
            [self appModelWithInfo:JSON];
            
            success();
            
        }else{
            failed(JSON[@"error"]);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self setNetworkCount:@([_networkCount integerValue] - 1)];
        
        failed(@"网络连接错误");
    }];
    
}

#pragma mark - 地图模块

- (void)reportWithLatitude:(CGFloat)latitude
                longtitude:(CGFloat)longitude
                   address:(NSString *)address
                     photo:(UIImage *)photo
                   success:(SimpleSuccessBlock)success
                    failed:(SimpleFailedBlock)failed {
    
    NSString *baseURL = [API_BASE stringByAppendingString:API_SEND_ALERT];
    
    NSString *fileName = [NSString stringWithFormat:@"%ld%c%c.jpg", (long)[[NSDate date] timeIntervalSince1970], arc4random_uniform(26) + 'a', arc4random_uniform(26) + 'a'];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *parameters = @{@"latitude":@(latitude),
                                 @"longitude":@(longitude),
                                 @"address":address,
                                 @"time":[[PGFunction function] dateFromNSDate:[NSDate date]],
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


#pragma mark - CoreData Functions

- (void)appModelWithInfo:(NSDictionary *)obj {
    
    AppModel *appModel = [AppModel MR_createEntity];
    appModel.token = obj[@"token"];
    
    User *user = [User MR_createEntity];
    user.uid = obj[@"uid"];
    user.username = obj[@"username"];
    user.email = obj[@"email"];
    
    appModel.user = user;
    _appModel = appModel;
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}


@end
