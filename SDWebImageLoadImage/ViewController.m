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
#import "WebImageManager.h"

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
    
    NSLog(@"%@",[WebImageManager sharedManager]);
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
    
    
        // 通知主线程更新 UI
    [[WebImageManager sharedManager] downloadImageWithUrlString:model.icon compeletion:^(UIImage *image) {
        
        cell.iconView.image = image;
    }];

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
