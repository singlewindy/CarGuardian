//
//  AppDelegate.m
//  CarGuard
//
//  Created by Stan on 11/9/14.
//  Copyright (c) 2014 PubGeek. All rights reserved.
//

#import "PGAppDelegate.h"
#import "PGFunction.h"
#import "PGGlobal.h"

#import "PGMessageViewController.h"
#import "PGMessageDetailViewController.h"

#import <MAMapKit/MAMapKit.h>
#import "APService.h"

#import "User.h"

#define Rgb2UIColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]

@interface PGAppDelegate ()

@end

@implementation PGAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    UIImage *navBarImage = [[PGFunction function] imageWithColor:Rgb2UIColor(56, 168, 124)];
//    UIImage *navBarImage = [[PGFunction function] imageWithColor:Rgb2UIColor(204, 0, 1)];
    [[UINavigationBar appearance] setBackgroundImage:navBarImage forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"Model"];
    [MAMapServices sharedServices].apiKey = AMAP_API_KEY;
    
    self.service = [[PGService alloc] init];
    
    _mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    _centerController = [_mainStoryboard instantiateViewControllerWithIdentifier:@"Map"];
    
    [self initPushServiceWithOptions:launchOptions];
    
    [self doLoginProcess];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    // Required
    [APService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required
    [APService handleRemoteNotification:userInfo];
    NSLog(@"%@", userInfo);
    
    if (self.service.token) {
        if (application.applicationState == UIApplicationStateActive){
            //应用程序在前台的时候，这里可以做响应的处理
            
        } else {
            PGMessageDetailViewController *vc = [_mainStoryboard instantiateViewControllerWithIdentifier:@"MessageDetail"];
            vc.aid = userInfo[@"aid"];
            [(UINavigationController *)[(IIViewDeckController *)self.window.rootViewController centerController] pushViewController:vc animated:YES];
        }
    }
    
}

#pragma mark - Helper Functions

- (IIViewDeckController *)viewDeckController {
    UIViewController* leftMenuController = [_mainStoryboard instantiateViewControllerWithIdentifier:@"Menu"];
    
    IIViewDeckController *viewDeckController =  [[IIViewDeckController alloc] initWithCenterViewController:_centerController leftViewController:leftMenuController rightViewController:nil];
    
    viewDeckController.leftSize = 95;
    viewDeckController.centerhiddenInteractivity = IIViewDeckCenterHiddenNotUserInteractiveWithTapToCloseBouncing;
    
    return viewDeckController;
}

- (UINavigationController *)loginViewController {
    return [_mainStoryboard instantiateViewControllerWithIdentifier:@"Login"];
}

- (void)doLoginProcess {
    
    //    BOOL launchedBefore = [[NSUserDefaults standardUserDefaults] boolForKey:@"LaunchedBefore"];
    //
    //    if(!launchedBefore) {
    //        self.window.rootViewController = self.introViewController;
    //        return;
    //    }
    
    User *user = [User MR_findFirst];
    
    self.window.rootViewController = user ? self.viewDeckController : self.loginViewController;
    
    if (user) {
        [self.service loginWithUserName:user.username password:user.password success:^{
            NSLog(@"Login Success!");
        } failed:^(NSString *error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"帐号异常，请重新登录！" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            
            [alertView show];
        }];
    }

}

- (void)initPushServiceWithOptions:(NSDictionary *)launchOptions {
    // Required
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [APService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                       UIUserNotificationTypeSound |
                                                       UIUserNotificationTypeAlert)
                                           categories:nil];
    } else {
        //categories 必须为nil
        [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                       UIRemoteNotificationTypeSound |
                                                       UIRemoteNotificationTypeAlert)
                                           categories:nil];
    }
#else
    //categories 必须为nil
    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                   UIRemoteNotificationTypeSound |
                                                   UIRemoteNotificationTypeAlert)
                                       categories:nil];
#endif
    // Required
    [APService setupWithOption:launchOptions];
}

@end
