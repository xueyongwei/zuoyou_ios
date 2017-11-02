//
//  XiaoxiViewController.m
//  HDJ
//
//  Created by xueyongwei on 16/6/13.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "XiaoxiViewController.h"
#import "SystemNotiViewController.h"
#import "XiaoxiTopTableViewCell.h"
#import "XiaoxiChatTableViewCell.h"
#import "XiaoxiSessionModel.h"
#import "SocketManager.h"
#import "XiaoxiTopViewController.h"
#import "LiwuXiaoxiViewController.h"
#import "PingLunXiaoxiViewController.h"
#import "SaishiTongzhiXiaoxiViewController.h"
#import "newCareXiaoxiTableView.h"
#import "MsgPraiseViewController.h"
#import "ChatPersonalViewController.h"
#import "MessageHelper.h"

@interface XiaoxiViewController ()<ChatPersonalViewControllerDelegate>

@property (nonatomic,assign)NSInteger currentPage;

@end

@implementation XiaoxiViewController
#pragma mark --- 🐷懒加载
-(NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc]init];
    }
    return _dataSource;
}
#pragma mark ---控制器方法
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.currentPage = 1;
    //    [self prepareXiaoxi:1];
    
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"消息页面"];
    //    [self remoreNotiObser];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"消息";
    self.currentPage = 1;
    [self addNotiObser];
    [self customTableView];
    
    [MessageHelper shareInstance].messagepage = self;
    
//    [self prepareXiaoxi:self.currentPage];
    // Do any additional setup after loading the view from its nib.
}

-(void)customTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.currentPage = 1;
    __weak typeof(self) wkSelf = self;
    BangdanMjHeader *header = [BangdanMjHeader headerWithRefreshingBlock:^{
        wkSelf.currentPage = 1;
        [wkSelf prepareXiaoxi:wkSelf.currentPage];
    }];
    header.frame = CGRectMake(0, 0, SCREEN_W, 60);
    self.tableView.mj_header = header;
        [header beginRefreshing];
    self.tableView.mj_footer = [MJRefreshBackStateFooter footerWithRefreshingBlock:^{
        [wkSelf prepareXiaoxi:wkSelf.currentPage];
    }];
}

#pragma mark ---🐛准备网络数据
//-(void)prepareXiaoxi
//{
//    [[SocketManager defaultManager] sendMsg:[NSString stringWithFormat:@"{uri:\"system/session/list\"}"]];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.tableView.mj_header endRefreshing];
//    });
//}
-(void)reloadList
{
    self.currentPage = 1;
    [self prepareXiaoxi:self.currentPage];
}
-(void)prepareXiaoxi:(NSInteger)page
{
    [[SocketManager defaultManager] sendMsg:[NSString stringWithFormat:@"{uri:\"system/session/list?pn=%ld\"}",(long)page]];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
    });
}
-(NSInteger)getTargetUserId:(NSInteger)id1 and:(NSInteger)id2{
    if (id1 == [UserInfoManager mySelfInfoModel].mid.integerValue) {
        return id2;
    }else{
        return id1;
    }
}
-(void)requestToDeleteSession:(NSIndexPath*)indexPath{
    NSString *uri = [NSString stringWithFormat:@"%@/social/deleteMessageSession",HeadUrl];
    XiaoxiSessionModel *model = self.dataSource[indexPath.row];
    NSDictionary *param = @{@"messageSessionKey":model.messageSessionKey};
    [XYWhttpManager XYWpost:uri parameters:param inView:nil sucess:^(id result) {
        DbLog(@"%@",result);
        
    } failure:^(NSError *error) {
        DbLog(@"%@",error.localizedDescription);
    }];
}
#pragma mark --- 😊tableView的代理方法
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
    //    return 4;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XiaoxiSessionModel *model = self.dataSource[indexPath.row];
    XiaoxiChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"XiaoxiChatTableViewCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"XiaoxiChatTableViewCell" owner:self options:nil]lastObject];
    }
    if (model.unreadCount>0) {
        cell.FlagLabel.hidden = NO;
    }else{
        cell.FlagLabel.hidden = YES;
    }
    if ([model.messageSessionKey hasPrefix:@"system/social/comment"]||[model.messageSessionKey hasPrefix:@"system/user/follow"]||[model.messageSessionKey hasPrefix:@"private/dialog"]) {
        cell.FlagLabel.layer.cornerRadius = 8;
        
        if (model.unreadCount>99) {
            cell.flagH.constant = 22;
            cell.flagheightConst.constant = 16;
            cell.FlagLabel.text = @"99+";
        }else{
            cell.flagH.constant = 16;
            cell.flagheightConst.constant = 16;
            cell.FlagLabel.text = [NSString stringWithFormat:@"%ld",(long)model.unreadCount];
        }
        
    }else{
        cell.flagH.constant = 8;
        cell.flagheightConst.constant = 8;
        cell.FlagLabel.layer.cornerRadius = 4;
        cell.FlagLabel.text = @"";
    }
    cell.timeLabel.text = model.lastMessage.body.listTimeStr;
    [self setName:cell.titLabel andIcon:cell.imgV with:model.messageSessionKey];
    //下面的耗时操作放入子线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if ([model.messageSessionKey hasPrefix:@"private/dialog"]) {//私信
            
            NSInteger userid = [self getTargetUserId:model.lastMessage.extras.from and:model.lastMessage.extras.to];
            [UserInfoManager setNameLabel:cell.titLabel headImageV:cell.imgV memberRoul:YES with:@(userid)];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.contentLabel.text = model.lastMessage.body.content;
            });
        }else if ([model.messageSessionKey hasPrefix:@"system/social/comment"]) {//评论。回复。
//            if (model.lastMessage.showSum) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    cell.contentLabel.text = model.lastMessage.showSum;
//                });
//            }else{
                [UserInfoManager requestUserInfoWithID:model.lastMessage.extras.mid finish:^(UserInfoModel *user) {
//                    NSString *content =[NSString stringWithFormat:@"%@：%@",user.name,model.lastMessage.body.content];
                    
                    
                    NSMutableString *userName = [NSMutableString stringWithString:user.name];
                    if (model.lastMessage.extras.referredMid &&model.lastMessage.extras.referredMid>100 ) {//回复的内容，不加冒号
                    }else{
                        [userName appendString:@"："];
                    }
                    NSMutableAttributedString *contentText = [[NSMutableAttributedString alloc]initWithString:userName];
                    [contentText appendAttributedString:model.lastMessage.body.contenText];
                    [contentText addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor colorWithHexColorString:@"777777"]} range:NSMakeRange(0, contentText.length)];
//                    model.lastMessage.showSum = content;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cell.contentLabel.attributedText = contentText;
                    });
                    
                }];
