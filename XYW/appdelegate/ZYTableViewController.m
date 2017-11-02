//
//  ZYTableViewController.m
//  ZuoYou
//
//  Created by xueyongwei on 16/10/28.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "ZYTableViewController.h"

@interface ZYTableViewController ()
@property (nonatomic,assign) UITableViewStyle tableViewStyle;
@end

@implementation ZYTableViewController
- (instancetype)initWithStyle:(UITableViewStyle)style
{
    if (self = [super init]) {
        self.tableViewStyle = style;
    }
    return self;
}
-(NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [NSMutableArray new];
    }
    return _dataSource;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self ZYTableViewCustomTableView:self.tableViewStyle];
}
-(void)ZYTableViewCustomTableView:(UITableViewStyle)style
{
    self.tableView = [[UITableView alloc]initWithFrame:CGRectZero style:style];
    [self.view addSubview:self.tableView];
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.left.equalTo(self.view);
    }];
    self.tableView.backgroundColor = [UIColor colorWithHexColorString:@"f4f4f4"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
}
@end
