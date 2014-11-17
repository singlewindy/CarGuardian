//
//  AppDelegate.h
//  CarGuard
//
//  Created by Stan on 11/9/14.
//  Copyright (c) 2014 PubGeek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PGService.h"
#import "IIViewDeckController.h"

@interface PGAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) PGService *service;

@property (nonatomic) IIViewDeckController *viewDeckController;
@property (nonatomic) UINavigationController *loginViewController;
@property (nonatomic) UINavigationController *centerController;
@property (nonatomic) UIStoryboard *mainStoryboard;

@end

