//
//  UHFansTableViewController.m
//  ZuoYou
//
//  Created by xueyongwei on 16/9/18.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "UHFansTableViewController.h"
#import "UHCenterViewController.h"

@interface UHFansTableViewController ()
@property (nonatomic,strong)NSMutableArray *dataSource;
@property (nonatomic,assign)NSInteger currentPage;
@property (nonatomic,strong)UILabel *noDataLabel;
@property (nonatomic,strong)UIView *headerView;
@end

@implementation UHFansTableViewController
-(UIView *)headerView
{
    if (!_headerView) {
        _headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_W, 10)];
        _headerView.backgroundColor = [UIColor colorWithHexColorString:@"f4f4f4"];
    }
    return _headerView;
}
-(UILabel *)noDataLabel
{
    if (!_noDataLabel) {
        _noDataLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_W/2-100, 100, 200, 21)];
        _noDataLabel.textAlignment = NSTextAlignmentCenter;
        _noDataLabel.text = @"还没有粉丝哦~";
        _noDataLabel.font = [UIFont systemFontOfSize:14];
        _noDataLabel.textColor = [UIColor colorWithHexColorString:@"999999"];
    }
    return _noDataLabel;
}
-(NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [NSMutableArray new];
    }
    return _dataSource;
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self prepareDataWithPg:1];
 
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customView];
    self.currentPage = 1;
    __weak typeof(self) wkSelf = self;
    MJRefreshAutoStateFooter *footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
        [wkSelf prepareDataWithPg:self.currentPage];
    }];
    [footer setTitle:@"" forState:MJRefreshStateIdle];
    
    self.tableView.mj_footer = footer;
}
-(void)customView
{
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}
-(void)prepareDataWithPg:(NSInteger)page
{
    //    /v1/social/followlist?mid=1&pn=1
    NSString *urlStr = [NSString stringWithFormat:@"%@/social/fanslist",HeadUrl];
    NSDictionary *param = @{@"mid": @(self.mid),@"pn":@(page)};
    [XYWhttpManager XYWpost:urlStr parameters:param inView:nil sucess:^(id result) {
        DbLog(@"%@",result);
        if (page <= 1) {
            [self.tableView.mj_header endRefreshing];
            if ([(NSArray *)result count]>0){
                [self.dataSource removeAllObjects];
            }
        }else{
            if ([(NSArray *)result count]>0) {
                [self.tableView.mj_footer endRefreshing];
            }else{
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
                return ;
            }
            
        }
        if ([result isKindOfClass:[NSArray class]]) {
            for (NSDictionary *social in result) {
                UHSocialInfoModel *model = [UHSocialInfoModel mj_objectWithKeyValues:social];
                [self.dataSource addObject:model];
            }
            self.currentPage ++;
            [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
        if (page <= 1) {
            [self.tableView.mj_header endRefreshing];
        }else{
            [self.tableView.mj_footer endRefreshing];
        }
    }];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataSource.count ==0) {
        [self.tableView addSubview:self.noDataLabel];
        [(MJRefreshAutoStateFooter*)self.tableView.mj_footer setTitle:@"" forState:MJRefreshStateNoMoreData];
    }else{
        [(MJRefreshAutoStateFooter*)self.tableView.mj_footer setTitle:@"别拉啦，全都给你啦～" forState:MJRefreshStateNoMoreData];
        [self.noDataLabel removeFromSuperview];
    }
    return self.dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UHCaresTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UHCaresTableViewCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"UHCaresTableViewCell" owner:self options:nil]lastObject];
        cell.delegate = self;
    }
    UHSocialInfoModel *model = self.dataSource[indexPath.row];
    cell.iconImgV.tag = model.mid;
    cell.guanzhuBtn.tag = model.mid;
    
    [UserInfoManager setNameLabel:cell.userNameLabel headImageV:cell.iconImgV corverImageV:cell.iconCorver with:@(model.mid)];
    NSInteger careType = model.isFollow?model.isFans?2:1:0;
    [self setCareType:careType Btn:cell.guanzhuBtn];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UHSocialInfoModel *model = self.dataSource[indexPath.row];
    UHCenterViewController *uhVC = [[UHCenterViewController alloc]init];
    uhVC.mid = model.mid;
    [self.navigationController pushViewController:uhVC animated:YES];
}

-(void)setCareType:(NSInteger)type Btn:(UIButton *)guanzhuBtn
{
    switch (type) {
        case 0:
        {
            [guanzhuBtn setTitle:@"关注" forState:UIControlStateNormal];
            [guanzhuBtn setTitleColor:[UIColor colorWithHexColorString:@"ff4a4b"] forState:UIControlStateNormal];
            guanzhuBtn.layer.borderColor = [UIColor colorWithHexColorString:@"ff4a4b"].CGColor;
            guanzhuBtn.selected = NO;
        }
            break;
        case 1:
        {
            [guanzhuBtn setTitle:@"已关注" forState:UIControlStateNormal];
            [guanzhuBtn setTitleColor:[UIColor colorWithHexColorString:@"999999"] forState:UIControlStateNormal];
            guanzhuBtn.layer.borderColor = [UIColor colorWithHexColorString:@"999999"].CGColor;
            guanzhuBtn.selected = YES;
        }
            break;
        case 2:
        {
            [guanzhuBtn setTitle:@"互相关注" forState:UIControlStateNormal];
            [guanzhuBtn setTitleColor:[UIColor colorWithHexColorString:@"999999"] forState:UIControlStateNormal];
            guanzhuBtn.layer.borderColor = [UIColor colorWithHexColorString:@"999999"].CGColor;
            guanzhuBtn.selected = YES;
        }
            break;
        default:
            break;
    }
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.headerView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}
#pragma mark ---代理方法

-(void)reloadNewWorkDataSource
{
    [self prepareDataWithPg:1];
}


@end
