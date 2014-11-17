//
//  PGFunction.m
//  soccer
//
//  Created by Stan on 6/28/14.
//  Copyright (c) 2014 greferry-pro. All rights reserved.
//

#import "PGFunction.h"

#define Rgb2UIColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]

static PGFunction *__function = nil;
static int maxFileSize = 200*1024;

@implementation PGFunction

+ (id)function {
    return [[PGFunction alloc] init];
}

- (id)init {
    if (__function) return __function;
    if (self = [super init]) {
        __function = self;
    }
    return self;
}

- (void)initCornerOfViews:(NSArray *)array {
    [array enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        view.layer.cornerRadius = 3;
        view.layer.masksToBounds = YES;
    }];
}

- (void)initBorderOfViews:(NSArray *)array {
    [array enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        view.layer.borderColor = Rgb2UIColor(221, 221, 221).CGColor;
        view.layer.borderWidth = 1.0f;
    }];
}

- (NSString *)dateFromNSDate:(NSDate *)date {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [dateFormat stringFromDate:date];
}

- (NSDate *)NSDateFormString:(NSString *)dateString {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [dateFormat dateFromString:dateString];
}

- (UIImage *)imageForRating:(int)rating
{
    switch (rating) {
        case 1:
            return [UIImage imageNamed:@"1StarSmall"];
            break;
        case 2:
            return [UIImage imageNamed:@"2StarsSmall"];
            break;
        case 3:
            return [UIImage imageNamed:@"3StarsSmall"];
            break;
        case 4:
            return [UIImage imageNamed:@"4StarsSmall"];
            break;
        case 5:
            return [UIImage imageNamed:@"5StarsSmall"];
            break;
        default:
            break;
    }
    return nil;
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (NSData *)compressImage:(UIImage *)image {
    
    if (image) {
        NSData *photoData = UIImageJPEGRepresentation(image, 0.5);
        CGFloat compression = 0.9f;
        CGFloat maxCompression = 0.1f;
        
        while ([photoData length] > maxFileSize && compression > maxCompression)
        {
            compression -= 0.1;
            photoData = UIImageJPEGRepresentation(image, compression);
        }
        
        return photoData;
    }
    
    return nil;
}

@end
