//
//  IncomeDetailViewController.m
//  ZuoYou
//
//  Created by xueyognwei on 16/12/21.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "IncomeDetailViewController.h"
#import "IncomeDetailTableViewCell.h"
@implementation withdrawHostoryModel
+(NSDictionary*)mj_replacedKeyFromPropertyName
{
    return @{@"withdrawId":@"id"};
}
@end

@interface IncomeDetailViewController ()

@end

@implementation IncomeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"收益明细";
    [self customTableView];
    // Do any additional setup after loading the view.
}
-(void)customTableView
{
    self.tableView.rowHeight = 118;
    [self.tableView.mj_header beginRefreshing];

}
#pragma mark 网络数据处理
-(void)prepareData
{
    NSMutableDictionary *param = [NSMutableDictionary new];
    __weak typeof(self) wkSelf = self;
    [self requestListDataWithShortUrlStr:@"/finance/profitHistory" param:param resultResolver:^(NSArray *result) {
        DbLog(@"%@",result);
        for (NSDictionary *dic in result) {
            withdrawHostoryModel *model = [withdrawHostoryModel mj_objectWithKeyValues:dic];
            [wkSelf.dataSource addObject:model];
        }
        [wkSelf.tableView reloadData];
    } error:^(NSNumber *errorCode, NSString *errMsg) {
        
    }];
}
#pragma mark tableView的代理
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IncomeDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IncomeDetailTableViewCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"IncomeDetailTableViewCell" owner:self options:nil]lastObject];
    }
    withdrawHostoryModel *model = self.dataSource[indexPath.row];
    [cell.versusView setTagName:model.tagName pkId:model.versusId leftUserId:model.redMid rightUserID:model.blueMid];
    cell.amountLabel.text = [NSString stringWithFormat:@"金额：%.2f元",model.amount.floatValue] ;
    cell.timeLabel.text = [NSString stringWithFormat:@"时间：%@",[model.createdDate substringToIndex:10]];
    [self setBtn:cell.stateBtn stringWithType:model.status];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark 私有方法
-(void)setBtn:(UIButton *)btn stringWithType:(NSString *)state
{
    if ([state isEqualToString:@"UNAPPROVED"]) {
        btn.selected = NO;
        btn.enabled = YES;
    }else if ([state isEqualToString:@"APPROVED"])
    {
        btn.enabled = NO;
    }else if ([state isEqualToString:@"REFUSED"])
    {
        btn.selected = YES;
        btn.enabled = YES;
    }else{
        CoreSVPCenterMsg(@"部分功能需要升级才能使用！");
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
