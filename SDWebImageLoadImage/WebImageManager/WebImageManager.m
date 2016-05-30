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


- (instancetype)init {
    self = [super init];
    if (self) {
        
        // 实例化 属性
        _imageCache = [NSMutableDictionary dictionary];
        
        _operationCache = [NSMutableDictionary dictionary];
        
        _downQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}
@end
