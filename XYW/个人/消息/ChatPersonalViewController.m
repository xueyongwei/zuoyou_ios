//
//  ChatPersonalViewController.m
//  ZuoYou
//
//  Created by xueyognwei on 17/2/8.
//  Copyright © 2017年 xueyongwei. All rights reserved.
//

#import "ChatPersonalViewController.h"
#import "SocketManager.h"
#import "UUInputFunctionView.h"
#import <MJRefresh.h>
#import "UUMessageCell.h"
#import "ChatModel.h"
#import "UUMessageFrame.h"
#import "UUMessage.h"
#import "MJRefresh.h"
#import "UIImage+Color.h"
#import "UHCenterViewController.h"
#import "XYWAlert.h"
#import "MessageHelper.h"
@interface ChatPersonalViewController ()<UUInputFunctionViewDelegate,UUMessageCellDelegate,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>
//@property (strong, nonatomic) MJRefreshHeader *head;
//@property (strong, nonatomic) ChatModel *chatModel;
@property (nonatomic,strong)NSMutableArray *dataSource;
@property (weak, nonatomic) IBOutlet UITableView *chatTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (nonatomic,copy)NSString *previousTime;
@property (nonatomic,assign)NSInteger currenPage;
@property (nonatomic,copy)NSString *myIconUrl;
@property (nonatomic,assign)BOOL blackHim;
@end

@implementation ChatPersonalViewController
{
UUInputFunctionView *IFView;
}
-(NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [NSMutableArray new];
    }
    return _dataSource;
}
-(void)setMid:(NSInteger)mid
{
    _mid = mid;
    __weak typeof(self) wkSelf = self;
    [UserInfoManager requestUserInfoWithID:mid finish:^(UserInfoModel *user) {
        wkSelf.userName = user.name;
        wkSelf.iconUrl = user.avatar;
        [wkSelf loadChatHistory:wkSelf.currenPage];
    }];
}
-(void)setUserName:(NSString *)userName
{
    _userName = userName;
    self.navigationItem.title = userName;
}
-(void)setMessageSessionKey:(NSString *)messageSessionKey
{
    _messageSessionKey = messageSessionKey;
    NSArray *arr= [messageSessionKey componentsSeparatedByString:@"-"];
    if (arr.count==3) {
        NSInteger user1 =[NSString stringWithFormat:@"%@",arr[1]].integerValue;
        NSInteger user2 =[NSString stringWithFormat:@"%@",arr[2]].integerValue;
        NSInteger myId = [UserInfoManager mySelfInfoModel].mid.integerValue;
        
        if (myId == user1) {
            self.mid = user2;
//            [UserInfoManager requestUserInfoWithID:user2 finish:^(UserInfoModel *user) {
//                wkSelf.userName = user.name;
//            }];
        }else if(myId == user2){
            self.mid = user1;
//            [UserInfoManager requestUserInfoWithID:user1 finish:^(UserInfoModel *user) {
//                wkSelf.userName = user.name;
//            }];
        }
    }
}
-(id)init{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(systemsessionlistHandle:) name:@"privatedialog" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(systemsessionlistHandle:) name:@"systemsessionloadMsg" object:nil];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.currenPage = 1;
    self.myIconUrl = [UserInfoManager mySelfInfoModel].avatar;
    
    [self customNavi];
    [self addRefreshViews];
    [self loadBaseViewsAndData];
    [self requestIsBlackHim];
    [[MessageHelper shareInstance] refreshUnReadCount];
    [MessageHelper shareInstance].currentSessionPoint = self.sessionModel;
}
-(void)dealloc
{
    [MessageHelper shareInstance].currentSessionPoint = nil;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
-(void)customNavi{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationItem.title = self.userName;
    if (self.navigationController) {
        //如果不是导航的第一个VC，且还没有添加返回按钮才添加，才添加返回按钮
        if (self.navigationController.childViewControllers.count>1 && self.navigationItem.leftBarButtonItems.count<2) {
            UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                               target:nil action:nil];
            negativeSpacer.width = -3;//修正间隙
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(0, 0, 60, 30);
            btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            [btn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"back_click"] forState:UIControlStateHighlighted];
            [btn addTarget:self action:@selector(onBackClick:) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *leftBar = [[UIBarButtonItem alloc]initWithCustomView:btn];
            self.navigationItem.leftBarButtonItems = @[negativeSpacer,leftBar];
        }
        //右侧
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -3;
        //右上角上传按钮
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        btn.frame = CGRectMake(0, 0, 44, 60);
        [btn addTarget:self action:@selector(onMoreClick:) forControlEvents:UIControlEventTouchDown];
        [btn setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
//        [btn setImage:[UIImage imageNamed:@"榜单icon-click"] forState:UIControlStateHighlighted];
        
        //    [btn setImage:[UIImage imageNamed:@"上传"] forState:UIControlStateNormal];
        //    [btn setImage:[UIImage imageNamed:@"上传"] forState:UIControlStateHighlighted];
        UIBarButtonItem *itm = [[UIBarButtonItem alloc]initWithCustomView:btn];
        self.navigationItem.rightBarButtonItems = @[negativeSpacer,itm];
        //导航栏标题的颜色和大小
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor colorWithHexColorString:@"333333"]}];
        
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageFromContextWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.shadowImage = [UIImage imageFromContextWithColor:[UIColor colorWithHexColorString:@"e6e6e6"]];
        self.navigationController.view.backgroundColor = [UIColor whiteColor];
        self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        
    }
    
    
}

