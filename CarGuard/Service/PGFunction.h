//
//  PGFunction.h
//  soccer
//
//  Created by Stan on 6/28/14.
//  Copyright (c) 2014 greferry-pro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PGFunction : NSObject

+ (id)function;
- (id)init;

- (void)initCornerOfViews:(NSArray *)array;
- (void)initBorderOfViews:(NSArray *)array;
- (void)initRoundViews:(NSArray *)array;

- (NSString *)dateFromNSDate:(NSDate *)date;
- (NSDate *)NSDateFormString:(NSString *)dateString;

- (UIImage *)imageForRating:(int)rating;
- (UIImage *)imageWithColor:(UIColor *)color;
- (NSData *)compressImage:(UIImage *)image;
- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell
                                        tableView:(UITableView *)tableView;

- (void)showAlertViewWithMessage:(NSString *)message;

@end
