//
//  ValueChartsTableViewController.m
//  ZuoYou
//
//  Created by xueyongwei on 2016/11/28.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "ValueChartsTableViewController.h"
#import "UHCenterViewController.h"
#import "UIImage+Color.h"



@interface ValueChartsTableViewController ()
@property (nonatomic,strong)NSMutableArray *dataSource;
@property (nonatomic,strong)UILabel *noDataLabel;
@end

@implementation ValueChartsTableViewController
-(UILabel *)noDataLabel
{
    if (!_noDataLabel) {
        _noDataLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_W/2-100, 100, 200, 21)];
        _noDataLabel.textAlignment = NSTextAlignmentCenter;
        _noDataLabel.text = @"暂时无人上榜";
        _noDataLabel.font = [UIFont systemFontOfSize:14];
        _noDataLabel.textColor = [UIColor colorWithHexColorString:@"999999"];
    }
    return _noDataLabel;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexColorString:@"f4f4f4"];
    [self customTableView];
    [self customNavi];
}
-(void)customNavi{
    if (self.navigationController) {
        //如果不是导航的第一个VC，且还没有添加返回按钮才添加，才添加返回按钮
        if (self.navigationController.childViewControllers.count>1 && self.navigationItem.leftBarButtonItems.count<2) {
            UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                               target:nil action:nil];
            negativeSpacer.width = -3;//修正间隙
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(0, 0, 60, 30);
            btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            [btn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"back_click"] forState:UIControlStateHighlighted];
            [btn addTarget:self action:@selector(onBackClick:) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *leftBar = [[UIBarButtonItem alloc]initWithCustomView:btn];
            self.navigationItem.leftBarButtonItems = @[negativeSpacer,leftBar];
        }
        //导航栏标题的颜色和大小
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor colorWithHexColorString:@"333333"]}];
        
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageFromContextWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.shadowImage = [UIImage imageFromContextWithColor:[UIColor colorWithHexColorString:@"e6e6e6"]];
        self.navigationController.view.backgroundColor = [UIColor whiteColor];
        self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}
-(void)onBackClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)customTableView
{
    self.dataSource = [NSMutableArray new];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithHexColorString:@"f4f4f4"];
    self.tableView.estimatedRowHeight = 130;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    __weak typeof(self) wkSelf = self;
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [wkSelf.tableView.mj_footer endRefreshingWithNoMoreData];
    }];
    BangdanMjHeader *header = [BangdanMjHeader headerWithRefreshingTarget:self refreshingAction:@selector(prepareData)];
    // 隐藏时间
    header.frame = CGRectMake(0, 0, SCREEN_W, 60);
    header.lastUpdatedTimeLabel.hidden = YES;
    [header setTitle:[self refreshTextWith:self.chartsType] forState:MJRefreshStateIdle];
    [header setTitle:[self refreshTextWith:self.chartsType] forState:MJRefreshStatePulling];
    [header setTitle:[self refreshTextWith:self.chartsType] forState:MJRefreshStateRefreshing];
    header.stateLabel.font = [UIFont systemFontOfSize:11];
    header.stateLabel.textColor = [UIColor colorWithHexColorString:@"555555"];
    self.tableView.mj_header = header;
    [header beginRefreshing];
}
-(void)prepareData
{
    NSString *urlStr =[NSString stringWithFormat:@"%@%@",HeadUrl,@"/topCountdown"];
    NSDictionary *param = @{@"type":[self paramWith:self.chartsType]};
    if (self.chartsType == ChartsTypePraise_activity_rank) {
        urlStr = [urlStr stringByAppendingString:@"/tagActivity"];
        param = @{@"tagId":@(self.tagId)};
    }
    
    [XYWhttpManager XYWpost:urlStr parameters:param inView:nil sucess:^(id result) {
        [CoreSVP dismiss];
        if (result) {
            [self.dataSource removeAllObjects];
            NSArray *rspArr = result;
            if (rspArr) {
                for (NSDictionary *dic in rspArr) {
                    ChartsModel *model = [ChartsModel mj_objectWithKeyValues:dic];
                    [self.dataSource addObject:model];
                }
                [self.tableView reloadData];
            }
        }
        [self.tableView.mj_header endRefreshing];
    } failure:^(NSError *error) {
        [CoreSVP dismiss];
        [self.tableView.mj_header endRefreshing];
        CoreSVPCenterMsg(error.localizedDescription);
        DbLog(@"%@",error.localizedDescription);
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
    if (self.dataSource.count==0) {
        [self.tableView addSubview:self.noDataLabel];
    }else{
        [self.noDataLabel removeFromSuperview];
    }
    return self.dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ChartsModel *model = self.dataSource[indexPath.row];
    ChartsTableViewCell *cell;
    if (indexPath.row == 0) {
        cell = [ChartsTableViewCell dequeueReusableCellIn:tableView WithStyle:Charts1TableViewCell];
    }else if (indexPath.row ==1){
        cell = [ChartsTableViewCell dequeueReusableCellIn:tableView WithStyle:Charts2TableViewCell];
    }else if (indexPath.row ==2){
        cell = [ChartsTableViewCell dequeueReusableCellIn:tableView WithStyle:Charts3TableViewCell];
    }else{
        cell = [ChartsTableViewCell dequeueReusableCellIn:tableView WithStyle:Charts0TableViewCell];
        cell.flagNumberLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row+1];
    }
    cell.ModelStyle = self.chartsType;
    cell.chartsModel = model;
    DbLog("%d",self.chartsType);
    
    cell.careClickBlock = ^{
        
    };
    cell.userIconClickBlock = ^(NSNumber *userId){
        DbLog(@"%@",userId);
        UHCenterViewController *uhvc = [[UHCenterViewController alloc]init];
        uhvc.mid = userId.integerValue;
        uhvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:uhvc animated:YES];
    };
    return cell;
}
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.row==0) {
//        return 175;
//        //            return 150;
//    }else if (indexPath.row<3){
//        return 130;
//    }
//    return 65;
//}










-(NSString *)paramWith:(ChartsType)type{
    switch (type) {
        case ChartsTypeWin_week:
            return @"win_week";
            break;
            
        case ChartsTypeBe_praised_week:
            return @"be_praised_week";
            break;
        case ChartsTypeFans_total:
            return @"fans_total";
            break;
        case ChartsTypePraise_win_rate:
            return @"praise_win_rate";
            break;
        case ChartsTypePraise_activity_rank:
            return @"praise_win_rate";
            break;
    }
}
-(NSString *)refreshTextWith:(ChartsType)type{
    switch (type) {
        case ChartsTypeWin_week:
            return @"上周胜利场数排行";
            break;
            
        case ChartsTypeBe_praised_week:
            return @"上周获赞总数排行";
            break;
        case ChartsTypeFans_total:
            return @"粉丝数排行，周日刷新";
            break;
        case ChartsTypePraise_win_rate:
            return @"点赞胜率排行，周日刷新";
            break;
        case ChartsTypePraise_activity_rank:
            return @"活动期间获胜场次排行";
            break;
    }
}

@end
