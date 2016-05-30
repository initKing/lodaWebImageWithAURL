//
//  WebImageManager.h
//  SDWebImageLoadImage
//
//  Created by CrazyHacker on 16/5/30.
//  Copyright © 2016年 CrazyHacker. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 *  网络图像管理者
 */
@interface WebImageManager : NSObject
/**
 *  图像缓冲池
 */
@property (nonatomic, strong) NSMutableDictionary *imageCache;

/**
 *  操作缓冲池
 */
@property (nonatomic, strong) NSMutableDictionary *operationCache;

/**
 *  下载队列
 */
@property (nonatomic, strong) NSOperationQueue *downQueue;

/**
 *  图像管理单例
 */
+ (instancetype)sharedManager;
@end
