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


@interface ViewController ()
@property (nonatomic, strong) UITableView *tableView;
/**
 *  网络图像模型数组
 */
@property (nonatomic, strong) NSArray <WebImageModel *> *imageList;
@end

@implementation ViewController

- (void)loadView {
    // 实例化tableView
    _tableView = [[UITableView alloc] init];
    
    self.view = _tableView;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        
        _imageList = arrayM.copy;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"加载数据失败%@",error);
    }];



}
@end
