//
//  ShouYiTableViewController.m
//  HDJ
//
//  Created by xueyongwei on 16/6/14.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "ShouYiTableViewController.h"

@interface ShouYiTableViewController ()
@property (nonatomic,strong)NSMutableArray *dataSource;
@end

@implementation ShouYiTableViewController
{
    ShouYiHdView *Hdview;
}
-(NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [NSMutableArray new];
        [_dataSource addObject:[self modelWith:100 org:1 now:1]];
        [_dataSource addObject:[self modelWith:600 org:6 now:6]];
        [_dataSource addObject:[self modelWith:1800 org:18 now:18]];
        [_dataSource addObject:[self modelWith:3000 org:30 now:29.40]];
        [_dataSource addObject:[self modelWith:6800 org:68 now:65.96]];
        [_dataSource addObject:[self modelWith:12800 org:128 now:122.88]];
        [_dataSource addObject:[self modelWith:32800 org:328 now:311.60]];
        [_dataSource addObject:[self modelWith:64800 org:648 now:615.6]];
    }
    return _dataSource;
}
-(ShouyiModel*)modelWith:(NSInteger)beans org:(NSInteger)org now:(float)now
{
    ShouyiModel *model = [ShouyiModel new];
    model.goldBenas = beans;
    model.salesOrg = org;
    model.salesNow = now;
    return model;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"收益页面"];
    Hdview.yueNub = 0.00;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"收益";
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsCompact];
//    self.automaticallyAdjustsScrollViewInsets = NO;
    
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
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChongzhiTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChongzhiTableViewCellID"];
    if (!cell) {
        cell = (ChongzhiTableViewCell*)[[[NSBundle mainBundle]loadNibNamed:@"ChongzhiTableViewCell" owner:self options:nil]lastObject ];
    }
    ShouyiModel *model = self.dataSource[indexPath.row];
    cell.douziLabel.text = [NSString stringWithFormat:@"%ld",(long)model.goldBenas];
    cell.moneyLabel.text = [NSString stringWithFormat:@"¥%.2f",model.salesNow];
    NSString *oldPrice = [NSString stringWithFormat:@"原价:%ld元",(long)model.salesOrg];
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:oldPrice];
    
    NSUInteger length = [oldPrice length];
    [attri addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(3, length-3)];
    [attri addAttribute:NSStrikethroughColorAttributeName value:[UIColor colorWithHexColorString:@"888888"] range:NSMakeRange(3, length-3)];
    cell.youhuiLabel.attributedText = attri;
    cell.YouHui = YES;
    if (indexPath.row == self.dataSource.count-1) {
        cell.fengeLabelH.constant = 0;
    }else{
        cell.fengeLabelH.constant = SINGLE_LINE_WIDTH;
    }
    return cell;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    Hdview = [[[NSBundle mainBundle]loadNibNamed:@"ShouYiHdView" owner:self options:nil]lastObject];
    
    return  Hdview;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 222;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CoreSVPCenterMsg(@"余额不足，无法兑换");
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    return;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}


@end
