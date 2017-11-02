//
//  PersonalViewController.m
//  ZuoYou
//
//  Created by xueyongwei on 16/9/14.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "PersonalViewController.h"
//#import "UHCenterViewController.h"
#import "UHCenterViewController.h"
#import "UIImage+Color.h"
#import "XYWAlert.h"
#import "HtmlViewController.h"
#import "IncomeViewController.h"
#import "SocketManager.h"
#import "MessageHelper.h"
@interface PersonalViewController ()
@property (nonatomic,strong)NSMutableArray *xiaoxiArr;
@property (nonatomic,strong)NSMutableArray *renwuDataSource;
@property (nonatomic,strong)NSMutableArray *gerenItms;
@property (nonatomic,weak)Geren2TableViewCell *xiaoxiCell;
@end

@implementation PersonalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initProty];
    [self addNotiObser];
    [self customTbaleView];
    [self prepareMyInfo];
    [self prepareXiaoxi];
    [MessageHelper shareInstance].personalpage = self;
}
-(void)initProty
{
    self.xiaoxiArr = [NSMutableArray new];
    self.renwuDataSource = [NSMutableArray new];
    self.gerenItms = [NSMutableArray new];
    self.gerenItms = [NSMutableArray new];
    NSInteger apple =  [UserInfoManager mySelfInfoModel].mid.integerValue;
    if (apple == 112087|| apple ==102561) {//Apple人员
        
    }else{//不是Apple
        NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
        NSString *pro = [usf objectForKey:KPRODUCTEVN];
        if (pro && pro.integerValue==1) {//且是生产环境
            [self.gerenItms addObject:@"收益"];
        }
    }
//    
//    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
//    NSString *pro = [usf objectForKey:KPRODUCTEVN];
//    if (pro && pro.integerValue==1) {//生产环境
//        [self.gerenItms addObject:@"收益"];
//    }
    [self.gerenItms addObject:@"充值"];
    [self.gerenItms addObject:@"消息"];
    [self.gerenItms addObject:@"支持的比赛"];
    [self.gerenItms addObject:@"抽奖"];
}

#pragma mark ---控制器方法
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self prepareRenwuList];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [[MessageHelper shareInstance]refreshUnReadCount];
//    if (self.xiaoxiArr) {
////        [self prepareXiaoxi];
//    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    self.navigationItem.rightBarButtonItem = nil;
    
//    [self remoreNotiObser];
    if (self.navigationController) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"个人页面"];
    
    //已到首页，取消导航栏手势返回
    if (self.navigationController) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
//    [self prepareXiaoxi];
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageFromContextWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
//    self.navigationController.navigationBar.translucent = NO;
//    self.navigationController.navigationBar.shadowImage = [UIImage imageFromContextWithColor:[UIColor colorWithHexColorString:@"e6e6e6"]];
//    [self dealHeadLine:self.navigationController.navigationBar];
}


-(void)customProgressView:(LDProgressView*)progressView
{
    progressView.color = [UIColor colorWithHexColorString:@"ff4a4b"];
    progressView.flat = @YES;
    progressView.showText = @NO;
    progressView.showBackgroundInnerShadow = @0;
    progressView.progress = 0.0;
    progressView.animate = @NO;
    progressView.background = [UIColor colorWithHexColorString:@"e6e6e6"];
}


-(void)customTbaleView
{
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.backgroundColor = [UIColor colorWithHexColorString:@"f4f4f4"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

-(void)customNavi
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 60, 16)];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithHexColorString:@"333333"];
    label.text = @"我";
    label.font = [UIFont systemFontOfSize:17];
    
    self.navigationItem.titleView = label;
    
    UIButton *setBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [setBtn setImage:[UIImage imageNamed:@"设置"] forState:UIControlStateNormal];
    setBtn.frame = CGRectMake(0, 0, 18, 18);
    [setBtn addTarget:self action:@selector(onSetClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:setBtn];
    
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageFromContextWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.shadowImage = [UIImage imageFromContextWithColor:[UIColor colorWithHexColorString:@"e6e6e6"]];

    //自定义导航栏可手势返回
    if (self.navigationController) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}
