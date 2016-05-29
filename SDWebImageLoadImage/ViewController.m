//
//  ViewController.m
//  SDWebImageLoadImage
//
//  Created by CrazyHacker on 16/5/29.
//  Copyright © 2016年 CrazyHacker. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "WebImageModel.h"
#import "WebImageViewCell.h"
#import "CZAdditions.h"

static NSString *cellId = @"cellId";
@interface ViewController ()<UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
/**
 *  网络图像模型数组
 */
@property (nonatomic, strong) NSArray <WebImageModel *> *imageList;

/**
 *  图像缓冲池
 */
@property (nonatomic, strong) NSMutableDictionary *imageCache;

/**
 *  操作缓冲池
 */
@property (nonatomic, strong) NSMutableDictionary *operationCache;
@end

@implementation ViewController {
    NSOperationQueue *_loadImageQueue;
}

- (void)loadView {
    // 实例化tableView
    _tableView = [[UITableView alloc] init];
    _tableView.rowHeight = 100;
    _tableView.dataSource = self;
    
    // 注册原型cell
    [_tableView registerNib:[UINib nibWithNibName:@"WebImageViewCell" bundle:nil] forCellReuseIdentifier:cellId];
    
    self.view = _tableView;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData];
    
    // 实例化全局队列
    _loadImageQueue = [[NSOperationQueue alloc] init];
    
    // 实例化缓冲池
    _imageCache = [NSMutableDictionary dictionary];
    _operationCache = [NSMutableDictionary dictionary];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // 假设收到内存警告, 清除图像缓冲池
    [_imageCache removeAllObjects];
    // 收到内存警告清空所有操作
    [_operationCache removeAllObjects];
}

#pragma mark - 加载数据
- (void)loadData {
    // 1. 获取http 网络管理器
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];;
    
    // 2. 使用GET方法获取网络数据
    [manager GET:@"https://raw.githubusercontent.com/initKing/webData/e89e881e12dde829eb04a51194b84b0072463494/apps.json" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSArray *responseObject) {
        NSLog(@"%@ -- %@",responseObject, [responseObject class]);
        // 3. 加载数据 - 字典转模型
        NSMutableArray *arrayM = [NSMutableArray array];
        
        for (NSDictionary *dict in responseObject) {
            WebImageModel *model = [[WebImageModel alloc] init];
            
            [model setValuesForKeysWithDictionary:dict];
            
            // KVC
            [arrayM addObject:model];
        }
        // 使用属性记录模型字典
        _imageList = arrayM.copy;
        
        [_tableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"加载数据失败%@",error);
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _imageList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WebImageViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    WebImageModel *model = _imageList[indexPath.row];
    cell.titleLabel.text = model.name;
    cell.loadCountLabel.text = model.download;
    
    // 判断如果缓冲池中有视图
    UIImage *image = _imageCache[model.icon];
    if (image != nil) {
        cell.iconView.image = image;
    }
    
    UIImage *cacheImage = [UIImage imageWithContentsOfFile:[self cachePathWithUrlString:model.icon]];;
    // 判断沙盒中是否有图像
    if (cacheImage != nil) {
        // 1> 直接设置cell的image
        cell.iconView.image = cacheImage;
        
        // 2> 将沙盒中的缓存保存至内存缓存 -- 内存缓存读写速度快
        [_imageCache setObject:cacheImage forKey:model.icon];
        
        return cell;
    }
    
    
    // cell 复用 --> 使用 直接设置为nil 或 占位图像(推荐)
    cell.iconView.image = nil;
  
    // 使用异步加载图像
    NSBlockOperation *operatin = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"异步下载图像");
        NSURL *url = [NSURL URLWithString:_imageList[indexPath.row].icon];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];
        
        if (image != nil) {
            [_imageCache setObject:image forKey:model.icon];
            
            // 将图像写入沙盒
            [data writeToFile:[self cachePathWithUrlString:model.icon] atomically:YES];
        }
        
        // 下载完成后 将图像地址对应的 操作从操作缓冲池中移除
        [_operationCache removeObjectForKey:model.icon];
       
        // 通知主线程更新 UI
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            cell.iconView.image = image;
            NSLog(@"队列中的操作数%zd",_loadImageQueue.operationCount);
        }];
        
    }];
   
    [_loadImageQueue addOperation:operatin];
    // 将加载图像的操作 加入操作缓冲池
    [_operationCache setObject:operatin forKey:model.icon];
    
    return cell;
}

#pragma mark - 根据图像url返回图像的沙盒全路径
- (NSString *)cachePathWithUrlString:(NSString *)urlString {
    // 1. 获取沙盒路径
    NSString *urlDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    
    // 2. 成成md5文件名
    NSString *fileName = [urlString cz_md5String];
    
    // 3. 返回拼接全路径
    return [urlDir stringByAppendingPathComponent:fileName];
}

@end
