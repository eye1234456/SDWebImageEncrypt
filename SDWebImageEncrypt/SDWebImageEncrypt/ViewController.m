//
//  ViewController.m
//  SDWebImageEncrypt
//
//  Created by lonelyEye on 3/10/22.
//

#import "ViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/SDAnimatedImageView.h>
#import <YYWebImage/YYWebImage.h>

typedef NS_ENUM(NSInteger, LoadType) {
    LoadTypeLocal, // 加载本地图片
    LoadTypeSDWebImage, // 使用SDWebImage加载远程图片
    LoadTypeYYImage, // 使用YYImage加载远程图片
};

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *dataList;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    // 未加密的图片
    NSArray *list = @[
        @"YYImage-originImage-不加密图片",
        @"YYImage-encryptImage-加密图片",
        @"SDWebImage-originImage-不加密图片",
        @"SDWebImage-encryptImage-加密图片"
                      ];
    for (NSString *title in list) {
        NSMutableArray *list = [NSMutableArray array];
        if ([title containsString:@"encryptImage"]) {
            // 加密的图片
            [list addObject:@"https://raw.githubusercontent.com/eye1234456/SDWebImageEncrypt/main/encryptImage/1.jpeg"];
            [list addObject:@"https://raw.githubusercontent.com/eye1234456/SDWebImageEncrypt/main/encryptImage/2.png"];
            [list addObject:@"https://raw.githubusercontent.com/eye1234456/SDWebImageEncrypt/main/encryptImage/3.webp"];
            [list addObject:@"https://raw.githubusercontent.com/eye1234456/SDWebImageEncrypt/main/encryptImage/4.webp"];
            [list addObject:@"https://raw.githubusercontent.com/eye1234456/SDWebImageEncrypt/main/encryptImage/5.gif"];
        }else {
            [list addObject:@"https://raw.githubusercontent.com/eye1234456/SDWebImageEncrypt/main/originImage/1.jpeg"];
            [list addObject:@"https://raw.githubusercontent.com/eye1234456/SDWebImageEncrypt/main/originImage/2.png"];
            [list addObject:@"https://raw.githubusercontent.com/eye1234456/SDWebImageEncrypt/main/originImage/3.webp"];
            [list addObject:@"https://raw.githubusercontent.com/eye1234456/SDWebImageEncrypt/main/originImage/4.webp"];
            [list addObject:@"https://raw.githubusercontent.com/eye1234456/SDWebImageEncrypt/main/originImage/5.gif"];
        }
        
        [self.dataList addObject:@{@"title":title,@"list":list}];
    }
    
    [self.tableView reloadData];
    
    
    
}

#pragma mark UITableViewDataSource & UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *dict = self.dataList[section];
    NSArray *list = dict[@"list"];
    return list.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [UILabel new];
    NSDictionary *dict = self.dataList[section];
    label.text = dict[@"title"];
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dict = self.dataList[indexPath.section];
    NSArray *list = dict[@"list"];
    NSString *urlStr = list[indexPath.row];
    NSString *title = dict[@"title"];
    if ([title containsString:@"SDWebImage"]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell_SD" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        // 使用sdwebimage 加载
        UIImageView *imageView = cell.imageView;
        imageView = [cell.contentView viewWithTag:100];
        if (imageView == nil) {
            imageView = [[SDAnimatedImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
            imageView.tag = 100;
            [cell.contentView addSubview:imageView];
        }
        [imageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        cell.textLabel.text = urlStr;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:10];
        return cell;
    }else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell_YY" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        // 使用YYImage 加载
        UIImageView *imageView = cell.imageView;
        // YYImageView, 不能适配既可以展示动图，又展示静态图的情况
        imageView = [cell.contentView viewWithTag:101];
        if (imageView == nil) {
            imageView = [[YYAnimatedImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
            imageView.tag = 101;
            [cell.contentView addSubview:imageView];
        }
        [imageView yy_setImageWithURL:[NSURL URLWithString:urlStr] placeholder:[UIImage imageNamed:@"placeholder"]];
        cell.textLabel.text = urlStr;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:10];
        return cell;
    }
    
}

#pragma mark - getter
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"UITableViewCell_SD"];
        [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"UITableViewCell_YY"];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

- (NSMutableArray *)dataList {
    if (_dataList == nil) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}
@end