-(void)onSetClick:(UIButton *)sender
{
//    SettingViewController *setVC = [[SettingViewController alloc]initWithNibName:@"SettingViewController" bundle:nil];
    SetingViewController *setVC = [[SetingViewController alloc]initWithStyle:UITableViewStyleGrouped];
    setVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:setVC animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark --- 准备数据
-(void)prepareMyInfo
{
    [UserInfoManager refreshMyselfInfoFinished:^{
        [self.tableView reloadData];
    }];
}
-(void)prepareXiaoxi
{
    [[SocketManager defaultManager] sendMsg:[NSString stringWithFormat:@"{uri:\"system/session/list\"}"]];
    
}
-(void)prepareRenwuList
{
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@%@",HeadUrl,@"/mission/list"] parameters:nil inView:nil sucess:^(id result) {
        //异步线程处理数据
        if (result&&[result isKindOfClass:[NSArray class]]) {
            DbLog(@"%@",result);
            NSArray *rlt = (NSArray *)result;
            NSDictionary *rsp = rlt.firstObject;
            if ([rsp objectForKey:@"errCode"]) {
                CoreSVPCenterMsg([rsp objectForKey:@"errMsg"]);
                return ;
            }else{
                [self.renwuDataSource removeAllObjects];
                
                for (NSDictionary *renwu in rlt) {
                    RenWuListModel *model = [RenWuListModel mj_objectWithKeyValues:renwu];
                    [self.renwuDataSource addObject:model];
                }
                [self.tableView reloadData];
            }
        }

    } failure:^(NSError *error) {
        
    }];
}
#pragma mark - tableView delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.renwuDataSource.count + self.gerenItms.count+2;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0) {
        Geren1TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Geren1TableViewCell"];
        if (!cell) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"Geren1TableViewCell" owner:self options:nil]lastObject];
        }
        MyselfInfoModel *my = [UserInfoManager mySelfInfoModel];
        [UserInfoManager setNameLabel:cell.nameLb headImageV:cell.iconImgV corverImageV:cell.corverImgV with:my.mid];
//        [cell.iconImgV sd_setImageWithURL:[NSURL URLWithString:my.avatar] placeholderImage:[UIImage imageNamed:@"1"]];
//        
//        cell.nameLb.text = my.name;
        return cell;
    }else if (indexPath.row>0 && indexPath.row<=self.gerenItms.count){//itms
        Geren2TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Geren2TableViewCell"];
        if (!cell) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"Geren2TableViewCell" owner:self options:nil]lastObject];
        }
        if (indexPath.row ==1) {
            cell.topH.constant = 0;
            cell.botH.constant = 0;
        }else{
            cell.botH.constant = 0;
        }
        cell.itmNaleLabel.text = self.gerenItms[indexPath.row-1];
        if ([cell.itmNaleLabel.text isEqualToString:@"消息"]) {
            self.xiaoxiCell = cell;
        }
        NSString *imgName = [NSString stringWithFormat:@"%@-icon",self.gerenItms[indexPath.row -1]];
        cell.itmIconV.image = [UIImage imageNamed:imgName];
        
        return cell;
    }else if (indexPath.row==self.gerenItms.count+1){//任务
        Geren3TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Geren3TableViewCell"];
        if (!cell) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"Geren3TableViewCell" owner:self options:nil]lastObject];
        }
        NSInteger finishNb=0;
        for (RenWuListModel *model in self.renwuDataSource) {
            if ([model.statusType isEqualToString:@"FINISH"]) {
                finishNb ++;
            }
        }
        cell.progressView.progress = (CGFloat)finishNb/self.renwuDataSource.count;
        cell.proTexTlabel.text =[NSString stringWithFormat:@"%ld/%lu",(long)finishNb,(unsigned long)self.renwuDataSource.count];
        return cell;
    }else{
        RenwuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RenwuTableViewCell"];
        if (!cell) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"RenwuTableViewCell" owner:self options:nil]lastObject];
            cell.delegate = self;
        }
        if (indexPath.row == self.renwuDataSource.count + self.gerenItms.count+2) {
            cell.fengexianH.constant = 0;
        }
        cell.model = self.renwuDataSource[indexPath.row-self.gerenItms.count-2];
        return cell;
    }
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
    NSString *pro = [usf objectForKey:KPRODUCTEVN];
    NSInteger numbs;
    if (pro && pro.integerValue == 1) {
        numbs = 5;
    }else{
        numbs = 4;
    }
    if (indexPath.row == 0) {
        return 95;
    }else if (indexPath.row >0 && indexPath.row<numbs){
        return 50;
    }else{
        return 55;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1f;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        [self onUserClick:nil];
    }else if (indexPath.row>0 && indexPath.row<=self.gerenItms.count){//itms
        if ([self.gerenItms[indexPath.row - 1] isEqualToString:@"收益"]) {
            [self onShouYiClick:nil];
            
        }else if ([self.gerenItms[indexPath.row - 1] isEqualToString:@"充值"]) {
            [self onZhanghuClick:nil];
        }if ([self.gerenItms[indexPath.row - 1] isEqualToString:@"消息"]) {
            [self onXiaoxiClick:nil];
        }if ([self.gerenItms[indexPath.row - 1] isEqualToString:@"支持的比赛"]) {
            [self onZhichideBisaiClick:nil];
        }if ([self.gerenItms[indexPath.row - 1] isEqualToString:@"抽奖"]) {
            [self onLuckClick:nil];
        }
    }
}


