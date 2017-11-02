//
//  LiwuXiaoxiViewController.m
//  HDJ
//
//  Created by xueyongwei on 16/7/27.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "LiwuXiaoxiViewController.h"
#import "AppDelegate.h"
#import "CoreTextView.h"
@interface LiwuXiaoxiViewController ()
@property (nonatomic,strong)NSMutableArray *dataSource;
//@property (nonatomic,strong)NSMutableDictionary *userDataDic;
@property (nonatomic,assign) int currentPage;
@property (nonatomic,strong)UILabel *noDataLabel;
@end

@implementation LiwuXiaoxiViewController
#pragma mark ---🐷懒加载
-(UILabel *)noDataLabel
{
    if (!_noDataLabel) {
        _noDataLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_W/2-100, SCREEN_H/3, 200, 21)];
        _noDataLabel.textAlignment = NSTextAlignmentCenter;
        _noDataLabel.text = @"暂时还没有收到礼物哦~";
        _noDataLabel.font = [UIFont systemFontOfSize:14];
        _noDataLabel.textColor = [UIColor colorWithHexColorString:@"999999"];
    }
    return _noDataLabel;
}
//-(NSMutableDictionary *)userDataDic
//{
//    if (!_userDataDic) {
//        _userDataDic = [NSMutableDictionary new];
//    }
//    return _userDataDic;
//}
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
//    [self prepareData:1];

    self.navigationItem.title = @"礼物";
    [self customTableView];
    // 用于缓存cell高度
//    self.heightDic = [[NSMutableDictionary alloc] init];
}

-(void)customTableView
{
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 120;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
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
            for (NSDictionary *dic in (NSArray*)model.body) {
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
    DbLog(@"%ld",(long)indexPath.row);
    MsgUserContentVersusCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MsgUserContentVersusCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"MsgUserContentVersusCell" owner:self options:nil]lastObject];
    }
    XIaoxiGitfModel *model = self.dataSource[indexPath.row];
    XiaoxiBodyModel *body = model.body;
    xiaoxiGiftExtras *extra = model.extras;
    cell.ctntLabel.attributedText = body.contenText;
    [cell.versusView setTagName:extra.formaterVersusTagName pkId:@(extra.versusId) leftUserId:@(extra.redMid) rightUserID:@(extra.blueMid)];
    [UserInfoManager setNameLabel:cell.userNaleLabel headImageV:cell.iconImgV corverImageV:cell.iconImgV with:@(extra.mid)];
    
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
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XIaoxiGitfModel *model = self.dataSource[indexPath.row];
    //    XiaoxiBodyModel *body = model.body;
    xiaoxiGiftExtras *extra = model.extras;
    PKDetailViewController *pkvc = [[PKDetailViewController alloc]initWithNibName:@"PKDetailViewController" bundle:nil];
    pkvc.pkId = extra.versusId;
    [self.navigationController pushViewController:pkvc animated:YES];
    
}

//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    DbLog(@"%ld",(long)indexPath.row);
//    
//    NSString *hiStr = [self.heightDic objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
//    if (!hiStr) {
//        return 50;
//    }
//    return hiStr.floatValue;
//}

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