//            }
            
        }else if ([model.messageSessionKey hasPrefix:@"system/user/follow"]){//关注
            if (model.lastMessage.showSum) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.contentLabel.text = model.lastMessage.showSum;
                });
            }else{
                [UserInfoManager requestUserInfoWithID:model.lastMessage.extras.createdBy finish:^(UserInfoModel *user) {
                    
                    NSString *content = [NSString stringWithFormat:@"%@ 关注了你",user.name];
                    model.lastMessage.showSum = content;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cell.contentLabel.text = content;
                    });
                }];
            }
        }else if ([model.messageSessionKey hasPrefix:@"system/finance/praise"]){//赞
            if (model.lastMessage.showSum) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.contentLabel.text = model.lastMessage.showSum;
                });
            }else{
                [UserInfoManager requestUserInfoWithID:model.lastMessage.extras.mid finish:^(UserInfoModel *user) {
                    NSString *content = [NSString stringWithFormat:@"%@ %@",user.name,model.lastMessage.body.content];
                    model.lastMessage.showSum = content;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cell.contentLabel.text = content;
                    });
                    
                }];
            }
            
        }else{
            if ([model.lastMessage.uri isEqualToString:@"system/pk/beChallenge"]) {//被挑战的通知
                
                [UserInfoManager requestUserInfoWithID:model.lastMessage.extras.blueMid finish:^(UserInfoModel *user) {
                    NSString *contentStr = [NSString stringWithFormat:@"<font color=\"#777777\"><font color=\"#03a9f3\">%@</font>%@</font>",user.name,model.lastMessage.body.content];
                    NSMutableAttributedString *contentText = [[NSMutableAttributedString alloc] initWithData:[contentStr dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType} documentAttributes:nil error:nil];
                    [contentText addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} range:NSMakeRange(0, contentText.length)];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cell.contentLabel.attributedText = contentText;
                    });
                    
                }];
            }else{
                
                NSString *contentStr = [NSString stringWithFormat:@"<font color=\"#777777\">%@</font>",model.lastMessage.body.content];
                NSMutableAttributedString *contentText = [[NSMutableAttributedString alloc] initWithData:[contentStr dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType} documentAttributes:nil error:nil];
                
                [contentText addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} range:NSMakeRange(0, contentText.length)];
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.contentLabel.attributedText = contentText;
                });
                
            }
        }
    });
    
    
    //        cell.timeLabel.text = [self changeTheDateString:model.lastMessage.body.createdDate];
    return cell;
}
-(void)setLabel:(UILabel *)label withText:(NSString *)text
{
    dispatch_async(dispatch_get_main_queue(), ^{
        label.text = text;
    });
}
-(void)setLabel:(UILabel *)label withAttriText:(NSMutableAttributedString *)attriText
{
    dispatch_async(dispatch_get_main_queue(), ^{
        label.attributedText = attriText;
    });
}
//- (NSString *)changeTheDateString:(NSString *)Str
//{
//    NSString *subString = [Str substringWithRange:NSMakeRange(0, 19)];
//    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
//    NSLocale* local =[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
//    [formater setLocale:local];
//    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSDate* lastDate = [formater dateFromString:subString];
//
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    //    NSString *resultStr = @"";
//    if ([lastDate isToday]) {
//        [dateFormatter setDateFormat:@"HH:mm"];
//    }else if ([lastDate isThisYear]){
//        [dateFormatter setDateFormat:@"MM月dd日"];
//    }else{
//        [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
//    }
//    NSString *currentDateStr = [dateFormatter stringFromDate:lastDate];
//    return currentDateStr;
//}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    XiaoxiSessionModel *model = self.dataSource[indexPath.row];

    model.unreadCount = 0;
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    if ([model.messageSessionKey hasPrefix:@"system/finance/item"]) {//礼物
        LiwuXiaoxiViewController *lwVC = [[LiwuXiaoxiViewController alloc]initWithNibName:@"LiwuXiaoxiViewController" bundle:nil];
        lwVC.model = model;
        [self.navigationController pushViewController:lwVC animated:YES];
    }else if ([model.messageSessionKey hasPrefix:@"system/social/comment"]){//评论
        PingLunXiaoxiViewController *plVC = [[PingLunXiaoxiViewController alloc]initWithNibName:@"PingLunXiaoxiViewController" bundle:nil];
        plVC.model = model;
        [self.navigationController pushViewController:plVC animated:YES];
    }else if ([model.messageSessionKey hasPrefix:@"system/pk/notice"]){//赛事通知
        SaishiTongzhiXiaoxiViewController *ssVC = [[SaishiTongzhiXiaoxiViewController alloc]initWithNibName:@"SaishiTongzhiXiaoxiViewController" bundle:nil];
        ssVC.model = model;
        [self.navigationController pushViewController:ssVC animated:YES];
    }else if ([model.messageSessionKey hasPrefix:@"system/user/follow"]){//关注提醒
        newCareXiaoxiTableView *ncVC = [newCareXiaoxiTableView new];
        ncVC.model = model;
        [self.navigationController pushViewController:ncVC animated:YES];
    }else if ([model.messageSessionKey hasPrefix:@"system/user/notice"]){//系统通知
        SystemNotiViewController *snVC = [[SystemNotiViewController alloc]initWithStyle:UITableViewStylePlain];
        snVC.model = model;
        snVC.title = @"系统通知";
        [self.navigationController pushViewController:snVC animated:YES];
    }else if ([model.messageSessionKey hasPrefix:@"system/notice"]){//小豆说
        XiaoxiSessionModel *model = self.dataSource[indexPath.row];
        XiaoxiTopViewController *vc = [[XiaoxiTopViewController alloc]initWithNibName:@"XiaoxiTopViewController" bundle:nil];
        vc.model = model;
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([model.messageSessionKey hasPrefix:@"system/finance/praise"]){//赞
        MsgPraiseViewController *zVC = [[MsgPraiseViewController alloc]initWithStyle:UITableViewStylePlain];
        zVC.model = model;
        zVC.title = @"赞";
        [self.navigationController pushViewController:zVC animated:YES];
    }else if ([model.messageSessionKey hasPrefix:@"private/dialog"]){//私聊
        ChatPersonalViewController *chatVC = [[ChatPersonalViewController alloc]init];
        chatVC.mid = [self getTargetUserId:model.lastMessage.extras.from and:model.lastMessage.extras.to];
        chatVC.sessionModel = model;
        chatVC.delegate = self;
        [self.navigationController pushViewController:chatVC animated:YES];
    }else{
        CoreSVPCenterMsg(@"您需要升级才能完成操作！");
    }
    
}
-(void)setName:(UILabel *)label andIcon:(UIImageView *)imgV with:(NSString *)type
{
    if ([type hasPrefix:@"system/social/comment"]) {//评论和回复
        label.text = @"评论";
        imgV.image = [UIImage imageNamed:@"消息列表评论icon"];
    }else if ([type hasPrefix:@"system/finance/item"]){//礼物
        label.text = @"礼物";
        imgV.image = [UIImage imageNamed:@"个人消息礼物-icon"];
    }else if ([type hasPrefix:@"system/pk/notice"]){//赛事
        label.text = @"赛事通知";
        imgV.image = [UIImage imageNamed:@"消息列表赛事通知icon"];
    }else if ([type hasPrefix:@"system/user/follow"]){//关注
        label.text = @"新的关注";
        imgV.image = [UIImage imageNamed:@"消息列表新的关注icon"];
    }else if ([type hasPrefix:@"system/user/notice"]){//系统通知
        label.text = @"系统通知";
        imgV.image = [UIImage imageNamed:@"消息列表系统通知icon"];
    }else if ([type hasPrefix:@"system/finance/praise"]){//赞
        label.text = @"赞";
        imgV.image = [UIImage imageNamed:@"消息列表赞icon"];
    }else if ([type hasPrefix:@"system/notic"]){//小豆说
        label.text = @"小豆说";
        imgV.image = [UIImage imageNamed:@"消息列表小豆说头像"];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    if (indexPath.row==0) {
    //        return 75;
    //    }else{
    return 60;
    //    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
//定义编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
//进入编辑模式，按下出现的编辑按钮后,进行删除操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self requestToDeleteSession:indexPath];
        // Delete the row from the data source.
        [self.dataSource removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}
#pragma mark --🎈通知中心
-(void)addNotiObser
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(systemsessionlistHandle:) name:@"systemsessionlist" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(systemsessionlistHandle:) name:@"privatedialog" object:nil];
}
-(void)remoreNotiObser
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"systemsessionlist" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"privatedialog" object:nil];
}
#pragma mark ---通知的handle
-(void)systemsessionlistHandle:(NSNotification *)noti
{
    DbLog(@"%@",noti.userInfo);
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
    WSmessageModel *model = (WSmessageModel*)noti.userInfo[@"model"];
    NSArray *bodys = (NSArray *)model.body;
    
    if ([noti.name isEqualToString:@"systemsessionlist"]) {//消息列表,消息的数组
        if (![model.body isKindOfClass:[NSArray class]]) {
            DbLog(@"is not the class we want(nsarray)!");
        }
        if (bodys.count==0) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
            return;
        }
        if (self.currentPage==1) {
            [self.dataSource removeAllObjects];
        }
        for (NSDictionary *dic in bodys) {
            XiaoxiSessionModel *model = [XiaoxiSessionModel mj_objectWithKeyValues:dic];
            if (model.isSuppotrType) {//只要当前版本识别的东西
                [self.dataSource addObject:model];
            }
        }
        if (self.currentPage ==1) {
//            self.xiaoxiModels = self.dataSource;
        }
        self.currentPage ++;
        [self.tableView reloadData];
    }else if([noti.name isEqualToString:@"privatedialog"]){
        XiaoxiSessionModel *session = [XiaoxiSessionModel new];
        msgLastMessageModel *lastMessage = [msgLastMessageModel mj_objectWithKeyValues:model.mj_JSONString];
        session.lastMessage = lastMessage;
        
        NSInteger i =0;
        
        for (i = 0; i<self.dataSource.count; i++) {
            XiaoxiSessionModel *listModel = self.dataSource[i];
            DbLog(@"%@",listModel.messageSessionKey);
            if ([listModel.messageSessionKey isEqualToString:model.headers[@"messageSessionKey"]]) {
                
                listModel.lastMessage = lastMessage;
                if ([MessageHelper shareInstance].currentSessionPoint == listModel) {//正在俩天的这个
                    listModel.unreadCount=0;
                }else{
                    listModel.unreadCount ++;
                }
                if (i>0) {//不是第一个，置顶最新的会话
                    [self topSessionModel:listModel];
                }else{
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//                    [self.tableView reloadData];
                }
                //               NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                //               [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                return;
            }
        }
        if (i ==self.dataSource.count) {
            session.unreadCount = 1;
            session.messageSessionKey = model.headers[@"messageSessionKey"];
            [self.dataSource insertObject:session atIndex:0];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            //           [self.dataSource addObject:session];
        }
        
        
    }
    
}
#pragma mark --delegate
-(void)removeSeessionModel:(XiaoxiSessionModel *)sessionModel
{
    NSIndexPath *idxPath = [NSIndexPath indexPathForRow:[self.dataSource indexOfObject:sessionModel] inSection:0];
    
    [self.dataSource removeObject:sessionModel];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:idxPath] withRowAnimation:UITableViewRowAnimationFade];
}
-(void)topSessionModel:(XiaoxiSessionModel *)sessionModel
{
    //    NSIndexPath *idxPath = [NSIndexPath indexPathForRow:[self.dataSource indexOfObject:sessionModel] inSection:0];
    [self.dataSource removeObject:sessionModel];
    [self.dataSource insertObject:sessionModel atIndex:0];
    [self.tableView reloadData];
    //    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:idxPath] withRowAnimation:UITableViewRowAnimationFade];
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
-(void)dealloc
{
    DbLog(@"xiaoxiViewcontroller 释放了");
}

@end
