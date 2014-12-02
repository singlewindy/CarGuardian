//
//  PGMessageDetailViewController.h
//  CarGuard
//
//  Created by Stan on 11/22/14.
//  Copyright (c) 2014 PubGeek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PGAlertVO.h"

@interface PGMessageDetailViewController : UITableViewController

@property (nonatomic) PGAlertVO *data;
@property (nonatomic) NSNumber *aid;

@end
