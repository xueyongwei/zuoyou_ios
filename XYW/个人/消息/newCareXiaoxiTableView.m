//
//  newCareXiaoxiTableView.m
//  ZuoYou
//
//  Created by xueyongwei on 16/9/27.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "newCareXiaoxiTableView.h"
#import "SocketManager.h"
@interface newCareXiaoxiTableView()
@property (nonatomic,strong)NSMutableArray *dataSource;
@property (nonatomic,strong)UILabel *noDataLabel;
@property (nonatomic,assign)NSInteger currentPage;
@end
@implementation newCareXiaoxiTableView
#pragma mark ---🐷懒加载
-(UILabel *)noDataLabel
{
    if (!_noDataLabel) {
        _noDataLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_W/2-100, SCREEN_H/3, 200, 21)];
        _noDataLabel.textAlignment = NSTextAlignmentCenter;
        _noDataLabel.text = @"暂时还没有收到新的关注哦~";
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
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self remoreNotiObser];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = [NSMutableArray new];
    self.currentPage = 1;
//    [self prepareData:1];
    
    
    self.navigationItem.title = @"新的关注";
    
    [self customTableView];
}

-(void)customTableView
{
    self.tableView.rowHeight = 65;
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    __weak typeof(self) wkSelf = self;
    BangdanMjHeader *header = [BangdanMjHeader headerWithRefreshingBlock:^{
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
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView.mj_header endRefreshing];
    });
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
            xiaoxiNewCareModel *model = [xiaoxiNewCareModel mj_objectWithKeyValues:dic];
            [self.dataSource addObject:model];
        }
        [CoreSVP dismiss];
        [self.tableView reloadData];
        self.currentPage++;
    }else{
        if (self.currentPage <2) {
            [self.tableView.mj_header endRefreshing];
        }else{
            [self.tableView.mj_footer endRefreshing];
        }
    }
}
#pragma mark ---😊tableView的代理方法
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
    //    return 10;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MsgNewCareTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MsgNewCareTableCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"MsgNewCareTableCell" owner:self options:nil]lastObject];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onUserIconClick:)];
        cell.userIcon.userInteractionEnabled = YES;
        [cell.userIcon addGestureRecognizer:tap];
    }
    xiaoxiNewCareModel *model = self.dataSource[indexPath.row];
    
    [UserInfoManager setNameLabel:cell.userName headImageV:cell.userIcon corverImageV:cell.userCorver with:@(model.extras.createdBy)];
    cell.timeLabel.text = [model.body howLongStr];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    xiaoxiNewCareModel *model = self.dataSource[indexPath.row];
    UHCenterViewController *uhVC = [[UHCenterViewController alloc]init];
    uhVC.mid =model.extras.createdBy;
    
    [self.navigationController pushViewController:uhVC animated:YES];
    
}
-(void)onUserIconClick:(UITapGestureRecognizer *)recognizer
{
    UHCenterViewController *uhvc = [[UHCenterViewController alloc]init];
    uhvc.mid = recognizer.view.tag;
    [self.navigationController pushViewController:uhvc animated:YES];
}
@end
