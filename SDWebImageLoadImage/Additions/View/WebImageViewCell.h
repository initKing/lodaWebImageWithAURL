//
//  WebImageViewCell.h
//  SDWebImageLoadImage
//
//  Created by CrazyHacker on 16/5/29.
//  Copyright © 2016年 CrazyHacker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebImageViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *loadCountLabel;

@end
