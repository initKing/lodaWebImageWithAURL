//
//  WebImageManager.m
//  SDWebImageLoadImage
//
//  Created by CrazyHacker on 16/5/30.
//  Copyright © 2016年 CrazyHacker. All rights reserved.
//

#import "WebImageManager.h"
#import "CZAdditions.h"

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

#pragma mark - 下载图像的方法
// 使用URL下载图像, 完成后通过回调,返回下载完成的图像
- (void)downloadImageWithUrlString:(NSString *)urlString compeletion:(void(^)(UIImage *))completion{
    NSAssert(completion != nil, @"必须完成回调");
    
    // 1. 检查内存缓存是否缓存了图像
    UIImage *image = _imageCache[urlString];
    if (_imageCache != nil) {
        completion(image);
        return;
    }
    
    // 2. 检查沙盒是否缓存了图像
    image = [UIImage imageWithContentsOfFile:[self cachePathWithUrl:urlString]];
    if (image != nil) {
        // 设置内存缓存
        [_imageCache setObject:image forKey:urlString];
        
        completion(image);
        return;
    }
    
    // 3. 假设下载时间过长, 通过操作缓存池, 避免重复下载
    if (_operationCache[urlString] != nil) {
        return;
    }
    
    

}

// 返回图像在沙盒中的全路径
- (NSString *)cachePathWithUrl:(NSString *)urlString {
    NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    
    NSString *imagePath = [urlString cz_md5String];
    // 返回拼接的全路径
    return [cacheDir stringByAppendingPathComponent:imagePath];
}
@end