#pragma mark - Item CLick

- (void)onUserClick:(UIButton *)sender {
    
//    UHCenterTableViewController *ushVC = [[UHCenterTableViewController alloc]initWithNibName:@"UHCenterTableViewController" bundle:nil];
    
    
    UHCenterViewController *ushVC = [[UHCenterViewController alloc]init];
    MyselfInfoModel *my = [UserInfoManager mySelfInfoModel];
    ushVC.mid = my.mid.integerValue;
    ushVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:ushVC animated:YES];
//    EditGerenViewController *egVC = [[EditGerenViewController alloc]initWithNibName:@"EditGerenViewController" bundle:nil];
//    egVC.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:egVC animated:YES];
}
- (void)onZhanghuClick:(UIButton *)sender {
    ChongZhiViewController *czVC = [[ChongZhiViewController alloc]initWithNibName:@"ChongZhiViewController" bundle:nil];
    czVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:czVC animated:YES];
}
- (void)onXiaoxiClick:(UIButton *)sender {
    XiaoxiViewController *xxVC = [[XiaoxiViewController alloc]initWithNibName:@"XiaoxiViewController" bundle:nil];
//    xxVC.dataSource = self.xiaoxiArr;
    xxVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:xxVC animated:YES];
}
- (void)onShouYiClick:(UIButton *)sender {
    MyselfInfoModel *my = [UserInfoManager mySelfInfoModel];
    if (my.memberRoles.integerValue ==6 || my.memberRoles.integerValue ==16) {
//    if (1) {
        IncomeViewController *syVC =[[IncomeViewController alloc]initWithNibName:@"IncomeViewController" bundle:nil];
        syVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:syVC animated:YES];
    }else{
        [XYWAlert XYWAlertTitle:@"你还不是认证PK主，暂时无法获得胜利收益" message:nil first:@"了解认证PK主" firstHandle:^{
            HtmlViewController *htmlVC = [HtmlViewController new];
            htmlVC.url = @"http://api.zuoyoupk.com/v1/html/referral.html";
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(0, 0, 44, 44);
            [btn setImage:[UIImage imageNamed:@"上传关闭"] forState:UIControlStateNormal];
            [btn addTarget:htmlVC action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
            htmlVC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
            
            UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:htmlVC];
            [self presentViewController:navi animated:YES completion:^{
                
            }];
        } second:nil Secondhandle:nil cancle:@"关闭" handle:^{
            
        }];
    }
    
}
- (void)onZhichideBisaiClick:(UIButton *)sender {
    VersusListViewController *zcVC = [[VersusListViewController alloc]initWithStyle:UITableViewStylePlain];
    zcVC.requestURL = @"/users/support";
    zcVC.noMoreDataMessage = @"还没有支持的比赛哦~";
    zcVC.title = @"支持的比赛";
    zcVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:zcVC animated:YES];
}

-(void)onLuckClick:(UIButton *)sender{
    HtmlViewController *html = [[HtmlViewController alloc]init];
    html.url = [NSString stringWithFormat:@"%@/misc/lottery/index?token=%@",@"http://api.zuoyoupk.com/v1",[UserInfoManager mySelfInfoModel].token];
    html.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:html animated:YES];
}

