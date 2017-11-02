//
//  SystemNotiViewController.m
//  ZuoYou
//
//  Created by xueyongwei on 16/11/11.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "SystemNotiViewController.h"
#import "SocketManager.h"
#import "MsgFeedBackModel.h"
#import "MsgSystemNotiModel.h"


#import "MsgChatLeftVersysTableViewCell.h"
#import "MsgChatRightTableViewCell.h"

#import "PKDetailViewController.h"
#import "UHCenterViewController.h"
@interface SystemNotiViewController ()
@property (nonatomic,strong)UILabel *noDataLabel;
@property (nonatomic,assign)NSInteger currentPage;
@end

@implementation SystemNotiViewController
#pragma mark ---🐷懒加载
-(UILabel *)noDataLabel
{
    if (!_noDataLabel) {
        _noDataLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_W/2-100, SCREEN_H/3, 200, 21)];
        _noDataLabel.textAlignment = NSTextAlignmentCenter;
        _noDataLabel.text = @"暂时还没有消息哦~";
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
            NSString *uri =[dic objectForKey:@"uri"];
            if ([uri isEqualToString:@"system/user/feedback"]) {//我的反馈
                MsgFeedBackModel *model = [MsgFeedBackModel mj_objectWithKeyValues:dic];
                [self.dataSource addObject:model];
            }else if ([uri isEqualToString:@"system/user/notice"]){//系统通知
                MsgSystemNotiModel *model = [MsgSystemNotiModel mj_objectWithKeyValues:dic];
                [self.dataSource addObject:model];
            }else if ([uri isEqualToString:@"system/user/forbid"]){//禁言
                MsgSystemNotiModel *model = [MsgSystemNotiModel mj_objectWithKeyValues:dic];
                [self.dataSource addObject:model];
            }else if ([uri isEqualToString:@"system/user/videoEditChoice"]){//赛事被精选
                MsgSystemNotiModel *model = [MsgSystemNotiModel mj_objectWithKeyValues:dic];
                [self.dataSource addObject:model];
            }
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
    MsgModel *msg = self.dataSource[indexPath.row];
    if ([msg.uri isEqualToString:@"system/user/feedback"]) {//用户反馈
        MsgFeedBackModel *model = (MsgFeedBackModel*)msg;
        MsgChatRightTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MsgChatRightTableViewCell"];
        if (!cell) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"MsgChatRightTableViewCell" owner:self options:nil]lastObject];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onUserIconClick:)];
            cell.iconImg.userInteractionEnabled = YES;
            [cell.iconImg addGestureRecognizer:tap];
        }
        
        [UserInfoManager setNameLabel:nil headImageV:cell.iconImg corverImageV:cell.iconCorver with:[UserInfoManager mySelfInfoModel].mid];
        
        cell.contentLabel.text = model.body.content;
        cell.timeLabel.text = [model.body howLongStr];
        return cell;
    }else {//系统通知 if ([msg.uri isEqualToString:@"system/user/notice"])
        MsgSystemNotiModel *model = (MsgSystemNotiModel *)msg;
        MsgChatLeftVersysTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MsgChatLeftVersysTableViewCell"];
        if (!cell) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"MsgChatLeftVersysTableViewCell" owner:self options:nil]lastObject];
        }
        cell.versusView.tag = indexPath.row;
        cell.iconImgV.image = [UIImage imageNamed:@"系统通知_头像"];
        cell.contentLabel.text = model.body.content;
        cell.timeLabel.text = [model.body howLongStr];
        DbLog(@"%@",model.extras.versusTagName);
        if (model.extras && model.extras.blueMid.integerValue>0 && model.extras.redMid.integerValue >0) {
            cell.versusHeightConst.constant = 45;
            [cell.versusView setTagName:model.extras.formaterVersusTagName pkId:model.extras.versusId leftUserId:model.extras.redMid rightUserID:model.extras.blueMid];
        }else{
            cell.versusHeightConst.constant = 0;
        }
        
        return cell;
    }
    return nil;
}
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    MsgModel *msg = self.dataSource[indexPath.row];
//    if ([msg.uri isEqualToString:@"system/user/notice"]) {//系统通知
//        MsgSystemNotiModel *model = (MsgSystemNotiModel *)msg;
//        PKDetailViewController *detailVC = [[PKDetailViewController alloc]initWithNibName:@"PKDetailViewController" bundle:nil];
//        detailVC.pkId = model.extras.versusId.integerValue;
//        [self.navigationController pushViewController:detailVC animated:YES];
//    }
//}
-(void)onVersusClick:(UITapGestureRecognizer *)recognizer
{
    MsgSystemNotiModel *msg = self.dataSource[recognizer.view.tag];
        PKDetailViewController *detailVC = [[PKDetailViewController alloc]initWithNibName:@"PKDetailViewController" bundle:nil];
    detailVC.pkId = msg.extras.versusId.integerValue;
    [self.navigationController pushViewController:detailVC animated:YES];
}
-(void)onUserIconClick:(UITapGestureRecognizer *)recognizer
{
    UHCenterViewController *uhvc = [[UHCenterViewController alloc]init];
    uhvc.mid = recognizer.view.tag;
    [self.navigationController pushViewController:uhvc animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end