-(void)onMoreClick:(UIButton *)sender{
    [self.view endEditing:YES];
    NSString *homePageStr = @"查看对方个人主页";
    if (self.backWhenGoToHomePage) {
        homePageStr = @"返回对方个人主页";
    }
    NSString *blackStr = @"加入黑名单";
    if (self.blackHim) {
        blackStr = @"移出黑名单";
    }
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles: homePageStr,@"举报该用户",blackStr,nil];
    sheet.tintColor = [UIColor colorWithHexColorString:@"ff4a4b"];
    [sheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DbLog(@"click %ld",buttonIndex);
    switch (buttonIndex) {
        case 0:
        {
            if (self.backWhenGoToHomePage) {
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [self goToUserHomePage:self.mid];
//                UHCenterViewController *uhVC = [[UHCenterViewController alloc]init];
//                uhVC.mid  = self.mid;
//                uhVC.backWhenGoToChatPage = YES;
//                [self.navigationController pushViewController:uhVC animated:YES];
            }
        }
            break;
        case 1:
        {
            CoreSVPSuccess(@"举报成功！");
        }
            break;
        case 2:
        {
            [self blackThisUser];
        }
            break;
        default:
            break;
    }
}
-(void)onBackClick:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)goToUserHomePage:(NSInteger)userID{
    UHCenterViewController *uhVC = [[UHCenterViewController alloc]init];
    uhVC.mid = userID;
    uhVC.backWhenGoToChatPage = YES;
    [self.navigationController pushViewController:uhVC animated:YES];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //add notification
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(shouLastMessage) name:UIKeyboardDidShowNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)addRefreshViews
{
    self.chatTableView.dataSource = self;
    self.chatTableView.delegate = self;
    BangdanMjHeader *header = [BangdanMjHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    header.frame = CGRectMake(0, 0, SCREEN_W, 60);
    self.chatTableView.mj_header = header;
}
-(void)refreshData{
    [self loadChatHistory:self.currenPage];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.chatTableView.mj_header.state == MJRefreshStateRefreshing) {
            [self.chatTableView.mj_header endRefreshing];
        }
    });
//    __weak typeof(self) weakSelf = self;
    //load more
    
