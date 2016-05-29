//
//  WebImageManager.m
//  SDWebImageLoadImage
//
//  Created by CrazyHacker on 16/5/30.
//  Copyright © 2016年 CrazyHacker. All rights reserved.
//

#import "WebImageManager.h"

@implementation WebImageManager
+ (instancetype)sharedManager {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}
@end
