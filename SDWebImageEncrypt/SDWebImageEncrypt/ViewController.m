//
//  ViewController.m
//  SDWebImageEncrypt
//
//  Created by lonelyEye on 3/10/22.
//

#import "ViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <YYImage/YYImage.h>

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
}

#pragma mark UITableViewDataSource & UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [UILabel new];
    label.text = section == 0 ? @"SDWebImage" : @"YYImage";
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    NSString *urlStr = self.dataList[indexPath.row];
    if (indexPath.section == 0) {
        // 使用sdwebimage 加载
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:urlStr]];
        
    }
    return cell;
}

#pragma mark - getter
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"UITableViewCell"];
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
