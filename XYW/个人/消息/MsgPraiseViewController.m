//
//  MsgPraiseViewController.m
//  ZuoYou
//
//  Created by xueyongwei on 2016/11/29.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "MsgPraiseViewController.h"
#import "SocketManager.h"
#import "MsgPraiseModel.h"

#import "MsgUserContentVersusCell.h"

#import "PKDetailViewController.h"
#import "UHCenterViewController.h"


@interface MsgPraiseViewController ()
@property (nonatomic,strong)UILabel *noDataLabel;
@property (nonatomic,assign)NSInteger currentPage;
@end

@implementation MsgPraiseViewController

#pragma mark ---🐷懒加载
-(UILabel *)noDataLabel
{
    if (!_noDataLabel) {
        _noDataLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_W/2-100, SCREEN_H/3, 200, 21)];
        _noDataLabel.textAlignment = NSTextAlignmentCenter;
        _noDataLabel.text = @"暂时还没有赞哦~";
        _noDataLabel.font = [UIFont systemFontOfSize:14];
        _noDataLabel.textColor = [UIColor colorWithHexColorString:@"999999"];
    }
    return _noDataLabel;
}

#pragma mark ---控制器方法
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self addNotiObser];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self remoreNotiObser];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self customTableView];
}
-(void)customTableView
{
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 65;
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    __weak typeof(self) wkSelf = self;
    BangdanMjHeader *header = [BangdanMjHeader headerWithRefreshingBlock:^{
        DbLog(@"请求一次");
        wkSelf.currentPage = 1;
        [wkSelf prepareData:self.currentPage];
    }];
    header.frame = CGRectMake(0, 0, SCREEN_W, 60);
    self.tableView.mj_header = header;
    [header beginRefreshing];
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [wkSelf prepareData:self.currentPage];
    }];
    
}
#pragma mark ---🎈请求数据
-(void)prepareData:(NSInteger)page
{
    
    NSString *msg= [NSString stringWithFormat:@"{uri:\"system/session/loadMsg?pn=%ld\",headers:{messageSessionKey:\"%@\"}}",(long)page,self.model.messageSessionKey];
    [[SocketManager defaultManager] sendMsg:msg];
    
}
#pragma mark --🎈通知中心
-(void)addNotiObser
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(systemsessionloadMsgHandle:) name:@"systemsessionloadMsg" object:nil];
}
-(void)remoreNotiObser
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"systemsessionloadMsg" object:nil];
}
-(void)systemsessionloadMsgHandle:(NSNotification *)noti
{
    DbLog(@"%@",noti.userInfo);
    NSDictionary *userInfo = noti.userInfo;
    WSmessageModel *model = [userInfo objectForKey:@"model"];
    if ([model.body isKindOfClass:[NSArray class]]) {
        NSArray *bodys = (NSArray*)model.body;
        
        if (self.currentPage<2) {
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer resetNoMoreData];
            [self.dataSource removeAllObjects];
        }else{
            if (bodys.count>0) {
                [self.tableView.mj_footer endRefreshing];
            }else{
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
        }
        
        for (NSDictionary *dic in bodys) {
            DbLog(@"%@",dic);
            MsgPraiseModel *model = [MsgPraiseModel mj_objectWithKeyValues:dic];
            [self.dataSource addObject:model];
        }
        self.currentPage++;
        [self.tableView reloadData];
        
    }else{
        if (self.currentPage <2) {
            [self.tableView.mj_header endRefreshing];
        }else{
            [self.tableView.mj_footer endRefreshing];
        }
    }
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.dataSource.count==0) {
        [self.tableView addSubview:self.noDataLabel];
    }else{
        if (self.noDataLabel.superview) {
            [self.noDataLabel removeFromSuperview];
        }
    }
    return self.dataSource.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MsgPraiseModel *model = self.dataSource[indexPath.row];
    MsgUserContentVersusCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MsgUserContentVersusCell"];
    if (!cell) {
        DbLog(@"!!!!!!!!!!!!!!!!!!!!!!创建新的CELL");
        cell = [[[NSBundle mainBundle]loadNibNamed:@"MsgUserContentVersusCell" owner:self options:nil]lastObject];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onUserIconClick:)];
        cell.iconImgV.userInteractionEnabled = YES;
        [cell.iconImgV addGestureRecognizer:tap];
    }
    MsgModelBody *body = model.body;
    MsgPraiseExtras *extra = model.extras;
    cell.ctntLabel.attributedText = body.contenText;
    
    [cell.versusView setTagName:extra.formaterVersusTagName pkId:extra.versusId leftUserId:extra.redMid rightUserID:extra.blueMid];
    
    [UserInfoManager setNameLabel:cell.userNaleLabel headImageV:cell.iconImgV corverImageV:cell.iconCorver with:extra.mid];
    
    cell.userNaleLabel.textColor = [UIColor colorWithHexColorString:@"333333"];
    if ([extra.contestantType isEqualToString:@"BLUE"]) {
        cell.iconCorver.image = [UIImage imageNamed:@"blueCorver"];
        cell.userNaleLabel.textColor = [UIColor colorWithHexColorString:@"03a9f3"];
    }else if([extra.contestantType isEqualToString:@"RED"]){
        cell.iconCorver.image = [UIImage imageNamed:@"redCorver"];
        cell.userNaleLabel.textColor = [UIColor colorWithHexColorString:@"f44236"];
    }
    cell.timeLabel.text = [model.body howLongStr];
    
    return cell;
}
-(void)onUserIconClick:(UITapGestureRecognizer *)recognizer
{
    UHCenterViewController *uhvc = [[UHCenterViewController alloc]init];
    uhvc.mid = recognizer.view.tag;
    [self.navigationController pushViewController:uhvc animated:YES];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MsgPraiseModel *model = self.dataSource[indexPath.row];
    PKDetailViewController *detailVC = [[PKDetailViewController alloc]initWithNibName:@"PKDetailViewController" bundle:nil];
    detailVC.pkId = model.extras.versusId.integerValue;
    [self.navigationController pushViewController:detailVC animated:YES];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
