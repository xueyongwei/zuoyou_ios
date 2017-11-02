//
//  UHFansTableView.m
//  ZuoYou
//
//  Created by xueyongwei on 16/10/18.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "UHFansTableView.h"

@implementation UHFansTableView

-(UILabel *)noDataLabel
{
    if (!_noDataLabel) {
        _noDataLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_W/2-100, 100, 200, 21)];
        _noDataLabel.textAlignment = NSTextAlignmentCenter;
        _noDataLabel.text = @"还没有粉丝哦~";
        _noDataLabel.font = [UIFont systemFontOfSize:14];
        _noDataLabel.textColor = [UIColor colorWithHexColorString:@"999999"];
        [self customView];
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
-(void)customView
{
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    __weak typeof(self) wkSelf = self;
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [wkSelf prepareDataWithPg:self.currentPage];
    }];
    
}
-(void)prepareData
{
    self.currentPage =1;
    [self prepareDataWithPg:1];
}
-(void)prepareDataWithPg:(NSInteger)page
{
    //    /v1/social/followlist?mid=1&pn=1
    NSString *urlStr = [NSString stringWithFormat:@"%@/social/fanslist",HeadUrl];
    NSDictionary *param = @{@"mid":self.userID,@"pn":@(page)};
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataSource.count ==0) {
        [self.tableView addSubview:self.noDataLabel];
    }else{
        [self.noDataLabel removeFromSuperview];
    }
    return self.dataSource.count;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UHSocialInfoModel *model = self.dataSource[indexPath.row];
    UHCaresTableViewCell *thisCell = (UHCaresTableViewCell*)cell;
    thisCell.iconImgV.tag = (long)model.mid;
    
    [UserInfoManager setNameLabel:thisCell.userNameLabel headImageV:thisCell.iconImgV corverImageV:thisCell.iconCorver with:@(model.mid)];
    
//    [self setNameLabel:thisCell.userNameLabel headImageV:thisCell.iconImgV with:model.mid];

    if ([UserInfoManager isMeOfID:model.mid]) {
        thisCell.guanzhuBtn.hidden = YES;
    }else{
        thisCell.guanzhuBtn.hidden = NO;
        thisCell.guanzhuBtn.tag = model.mid;
        NSInteger careType = model.isFollow?model.isFans?2:1:0;
        [self setCareType:careType Btn:thisCell.guanzhuBtn];
    }

}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UHCaresTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UHCaresTableViewCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"UHCaresTableViewCell" owner:self options:nil]lastObject];
        cell.delegate = self;
    }
    cell.userNameLabel.text = @"";
    cell.iconImgV.image = [UIImage imageNamed:@"1"];
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
//    UHCenterViewController *uhVC = [[UHCenterViewController alloc]init];
//    uhVC.mid = model.mid;
    self.block(@{@"action":@"push",@"class":@"UHCenterViewController",@"calssID":@(model.mid)});
    
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

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}
#pragma mark ---代理方法

-(void)reloadNewWorkDataSource
{
    [self prepareDataWithPg:1];
    [self.delegate reloadTabNumbData];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