#pragma mark --🎈通知中心
-(void)addNotiObser
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(systemsessionlistHandle:) name:@"systemsessionlist" object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(systemsessionlistHandle:) name:@"privatedialog" object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(prepareXiaoxi) name:@"personalVCshouldRefreshList" object:nil];
}
-(void)remoreNotiObser
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"systemsessionlist" object:nil];
}
#pragma mark ---通知的handle
-(void)systemsessionlistHandle:(NSNotification *)noti
{
    DbLog(@"%@",noti.userInfo);
    if ([noti.name isEqualToString:@"systemsessionlist"]){//消息列表的数据
//        Geren2TableViewCell *xiaoxiCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.gerenItms.count-1 inSection:0]];
        
        WSmessageModel *model = (WSmessageModel*)noti.userInfo[@"model"];
        if (![model.body isKindOfClass:[NSArray class]]) {
            DbLog(@"is not the class we want(nsarray)!");
        }
        NSArray *bodys = (NSArray *)model.body;
        if (bodys.count==0) {
            return;
        }
        [self.xiaoxiArr removeAllObjects];
        for (NSDictionary *dic in bodys) {
            XiaoxiSessionModel *model = [XiaoxiSessionModel mj_objectWithKeyValues:dic];
            [self.xiaoxiArr addObject:model];
        }
        [self remoreNotiObser];
    }else if([noti.name isEqualToString:@"privatedialog"]){//收到新的消息
//        [self prepareXiaoxi];
    }
        /*
    NSInteger numb = 0;//如果是显示数字就不要再改成点了
    for (NSDictionary *dic in bodys) {
        XiaoxiSessionModel *model = [XiaoxiSessionModel mj_objectWithKeyValues:dic];
        if (![model isSuppotrType]) {
            continue;
        }
        if (numb==0 && model.unreadCount>0) {
            xiaoxiCell.numbLVB.hidden = NO;
            xiaoxiCell.numbLVB.text = @"";
            xiaoxiCell.numbLH.constant = 8;
            xiaoxiCell.numbLVB.layer.cornerRadius = 4;
            xiaoxiCell.numbLVB.clipsToBounds = YES;
            numb =1;
        }
        int totoalNb = 0;
        if ([model.messageSessionKey hasPrefix:@"system/social/comment"]) {
            if (model.unreadCount>0) {
                xiaoxiCell.numbLVB.hidden = NO;
                totoalNb += model.unreadCount;
                xiaoxiCell.numbLH.constant = 16;
                xiaoxiCell.numbLVB.clipsToBounds = YES;
                xiaoxiCell.numbLVB.layer.cornerRadius = 8;
                numb = 2;
                xiaoxiCell.numbLVB.text = [NSString stringWithFormat:@"%d",totoalNb];
            }
        }
        if ([model.messageSessionKey hasPrefix:@"system/user/follow"]) {
            if (model.unreadCount>0) {
                xiaoxiCell.numbLVB.hidden = NO;
                totoalNb += model.unreadCount;
                xiaoxiCell.numbLH.constant = 16;
                xiaoxiCell.numbLVB.clipsToBounds = YES;
                xiaoxiCell.numbLVB.layer.cornerRadius = 8;
                numb = 2;
                xiaoxiCell.numbLVB.text = [NSString stringWithFormat:@"%d",totoalNb];
            }
        }
        [self.tabBarController.tabBar hideBadgeOnItemIndex:3];
        [self.tabBarController.tabBar showBadgeOnItemIndex:3];
        if (numb ==0) {
            xiaoxiCell.numbLVB.hidden = YES;
            [self.tabBarController.tabBar hideBadgeOnItemIndex:3];
        }
        [self.xiaoxiArr addObject:model];
    }
    */
}
-(void)setMessageItemUnreadCount:(NSInteger)unreadShowCount totalCount:(NSInteger)unreadTotalCount{
//    Geren2TableViewCell *xiaoxiCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.gerenItms.count-1 inSection:0]];
    Geren2TableViewCell *xiaoxiCell = self.xiaoxiCell;
    if (unreadTotalCount>0) {
        xiaoxiCell.numbLVB.hidden = NO;
        if (unreadShowCount>0) {
            NSString *numbText = @"";
            if (unreadShowCount>99) {
                xiaoxiCell.numbLH.constant = 22;
                xiaoxiCell.numbLabelHeghtConst.constant = 16;
                numbText = @"99+";
            }else{
                xiaoxiCell.numbLH.constant = 16;
                xiaoxiCell.numbLabelHeghtConst.constant = 16;
                numbText =[NSString stringWithFormat:@"%ld",unreadShowCount];
            }
            xiaoxiCell.numbLVB.clipsToBounds = YES;
            xiaoxiCell.numbLVB.layer.cornerRadius = 8;
            xiaoxiCell.numbLVB.text = numbText;
        }else{
            xiaoxiCell.numbLVB.hidden = NO;
            xiaoxiCell.numbLVB.text = @"";
            xiaoxiCell.numbLH.constant = 8;
            xiaoxiCell.numbLabelHeghtConst.constant = 8;
            xiaoxiCell.numbLVB.layer.cornerRadius = 4;
            xiaoxiCell.numbLVB.clipsToBounds = YES;
        }
    }else{
        xiaoxiCell.numbLVB.hidden = YES;
    }

}
-(void)dealloc
{
    DbLog(@"persinal释放了");
}





@end
