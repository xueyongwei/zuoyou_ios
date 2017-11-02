//
//  BlackListViewController.m
//  ZuoYou
//
//  Created by xueyognwei on 2017/2/10.
//  Copyright © 2017年 xueyongwei. All rights reserved.
//

#import "BlackListViewController.h"
#import "BlackListTableViewCell.h"
#import "UHCenterViewController.h"

@interface BlackUserModel:NSObject
@property (nonatomic,strong)NSNumber *userId;
@property (nonatomic,assign)BOOL haveRevoke;
@end
@implementation BlackUserModel
@end

@interface BlackListViewController ()<BlackListTableViewCellDelegate>
@property (nonatomic,assign)NSInteger currentPage;
@property (nonatomic,strong)UILabel *noDataLabel;
@end

@implementation BlackListViewController
-(UILabel *)noDataLabel
{
    if (!_noDataLabel) {
        _noDataLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_W/2-100, SCREEN_H/3, 200, 21)];
        _noDataLabel.textAlignment = NSTextAlignmentCenter;
        _noDataLabel.text = @"还没有人被你加入黑名单";
        _noDataLabel.font = [UIFont systemFontOfSize:14];
        _noDataLabel.textColor = [UIColor colorWithHexColorString:@"999999"];
    }
    return _noDataLabel;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentPage = 1;
    self.navigationItem.title = @"黑名单";
    [self prepareData:self.currentPage];
    [self customTableView];
    // Do any additional setup after loading the view.
}
-(void)customTableView{
    __weak typeof(self) wkSelf = self;
    BangdanMjHeader *header = [BangdanMjHeader headerWithRefreshingBlock:^{
        wkSelf.currentPage = 1;
        [wkSelf prepareData:wkSelf.currentPage];
    }];
    header.frame = CGRectMake(0, 0, SCREEN_W, 60);
    self.tableView.mj_header = header;
    //    [header beginRefreshing];
    self.tableView.mj_footer = [MJRefreshBackStateFooter footerWithRefreshingBlock:^{
        [wkSelf prepareData:wkSelf.currentPage];
    }];
}
#pragma mark --数据的获取
-(void)prepareData:(NSInteger)page{
    
//    /v1/social/blacklist?pn=
    NSString *uri = [NSString stringWithFormat:@"%@/social/blacklist",HeadUrl];
    NSDictionary *param = @{@"pn":@(page)};
    [XYWhttpManager XYWpost:uri parameters:param inView:nil sucess:^(id result) {
        DbLog(@"%@",result);
        NSArray *resultArr = (NSArray *)result;
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        
        if (resultArr) {
            if (page == 1) {
                [self.dataSource removeAllObjects];
            }
            for (NSNumber *userId in resultArr) {
                BlackUserModel *model = [BlackUserModel new];
                model.userId = userId;
                model.haveRevoke = NO;
                [self.dataSource addObject:model];
            }
            self.currentPage++;
        }else{
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        DbLog(@"%@",error.localizedDescription);
    }];
}
#pragma mark --tableView代理
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.dataSource.count ==0) {
        [self.tableView addSubview:self.noDataLabel];
    }else{
        [self.noDataLabel removeFromSuperview];
    }
    return self.dataSource.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BlackListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BlackListTableViewCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"BlackListTableViewCell" owner:self options:nil]lastObject];
        cell.delegate = self;
    }
    BlackUserModel *user = self.dataSource[indexPath.row];
    cell.actionBtn.selected = user.haveRevoke;
    [UserInfoManager setNameLabel:cell.userNameLabel headImageV:cell.iconImgV memberRoul:YES with:user.userId];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BlackUserModel *user = self.dataSource[indexPath.row];
    UHCenterViewController *uhvc = [[UHCenterViewController alloc]init];
    uhvc.mid = user.userId.integerValue;
    [self.navigationController pushViewController:uhvc animated:YES];
    
}
-(void)onActionBtnClick:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    BlackUserModel *user = self.dataSource[indexPath.row];
    BlackListTableViewCell *thisCell = (BlackListTableViewCell*)cell;
//    if (user.haveRevoke) {
//        
//    }else{
//        
//    }
    [self requestToChangeBlackList:user];
    user.haveRevoke = !user.haveRevoke;
    thisCell.actionBtn.selected = user.haveRevoke;
    NSString *colorStr = user.haveRevoke?@"ff4a4b":@"999999";
    thisCell.actionBtn.layer.borderColor = [UIColor colorWithHexColorString:colorStr].CGColor;
}
#pragma mark -- API
-(void)requestToChangeBlackList:(BlackUserModel *)user{
    NSString *path = @"";
    if (user.haveRevoke) {//重新加入
        path = @"/social/addBlacklist";
    }else{//移除黑名单
        path = @"/social/removeBlacklist";
    }
    NSString *uri = [NSString stringWithFormat:@"%@%@",HeadUrl,path];
    NSDictionary *param = @{@"mid":user.userId};
    [XYWhttpManager XYWpost:uri parameters:param inView:nil sucess:^(id result) {
        DbLog(@"%@",result);
    } failure:^(NSError *error) {
        DbLog(@"%@",error.localizedDescription);
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
