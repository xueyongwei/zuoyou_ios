//
//  XiaoxiTopViewController.m
//  HDJ
//
//  Created by xueyongwei on 16/7/25.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "XiaoxiTopViewController.h"
#import "AppDelegate.h"
#import "UHCenterViewController.h"
@interface XiaoxiTopViewController ()
@property (nonatomic,strong)NSMutableArray *dataSource;
@property (nonatomic,strong)NSMutableDictionary *heightDic;
@property (nonatomic,assign) int currentPage;
@property (nonatomic,strong)UILabel *noDataLabel;
@end

@implementation XiaoxiTopViewController

#pragma mark ---🐷懒加载
-(UILabel *)noDataLabel
{
    if (!_noDataLabel) {
        _noDataLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_W/2-100, SCREEN_H/3, 200, 21)];
        _noDataLabel.textAlignment = NSTextAlignmentCenter;
        _noDataLabel.text = @"暂时还没有消息~";
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
    self.currentPage = 1;
    [self prepareData:self.currentPage];
    self.navigationItem.title = @"小豆说";
    [self customTableView];
    // 用于缓存cell高度
    self.heightDic = [[NSMutableDictionary alloc] init];
    
    // 注册加载完成高度的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti:) name:@"WEBVIEW_HEIGHT" object:nil];
    // Do any additional setup after loading the view from its nib.
}

-(void)customTableView
{
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 120;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView reloadData];
    __weak typeof(self) wkSelf = self;
    BangdanMjHeader *header = [BangdanMjHeader headerWithRefreshingBlock:^{
        wkSelf.currentPage = 1;
        [wkSelf prepareData:self.currentPage];
    }];
    header.frame = CGRectMake(0, 0, SCREEN_W, 60);
    self.tableView.mj_header = header;
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [wkSelf prepareData:self.currentPage];
    }];
}
#pragma mark ---🎈请求数据
-(void)prepareData:(NSInteger)page
{
    /*{
     uri:"system/session/loadMsg?pn="
     header:{
     messageSessionKey:'private/dialog_${mid}_${mid}'
     }
     }
     */
    NSString *msg= [NSString stringWithFormat:@"{uri:\"system/session/loadMsg?pn=%ld\",headers:{messageSessionKey:\"%@\"}}",(long)page,self.model.messageSessionKey];
    [[SocketManager defaultManager] sendMsg:msg];
    CoreSVPLoading(@"加载中...", NO);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView.mj_header endRefreshing];
        [CoreSVP dismiss];
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
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
    NSDictionary *userInfo = noti.userInfo;
    WSmessageModel *model = [userInfo objectForKey:@"model"];
    if ([model.body isKindOfClass:[NSArray class]]) {
        NSArray *bodys = (NSArray*)model.body;
        if (bodys.count==0) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
            return;
        }
        if (self.currentPage==1) {
            [self.dataSource removeAllObjects];
        }
        for (NSDictionary *dic in bodys) {
            DbLog(@"%@",dic);
            XIaoxiGitfModel *model = [XIaoxiGitfModel mj_objectWithKeyValues:dic];
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
    MsgDetailTopTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MsgDetailTopTableViewCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"MsgDetailTopTableViewCell" owner:self options:nil]lastObject];
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onUserIconClick:)];
//        cell.userIconImgV.userInteractionEnabled = YES;
//        [cell.userIconImgV addGestureRecognizer:tap];
    }
    XIaoxiGitfModel *model = self.dataSource[indexPath.row];
    XiaoxiBodyModel *body = model.body;
    cell.content = body.content;
    cell.tag = indexPath.row;
    cell.userNameLabel.text = [model.body howLongStr];
    return cell;
}
//更新高度
- (void)noti:(NSNotification *)sender
{
    MsgDetailTopTableViewCell *cell = [sender object];
    
    if (![self.heightDic objectForKey:[NSString stringWithFormat:@"%ld",(long)cell.tag]]||[[self.heightDic objectForKey:[NSString stringWithFormat:@"%ld",(long)cell.tag]] floatValue] != cell.frame.size.height)
    {
        [self.heightDic setObject:[NSNumber numberWithFloat:cell.frame.size.height] forKey:[NSString stringWithFormat:@"%ld",(long)cell.tag]];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:cell.tag inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *hiStr = [self.heightDic objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
    
    return hiStr.floatValue;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)onUserIconClick:(UITapGestureRecognizer *)recognizer
{
    UHCenterViewController *uhvc = [[UHCenterViewController alloc]init];
    uhvc.mid = recognizer.view.tag;
    [self.navigationController pushViewController:uhvc animated:YES];
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