//    if (weakSelf.chatModel.dataSource.count > pageNum) {
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:pageNum inSection:0];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [weakSelf.chatTableView reloadData];
//            [weakSelf.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
//        });
//    }
//    [self.chatTableView.mj_header endRefreshing];
}
- (void)loadBaseViewsAndData
{
//    self.chatModel = [[ChatModel alloc]init];
//    self.chatModel.isGroupChat = NO;
//    [self.chatModel populateRandomDataSource];
    
    IFView = [[UUInputFunctionView alloc]initWithSuperVC:self];
    
    IFView.frame = CGRectMake(0, SCREEN_H-114, SCREEN_W, 50);
    IFView.delegate = self;
    [self.view addSubview:IFView];
    [self.view bringSubviewToFront:IFView];
    
//    [self.chatTableView reloadData];
//    [self tableViewScrollToBottom];
}
#pragma mark - 定制消息
// 添加自己的item
- (UUMessageFrame *)addSpecifiedItem:(NSDictionary *)dic
{
    UUMessageFrame *messageFrame = [[UUMessageFrame alloc]init];
    UUMessage *message = [[UUMessage alloc] init];
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    MyselfInfoModel *mySelf =[UserInfoManager mySelfInfoModel];
    
    [dataDic setObject:@(UUMessageFromMe) forKey:@"from"];
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSLocale* local =[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    [formater setLocale:local];
    [dataDic setObject:[formater stringFromDate:[NSDate date]] forKey:@"strTime"];
    [dataDic setObject:mySelf.avatar forKey:@"strIcon"];
    [dataDic setObject:[NSString stringWithFormat:@"%@",mySelf.mid] forKey:@"strId"];
    
    [message setWithDict:dataDic];
    UUMessageFrame *lastMessage = self.dataSource.lastObject;
    
    [message minuteOffSetStart:lastMessage.message.strTime end:dataDic[@"strTime"]];
    [message setStrIcon:self.myIconUrl];
    messageFrame.showTime = message.showDateLabel;
    [messageFrame setMessage:message];
    
    if (message.showDateLabel) {
        self.previousTime = dataDic[@"strTime"];
    }
    [self.dataSource addObject:messageFrame];
    return messageFrame;
}

-(void)addMessage:(WSmessageModel *)model insertfront:(BOOL)insertfront showTimeLabel:(BOOL)showTimeLabel
{
    NSDictionary *body = (NSDictionary*)model.body;
    NSDictionary *extras = (NSDictionary*)model.extras;
    NSInteger from =[NSString stringWithFormat:@"%@",extras[@"from"]].integerValue ;
    NSInteger to =[NSString stringWithFormat:@"%@",extras[@"to"]].integerValue ;
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    MessageType msgType = UUMessageTypeText;
    [dictionary setObject:body[@"content"] forKey:@"strContent"];
    [dictionary setObject:body[@"content"] forKey:@"strContent"];
    if (to == self.mid) {// 我发给对方的
        [dictionary setObject:@(UUMessageFromMe) forKey:@"from"];
        [dictionary setObject:self.myIconUrl forKey:@"strIcon"];
    }else{
        [dictionary setObject:@(UUMessageFromOther) forKey:@"from"];
        [dictionary setObject:self.iconUrl forKey:@"strIcon"];
    }
    [dictionary setObject:@(msgType) forKey:@"type"];
//    NSDate *date = [self zyDate:body[@"createdDate"]];
    NSString *timeStr = body[@"createdDate"];
    
//    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
//    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSLocale* local =[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
//    [formater setLocale:local];
//    NSString *date = [formater stringFromDate:[NSDate date]];
    [dictionary setObject:[timeStr substringToIndex:19] forKey:@"strTime"];
    
    [dictionary setObject:[NSString stringWithFormat:@"%ld",from] forKey:@"strId"];
//    [dictionary setObject:self.userName forKey:@"strName"];
//    if (user.avatar) {
    
//    }
    UUMessageFrame *messageFrame = [[UUMessageFrame alloc]init];
    messageFrame.messageID = [NSString stringWithFormat:@"%@",body[@"id"]].integerValue;
    UUMessage *message = [[UUMessage alloc] init];
    
    [message setWithDict:dictionary];
    if (insertfront) {
        if (showTimeLabel) {//指定需要显示时间格（后面没有数据了）
            [message minuteOffSetStart:nil end:dictionary[@"strTime"]];
        }else if(self.dataSource.count==0){//添加的第一条，且后面还有数据要添加
            [message minuteOffSetStart:dictionary[@"strTime"] end:dictionary[@"strTime"]];
        }else{
            [message minuteOffSetStart:self.previousTime end:dictionary[@"strTime"]];
        }
    }
    
    if (self.dataSource.count==1) {
        self.previousTime = timeStr;
    }
    messageFrame.showTime = message.showDateLabel;
    [messageFrame setMessage:message];
    if (message.showDateLabel) {//上次显示的时间
        self.previousTime = dictionary[@"strTime"];
    }
    if (insertfront) {
        [self.dataSource insertObject:messageFrame atIndex:0];
    }else{
        [self.dataSource addObject:messageFrame];
    }

//    [UserInfoManager requestUserInfoWithID:from finish:^(UserInfoModel *user) {
//        if (user.avatar) {
//            [dictionary setObject:user.avatar forKey:@"strIcon"];
//        }
//        UUMessageFrame *messageFrame = [[UUMessageFrame alloc]init];
//        messageFrame.messageID = [NSString stringWithFormat:@"%@",body[@"id"]].integerValue;
//        UUMessage *message = [[UUMessage alloc] init];
//        
//        [message setWithDict:dictionary];
//        
//        [message minuteOffSetStart:self.previousTime end:dictionary[@"strTime"]];
//        if (self.dataSource.count==1) {
//            self.previousTime = [date description];
//        }
//        messageFrame.showTime = message.showDateLabel;
//        [messageFrame setMessage:message];
//        if (message.showDateLabel) {
//            self.previousTime = dictionary[@"strTime"];
//        }
//        if (insertfront) {
//            [self.dataSource insertObject:messageFrame atIndex:0];
//        }else{
//            [self.dataSource addObject:messageFrame];
//        }
//    }];
    
    
    
    //    [self.dataSource addObject:messageFrame];
}
-(NSDate *)zyDate:(NSString *)dataStr{
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    NSLocale* local =[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    [formater setLocale:local];
    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate* date = [formater dateFromString:dataStr];
    return date;
}
-(NSString *)getPrivateMessageSessionKey
{
    NSInteger myId = [UserInfoManager mySelfInfoModel].mid.integerValue;
    if (self.mid>myId) {
        return [NSString stringWithFormat:@"private/dialog-%ld-%ld",self.mid,myId];
    }else{
        return [NSString stringWithFormat:@"private/dialog-%ld-%ld",myId,self.mid];
    }
}

-(void)keyboardChange:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    //adjust ChatTableView's height
    if (notification.name == UIKeyboardWillShowNotification) {
        self.bottomConstraint.constant = keyboardEndFrame.size.height+50;
    }else{
        self.bottomConstraint.constant = 50;
    }
    
    [self.view layoutIfNeeded];
    
    //adjust UUInputFunctionView's originPoint
    CGRect newFrame = IFView.frame;
    newFrame.origin.y = keyboardEndFrame.origin.y - newFrame.size.height -64;
    IFView.frame = newFrame;
    
    [UIView commitAnimations];
    
}

//tableView Scroll to bottom
-(void)shouLastMessage{
    [self tableViewScrollToBottomAnimated:YES];
}
- (void)tableViewScrollToBottomAnimated:(BOOL)animated
{
    if (self.dataSource.count==0)
        return;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.dataSource.count-1 inSection:0];
    [self.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
}
#pragma mark - webSocket
-(void)loadChatHistory:(NSInteger)page{
    NSInteger pagesize = 10;
    NSString *uri = [NSString stringWithFormat:@"system/session/loadMsg?pn=%ld&ps=%ld",page,pagesize];
    NSDictionary *dic = @{
                          @"uri":uri,
                          @"headers":@{
                                  @"messageSessionKey":[self getPrivateMessageSessionKey],
                                  },
                          };
    
    //    NSString *msg = [NSString stringWithFormat:@"{\"uri\":\"system/session/loadMsg?pn=1\"
    //                     "headers":{
    //                         "messageSessionKey":"system/notice"
    //                     }
    //                     }"]
    [[SocketManager defaultManager]sendMsg:dic.mj_JSONString];
}
-(void)requestTellRead:(NSInteger)messageId
{
    NSString *uri = [NSString stringWithFormat:@"private/receiveMsg"];
    NSDictionary *dic = @{
                          @"uri":uri,
                          @"headers":@{
                                  @"messageSessionKey":[self getPrivateMessageSessionKey],
                                  },
                          @"body":@{
                                  @"id":@(messageId),
                                  },
                          };
    
    //    NSString *msg = [NSString stringWithFormat:@"{\"uri\":\"system/session/loadMsg?pn=1\"
    //                     "headers":{
    //                         "messageSessionKey":"system/notice"
    //                     }
    //                     }"]
    [[SocketManager defaultManager]sendMsg:dic.mj_JSONString];
    [[MessageHelper shareInstance] refreshUnReadCount];
}
-(void)systemsessionlistHandle:(NSNotification *)noti{
    DbLog(@"%@",noti);
    
    WSmessageModel *model = noti.userInfo[@"model"];
    NSDictionary *extras = (NSDictionary*)model.extras;
    
    if ([noti.name isEqualToString:@"systemsessionloadMsg"]) {//消息列表,消息的数组
        [self.chatTableView.mj_header endRefreshing];
        NSArray *body = (NSArray*)model.body;
        
        if (body.count==0) {//没有数据了，不处理
            if (self.currenPage>1) {
                UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_W, 15)];
                label.textColor = [UIColor colorWithHexColorString:@"999999"];
                label.font = [UIFont systemFontOfSize:11];
                label.textAlignment = NSTextAlignmentCenter;
                label.text = @"-没有更多消息-";
                self.chatTableView.tableHeaderView = label;
            }
            
            return;
        }
        self.chatTableView.tableHeaderView = nil;
        //有数据，继续处理
        if (self.currenPage==1) {
            [self.dataSource removeAllObjects];
        }
        //        BOOL emptySource = self.dataSource.count==0;
        NSInteger i = 0;
        for (NSDictionary *msgDic in body) {//处理这些历史数据
            WSmessageModel *msg = [WSmessageModel mj_objectWithKeyValues:msgDic];
            [self addMessage:msg insertfront:YES showTimeLabel:i==body.count-1];
            i++;
        }
        
        [self.chatTableView reloadData];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:body.count inSection:0];
        
        if (self.dataSource.count ==body.count) {//刚加载的数据，直接滚到底部
            [self tableViewScrollToBottomAnimated:NO];
        }else{
            [self.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
        self.currenPage ++;
        //        NSInteger count = [NSString stringWithFormat:@"%@",extras[@"totalCnt"]].integerValue;
        
        
        //        if (self.currenPage>1) {
        //            [self.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        //        }else{
        //            [self tableViewScrollToBottom];
        //        }
        
        //        if (emptySource) {//刚才么有数据，
        //            [self tableViewScrollToBottom];
        //        }else{
        //            [self.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        //        }
    }else{
        NSDictionary *body = (NSDictionary*)model.body;
        
        NSInteger from =[NSString stringWithFormat:@"%@",extras[@"from"]].integerValue ;
        NSInteger to =[NSString stringWithFormat:@"%@",extras[@"to"]].integerValue ;
        if(from == self.mid || from == [UserInfoManager mySelfInfoModel].mid.integerValue){
            [self requestTellRead:[NSString stringWithFormat:@"%@",body[@"id"]].integerValue];
        }
        if ( from != self.mid) {//不是当前聊天对象用户发来的
            //            if (from == [UserInfoManager mySelfInfoModel].mid.integerValue && to == self.mid) {//我发来的给当前聊天者的
            //                self.currenPage = 1;
            //                [self loadChatHistory:self.currenPage];
            //            }
//            if (from == [UserInfoManager mySelfInfoModel].mid.integerValue) {//我发的
//                
//            }
            return;
        }
        
        [self addMessage:model insertfront:NO showTimeLabel:NO];
        //        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        [self.chatTableView reloadData];
        [self tableViewScrollToBottomAnimated:YES];
        //        [self.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}
#pragma mark - API
-(void)requestIsBlackHim{
    NSString *uri = [NSString stringWithFormat:@"%@/social/isInBlacklist",HeadUrl];
    NSDictionary *param = @{@"mid":@(self.mid)};
    [XYWhttpManager XYWpost:uri parameters:param inView:nil sucess:^(id result) {
        DbLog(@"%@",result);
        NSNumber *res = result[@"result"];
        if (res && res.integerValue ==1) {
            self.blackHim = YES;
        }else{
            self.blackHim = NO;
        }
    } failure:^(NSError *error) {
        CoreSVPCenterMsg(error.localizedDescription);
        DbLog(@"%@",error.localizedDescription);
    }];
}
-(void)requestToChangeBlackState:(NSString *)urlStr{
    NSString *uri = [NSString stringWithFormat:@"%@/social/%@",HeadUrl,urlStr];
    NSDictionary *param = @{@"mid":@(self.mid)};
    [XYWhttpManager XYWpost:uri parameters:param inView:nil sucess:^(id result) {
        DbLog(@"%@",result);
        if (result[@"code"]) {
            CoreSVPCenterMsg(result[@"msg"]);
            if ([urlStr isEqualToString:@"addBlacklist"]) {//拉黑对方
                [self.navigationController popViewControllerAnimated:YES];
                if ([self.delegate respondsToSelector:@selector(removeSeessionModel:)]) {
                    [self.delegate removeSeessionModel:self.sessionModel];
                }
            }
            [self requestIsBlackHim];
        }else{
            CoreSVPCenterMsg(result[@"errMsg"]);
        }
    } failure:^(NSError *error) {
        CoreSVPCenterMsg(error.localizedDescription);
        DbLog(@"%@",error.localizedDescription);
    }];

}
-(void)sendToServer:(UUMessageFrame *)messageFrame
{
    NSString *uri = [NSString stringWithFormat:@"%@/social/sendMsg",HeadUrl];
    NSDictionary *param = @{@"mid":@(self.mid),@"content":messageFrame.message.strContent};
    __weak typeof(self) wkSelf = self;
    __block typeof(messageFrame) wkMessageFrame = messageFrame;
    [XYWhttpManager XYWpost:uri parameters:param inView:nil sucess:^(id result) {
        DbLog(@"%@",result);
        NSNumber *errorCode =[result objectForKey:@"errCode"];
        if (errorCode) {
            if (errorCode.integerValue == 4009 ||errorCode.integerValue == 4008) {//被拉黑或拉黑对方
                wkMessageFrame.sendFaild = YES;
//                 [self.dataSource indexOfObject:messageFrame];
                [wkSelf.chatTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:[self.dataSource indexOfObject:wkMessageFrame] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
//                CoreSVPCenterMsg([result objectForKey:@"errMsg"]);
                if(errorCode.integerValue == 4008){
                    wkSelf.blackHim = YES;
                }
            }
        }else{
            wkMessageFrame.sendFaild = NO;
            wkMessageFrame.messageID = [NSString stringWithFormat:@"%@",result[@"id"]].integerValue;
            [wkSelf.chatTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:[self.dataSource indexOfObject:wkMessageFrame] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
        
    } failure:^(NSError *error) {
        DbLog(@"%@",error.localizedDescription);
        wkMessageFrame.sendFaild = YES;
    }];
}

-(void)deleteServerMessage:(NSInteger)messageID{
    NSString *uri = [NSString stringWithFormat:@"%@/social/deleteMsg",HeadUrl];
    NSDictionary *param = @{@"mid":@(self.mid),@"id":@(messageID)};
    [XYWhttpManager XYWpost:uri parameters:param inView:nil sucess:^(id result) {
        DbLog(@"%@",result);
        NSNumber *messageCount = result[@"messageCount"];
        if (messageCount && messageCount.integerValue ==0) {
            [self.delegate removeSeessionModel:self.sessionModel];
        }
    } failure:^(NSError *error) {
        DbLog(@"%@",error.localizedDescription);
    }];
}
-(void)blackThisUser{
//    v1/social/?mid=
    
    NSString *urlStr = @"addBlacklist";
    if (self.blackHim) {
        urlStr = @"removeBlacklist";
        [self requestToChangeBlackState:urlStr];
    }else{
        [XYWAlert XYWAlertTitle:@"加入黑名单将不再收到TA的消息" message:nil first:@"确定" firstHandle:^{
            [self requestToChangeBlackState:urlStr];
        } second:nil Secondhandle:nil cancle:@"取消" handle:^{
            
        }];
    }
    
//    NSString *uri = [NSString stringWithFormat:@"%@/social/%@",HeadUrl,urlStr];
//    NSDictionary *param = @{@"mid":@(self.mid)};
//    [XYWhttpManager XYWpost:uri parameters:param inView:nil sucess:^(id result) {
//        DbLog(@"%@",result);
//        if (result[@"code"]) {
//            CoreSVPCenterMsg(result[@"msg"]);
//            [self.navigationController popViewControllerAnimated:YES];
//        }else{
//            CoreSVPCenterMsg(result[@"errMsg"]);
//        }
//    } failure:^(NSError *error) {
//        CoreSVPCenterMsg(error.localizedDescription);
//        DbLog(@"%@",error.localizedDescription);
//    }];
}
#pragma mark - InputFunctionViewDelegate
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendMessage:(NSString *)message
{
    NSDictionary *dic = @{@"strContent": message,
                          @"type": @(UUMessageTypeText)};
    funcView.TextViewInput.text = @"";
    [funcView changeSendBtnWithPhoto:YES];
    UUMessageFrame *msgFrame =  [self dealTheFunctionData:dic];
    [self sendToServer:msgFrame];
}

- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendPicture:(UIImage *)image
{
    NSDictionary *dic = @{@"picture": image,
                          @"type": @(UUMessageTypePicture)};
    [self dealTheFunctionData:dic];
}

- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendVoice:(NSData *)voice time:(NSInteger)second
{
    NSDictionary *dic = @{@"voice": voice,
                          @"strVoiceTime": [NSString stringWithFormat:@"%d",(int)second],
                          @"type": @(UUMessageTypeVoice)};
    [self dealTheFunctionData:dic];
}

- (UUMessageFrame *)dealTheFunctionData:(NSDictionary *)dic
{
    UUMessageFrame *msgFrame =  [self addSpecifiedItem:dic];
    [self.chatTableView reloadData];
    [self tableViewScrollToBottomAnimated:YES];
    return msgFrame;
}

#pragma mark - tableView delegate & datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UUMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];
    if (cell == nil) {
        cell = [[UUMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellID"];
        cell.delegate = self;
    }
    [cell setMessageFrame:self.dataSource[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self.dataSource[indexPath.row] cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

#pragma mark - cellDelegate
- (void)headImageDidClick:(UUMessageCell *)cell userId:(NSString *)userId{
    // headIamgeIcon is clicked
    [self goToUserHomePage:userId.integerValue];
    
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:cell.messageFrame.message.strName message:@"headImage clicked" delegate:nil cancelButtonTitle:@"sure" otherButtonTitles:nil];
//    [alert show];
}
-(void)deleteCell:(UUMessageCell *)cell
{
    NSIndexPath *indexPath = [self.chatTableView indexPathForCell:cell];
    UUMessageFrame *msgFrame = self.dataSource[indexPath.row];
    if (msgFrame.messageID>0) {//有ID，需要告诉服务器删除这个消息
        [self deleteServerMessage:msgFrame.messageID];
    }
    [self.dataSource removeObjectAtIndex:indexPath.row];
    [self.chatTableView  deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath]withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)retryClick:(UUMessageCell *)cell
{
    [self sendToServer:cell.messageFrame];
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
