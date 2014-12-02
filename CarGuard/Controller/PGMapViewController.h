//
//  PGMapViewController.h
//  CarGuard
//
//  Created by Stan on 11/10/14.
//  Copyright (c) 2014 PubGeek. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PGMapViewController : UIViewController

@property (nonatomic) NSArray *data;
@property (nonatomic) NSUInteger type;  // 0 -- 主页, 1 -- 警情地图

@end
