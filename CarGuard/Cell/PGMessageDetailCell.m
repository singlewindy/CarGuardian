//
//  PGMessageDetailCell.m
//  CarGuard
//
//  Created by Stan on 11/22/14.
//  Copyright (c) 2014 PubGeek. All rights reserved.
//

#import "PGMessageDetailCell.h"
#import "NSDate+NVTimeAgo.h"
#import "UIImageView+WebCache.h"
#import  "QuartzCore/QuartzCore.h"

#import "JTSImageViewController.h"

@interface PGMessageDetailCell()

@property (strong, nonatomic) IBOutlet UIImageView *avatarView;
@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelTime;
@property (strong, nonatomic) IBOutlet UILabel *labelDescription;
@property (strong, nonatomic) IBOutlet UIImageView *photoView;
@property (strong, nonatomic) IBOutlet UILabel *labelMessage;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *photoHeight;
@property (strong, nonatomic) IBOutlet UIView *bgView;

@property (nonatomic) JTSImageInfo *imageInfo;

@end

@implementation PGMessageDetailCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setData:(PGAlertVO *)data {
    _data = data;
    
    
    self.labelName.text = data.username;
    self.labelDescription.text = [NSString stringWithFormat:@"在距您%.2fkm的%@被开了罚单", data.distance, data.address];
    self.labelTime.text = [data.time formattedAsTimeAgo];
    if ([data.photo length]) {
        self.photoHeight.constant = 200;
        
        [self.photoView sd_setImageWithURL:[NSURL URLWithString:data.photo] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            // Create image info
            _imageInfo = [[JTSImageInfo alloc] init];
            _imageInfo.image = image;
        }];
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
        self.photoView.userInteractionEnabled = YES;
        [self.photoView addGestureRecognizer:gesture];
        
    } else {
        self.photoHeight.constant = 0;
    }
    
    self.labelMessage.text = data.message;
}

- (void)tapHandle:(UITapGestureRecognizer *)tap {
//    [EXPhotoViewer showImageFrom:self.photoView];
    
    _imageInfo.referenceRect = self.photoView.frame;
    _imageInfo.referenceView = self.photoView.superview;
    
    UITableView *tv = (UITableView *) self.superview.superview;
    UITableViewController *vc = (UITableViewController *) tv.dataSource;
    
    // Setup view controller
    JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                           initWithImageInfo:_imageInfo
                                           mode:JTSImageViewControllerMode_Image
                                           backgroundStyle:JTSImageViewControllerBackgroundOption_Blurred];
    
    // Present the view controller.
    [imageViewer showFromViewController:vc transition:JTSImageViewControllerTransition_FromOriginalPosition];
}


@end
