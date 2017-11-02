//
//  UHCenterViewController.m
//  ZuoYou
//
//  Created by xueyongwei on 16/10/18.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "UHCenterViewController.h"
#import "YXIgnoreHeaderTouchAndRecognizeSimultaneousTableView.h"
#import "YXTabView.h"
#import "YX.h"
#import "UHNavigationView.h"
#import "XYWAlert.h"
#import "EditGerenViewController.h"
#import "UserInfoTableViewCell.h"
#import "PKDetailViewController.h"
#import "HtmlViewController.h"
//#import "ChatViewController.h"
#import "ChatPersonalViewController.h"
@interface UHCenterViewController ()<UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate>
@property (nonatomic, strong) YXIgnoreHeaderTouchAndRecognizeSimultaneousTableView *tableView;
@property (nonatomic, assign) BOOL isMe;
@property (nonatomic, assign) BOOL isTopIsCanNotMoveTabView;
@property (nonatomic, assign) BOOL isTopIsCanNotMoveTabViewPre;

@property (nonatomic, assign) BOOL canScroll;
@property (nonatomic,strong)NSMutableArray *BeansOffersDataSource;
@property (nonatomic,strong) UHNavigationView *navigationView;
@property (nonatomic,strong) UIButton *careBtn;
@property (nonatomic,strong)NSNumber *receiveBeans;
@property (nonatomic,strong)YXTabView *contentTableView;
@property (nonatomic,strong)UserInfoTableViewCell *userInfoCell;
@property (nonatomic,weak)UserInfoModel *userInfoPointer;
@property (nonatomic,assign)BOOL donnotHiddenNavi;
@end

@implementation UHCenterViewController
-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([viewController isKindOfClass:[self class]]) {
        
    }else{
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.userInfoCell) {
        [self customUserInfoView:self.userInfoCell];
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.contentTableView.tabTitleView.videoTableView) {
        [self.contentTableView.tabTitleView.videoTableView stopPlay];
    }
    
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.navigationController.delegate = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.donnotHiddenNavi = NO;
    self.navigationController.delegate = self;
    self.isMe = [UserInfoManager isMeOfID:self.mid];
    _canScroll = YES;
    [self initUI];
}
#pragma mark ---准备数据
-(void)prepareDataTitle:(YYLabel *)titleLabel editBtn:(UIButton *)editBtn
{
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@%@",HeadUrl,@"/social/info"] parameters:@{@"mid":@(self.mid)} inView:nil sucess:^(id result) {
        [CoreSVP dismiss];
        DbLog(@"请求成功");
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSMutableAttributedString *text = [NSMutableAttributedString new];
            UIFont *font = [UIFont systemFontOfSize:13];
            NSString *title = @"消耗 ";
            [text appendAttributedString:[[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}]];
            
            UIImage *image = [UIImage imageNamed:@"胜方获得金豆"];
            image = [UIImage imageWithCGImage:image.CGImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
            NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:image contentMode:UIViewContentModeScaleAspectFit attachmentSize:CGSizeMake(13, 13) alignToFont:font alignment:YYTextVerticalAlignmentCenter];
            [text appendAttributedString:attachText];
            
            [text appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",[result objectForKey:@"consume"]] attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}]];
            
            text.yy_alignment = NSTextAlignmentCenter;
            
            titleLabel.attributedText = text;
            self.receiveBeans = [result objectForKey:@"incomeBeans"];
        }
        if (self.isMe) {//是我本人
            editBtn.hidden = NO;
        }else{
            editBtn.hidden = YES;
            [self initBottomViewIsFans:[result objectForKey:@"isFans"] isFollow:[result objectForKey:@"isFollow"]];
        }
//        NSNumber *isFans =[result objectForKey:@"isFans"];
//        NSNumber *isFollow =[result objectForKey:@"isFollow"];
//        [self careStatusWithFans:isFans andFollow:isFollow];
    } failure:^(NSError *error) {
        [CoreSVP dismiss];
        
    }];
}
/*
-(void)prepareDouziGongxianbang:(DouziGongxianTableViewCell *)cell
{
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@%@",HeadUrl,@"/users/items"] parameters:@{@"mid":@(self.mid)} inView:nil sucess:^(id result) {
        if ([result isKindOfClass:[NSArray class]]) {
            [self.BeansOffersDataSource removeAllObjects];
            for (NSDictionary *dic in result) {
                BeansOffersModel *model = [BeansOffersModel mj_objectWithKeyValues:dic];
                [self.BeansOffersDataSource addObject:model];
            }
            [self customDouziGongxian:cell];
        }
        
        DbLog(@"请求成功");
    } failure:^(NSError *error) {
        
        
    }];
}
*/
-(void)getUserInfo:(NSInteger)userId
{
    if (userId<5) {
        return;
    }
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@%@",HeadUrl,@"/users/info"] parameters:@{@"ids":[NSString stringWithFormat:@"%ld",(long)userId]} inView:nil sucess:^(id result) {
        if ([result isKindOfClass:[NSArray class]]) {
            NSArray *users = result;
            NSDictionary *user = users.firstObject;
            if (user) {
                UserInfoModel *userModel = [UserInfoModel mj_objectWithKeyValues:user];
                self.userInfoPointer = userModel;
//                UserInfoTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//                cell.userNameLabel.text = userModel.name;
//                cell.userRoleIconImgV.image = userModel.memberRoleIcon;
//                [cell.userIconImgV sd_setImageWithURL:[NSURL URLWithString:userModel.avatar] placeholderImage:[UIImage imageNamed:@"1"]];
//                if (userModel.memberRolesDesc.length>0) {
//                    cell.userRoleDesclabel.text = userModel.memberRolesDesc;
//                    cell.userRoleDescLabelHeightConst.constant = 13;
//                    cell.userRoleIconImgV.userInteractionEnabled = YES;
//                    UITapGestureRecognizer *tapV = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapUserRoleIconView:)];
//                    [cell.userRoleIconImgV addGestureRecognizer:tapV];
//                }else{
//                    cell.userRoleDescLabelHeightConst.constant = 0;
//                }
//                cell.userSignLabel.text = userModel.signature;
//                if (userModel.gender ==0) {
//                    NSString *imgName = @"uhgirl";
//                    cell.userGenderImgV.image = [UIImage imageNamed:imgName];
//                }else if (userModel.gender ==1){
//                    NSString *imgName = @"uhman";
//                    cell.userGenderImgV.image = [UIImage imageNamed:imgName];
//                }
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
    } failure:^(NSError *error) {
        
    }];
}
#pragma mark ---UI
-(void)initUI{
    [self initPicView];
    CGRect rect = self.isMe?CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)):CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-kBottomBarHeight);
    _tableView = [[YXIgnoreHeaderTouchAndRecognizeSimultaneousTableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.showsVerticalScrollIndicator = NO;
//    _tableView.rowHeight = UITableViewAutomaticDimension;
//    _tableView.rowHeight = 120;
    
    [self.view addSubview:_tableView];
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 64)];
    headView.backgroundColor = [UIColor clearColor];
    _tableView.tableHeaderView = headView;
    
    [self initTopView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:kLeaveTopNotificationName object:nil];
}

-(void)acceptMsg : (NSNotification *)notification{
    NSLog(@"acceptMsg %@",notification);
    NSDictionary *userInfo = notification.userInfo;
    NSString *canScroll = userInfo[@"canScroll"];
    if ([canScroll isEqualToString:@"1"]) {
        self.canScroll = YES;
    }
}
//-(void)setCanScroll:(BOOL)canScroll
//{
//    _canScroll = canScroll;
//    DbLog(@"!!!");
//}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)initPicView{
    UIImageView *picView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame))];
//    picView.image = [UIImage imageNamed:@"item.jpg"];
    picView.backgroundColor = [UIColor colorWithHexColorString:@"ff4a4b"];
    picView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage:)];
    [picView addGestureRecognizer:tapGesture];
    [self.view addSubview:picView];
}

-(void)clickImage:(UITapGestureRecognizer *)gesture{
    NSLog(@"点击图片操作");
}

-(void)initTopView{
    UHNavigationView *topView = [[UHNavigationView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kTopBarHeight)];
    topView.backgroundColor = [UIColor colorWithHexColorString:@"ff4a4b"];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(13, 20, 60, 44);
    backBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [backBtn setImage:[UIImage imageNamed:@"uhback"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"uhback_click"] forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(onBackClick:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backBtn];
    UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    editBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    editBtn.frame = CGRectMake(self.view.frame.size.width-73, 20, 60, 44);
    [editBtn setImage:[UIImage imageNamed:@"uh编辑"] forState:UIControlStateNormal];
    [editBtn setImage:[UIImage imageNamed:@"uh编辑"] forState:UIControlStateHighlighted];
    [editBtn addTarget:self action:@selector(onEditClick:) forControlEvents:UIControlEventTouchUpInside];
    editBtn.hidden = YES;
    [topView addSubview:editBtn];
    
    topView.editBtn = editBtn;
    
    YYLabel *titleLabel = [[YYLabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2-50, 33, 100, 18)];
    topView.titleLabel = titleLabel;
    [topView addSubview:titleLabel];
    
    [self.view addSubview:topView];
     [self prepareDataTitle:titleLabel editBtn:editBtn];
}

-(void)initBottomViewIsFans:(NSNumber *)isFnas isFollow:(NSNumber *)isFollow{
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)-kBottomBarHeight, CGRectGetWidth(self.view.frame), kBottomBarHeight)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    
    
    UILabel *SepLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_W, 1)];
    SepLabel.backgroundColor = [UIColor colorWithHexColorString:@"e1e1e1"];
    [bottomView addSubview:SepLabel];
    
    UIButton *careBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect careFrame = bottomView.bounds;
    careFrame.size.width /= 2;
    careBtn.frame =  careFrame;
    self.careBtn = careBtn;
    [careBtn addTarget:self action:@selector(onCareBtn:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:careBtn];
    [self careStatusWithFans:isFnas andFollow:isFollow];
    
    CGRect chatFrame = careFrame;
    chatFrame.origin.x = careFrame.size.width;
    UIButton *chatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    chatBtn.frame = chatFrame;
    [chatBtn addTarget:self action:@selector(onChatBtn:) forControlEvents:UIControlEventTouchUpInside];
    [chatBtn setImage:[UIImage imageNamed:@"personal私信"] forState:UIControlStateNormal];
//    [chatBtn setTitle:@"chat" forState:UIControlStateNormal];
    [bottomView addSubview:chatBtn];
    
//    CGRect SepLabelVFrame = CGRectMake(0, 0, 1, chatFrame.size.height/2);
    UILabel *SepLabelV = [[UILabel alloc] initWithFrame:CGRectMake(chatFrame.origin.x, chatFrame.size.height*0.25, SINGLE_LINE_WIDTH, chatFrame.size.height/2)];
//    SepLabelV.center = bottomView.center;
    SepLabelV.backgroundColor = [UIColor colorWithHexColorString:@"e1e1e1"];
    [bottomView addSubview:SepLabelV];
    
}
-(void)customUserInfoView:(UserInfoTableViewCell *)cell
{
    if (self.userInfoPointer) {
        cell.userNameLabel.text = self.userInfoPointer.name;
        cell.userRoleIconImgV.image = self.userInfoPointer.memberRoleIcon;
        [cell.userIconImgV sd_setImageWithURL:[NSURL URLWithString:self.userInfoPointer.avatar] placeholderImage:[UIImage imageNamed:@"1"]];
        if (self.userInfoPointer.memberRolesDesc.length>0) {
            cell.userRoleDesclabel.text = self.userInfoPointer.memberRolesDesc;
            cell.userRoleDescLabelHeightConst.constant = 13;
            cell.userRoleIconImgV.userInteractionEnabled = YES;
            UITapGestureRecognizer *tapV = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapUserRoleIconView:)];
            [cell.userRoleIconImgV addGestureRecognizer:tapV];
        }else{
            cell.userRoleDescLabelHeightConst.constant = 0;
        }
        cell.userSignLabel.text = self.userInfoPointer.signature;
        if (self.userInfoPointer.gender ==0) {
            NSString *imgName = @"uhgirl";
            cell.userGenderImgV.image = [UIImage imageNamed:imgName];
        }else if (self.userInfoPointer.gender ==1){
            NSString *imgName = @"uhman";
            cell.userGenderImgV.image = [UIImage imageNamed:imgName];
        }
        return;
    }else{
        
    }
    //获取用户信息
    MyselfInfoModel *my = [UserInfoManager mySelfInfoModel];
    if (!self.mid || self.mid == my.mid.integerValue) {//我自己，显示编辑按钮
        self.navigationView.editBtn.hidden = NO;
        [self getUserInfo:my.mid.integerValue];
    }else{
        self.navigationView.editBtn.hidden = YES;
        [self getUserInfo:self.mid];
    }
    
}
-(void)tapUserRoleIconView:(UITapGestureRecognizer *)recognizer
{
    HtmlViewController *htmlV = [HtmlViewController new];
//    htmlV.webTitle = self.userInfoCell.userRoleDesclabel.text;
    htmlV.url = @"http://api.hongdoujiao.net:9090/v1/html/referral.html";
    [self.navigationController pushViewController:htmlV animated:YES];
}

#pragma mark ---tableView的代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger section = indexPath.section;
    CGFloat height = 0.;
    if (section==0) {
        if (self.userInfoCell) {
            self.userInfoCell.userSignLabel.text = self.userInfoPointer.signature;
            self.userInfoCell.userSignLabel.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width-40;
            self.userInfoCell.userRoleDesclabel.text = self.userInfoPointer.memberRolesDesc;
            [self.userInfoCell setNeedsUpdateConstraints];
            [self.userInfoCell updateConstraintsIfNeeded];
        }
        CGSize size = [self.userInfoCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        NSLog(@"h=%f", size.height + 1);
        return 1  + size.height;
//        height = 190;
////        if (self.userInfoCell.userSignLabel.text.length>0) {//有签名
////            height +=50;
////        }
//        if (self.userInfoCell.userRoleDesclabel.text.length>0) {//有描述
//            height += 50;
//        }
    }else if(section==1){
        height =  self.isMe?CGRectGetHeight(self.view.frame)-kTopBarHeight:CGRectGetHeight(self.view.frame)-kBottomBarHeight-kTopBarHeight;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger section  = indexPath.section;
    
    if (section==0) {
        UserInfoTableViewCell *infoCell = [tableView dequeueReusableCellWithIdentifier:@"UserInfoTableViewCell"];
        if (!infoCell) {
            infoCell = [[[NSBundle mainBundle]loadNibNamed:@"UserInfoTableViewCell" owner:self options:nil]lastObject];
            self.userInfoCell = infoCell;
        }
        [self customUserInfoView:infoCell];
        return infoCell;
    }else if(section==1){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contentTableView"];
        if (!cell) {
            cell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"contentTableView"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            NSArray *tabConfigArray = @[@{
                                            @"title":@"战绩",
                                            @"view":@"UHexploitsTableView",
                                            @"data":@"youdoNotme",
                                            @"position":@0
                                            },@{
                                            @"title":@"视频",
                                            @"view":@"UHVideosTableView",
                                            @"data":@"youdoNotme",
                                            @"position":@1
                                            },@{
                                            @"title":@"关注",
                                            @"view":@"UHCareTbaleView",
                                            @"data":@"youdoNotme",
                                            @"position":@2
                                            },@{
                                            @"title":@"粉丝",
                                            @"view":@"UHFansTableView",
                                            @"data":@"youdoNotme",
                                            @"position":@3
                                            }];
            YXTabView *tabView = [[YXTabView alloc] initWithTabConfigArray:tabConfigArray userId:@(self.mid) block:^(NSDictionary *dict) {
                //VC执行的操作
                if ([[dict objectForKey:@"action"] isEqualToString:@"push"]) {//push操作
                    if ([[dict objectForKey:@"class"] isEqualToString:@"PKDetailViewController"]) {
                        PKDetailViewController *pdVC = [[PKDetailViewController alloc]initWithNibName:@"PKDetailViewController" bundle:nil];
                        NSNumber *pkid =[dict objectForKey:@"calssID"];
                        pdVC.pkId = pkid.integerValue;
                        [self.navigationController pushViewController:pdVC animated:YES];
                    }else if ([[dict objectForKey:@"class"] isEqualToString:@"UHCenterViewController"]){
                        UHCenterViewController *vc = [[UHCenterViewController alloc]init];
                        NSNumber *mid =[dict objectForKey:@"calssID"];
                        vc.mid = mid.integerValue;
                        [self.navigationController pushViewController:vc animated:YES];
                    }
                }
            }];
            self.contentTableView = tabView;
            [cell.contentView addSubview:tabView];
        }
        return cell;
    }
    return nil;
}
/*
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1) {
        DbLog(@"豆子贡献榜");
        BeansOfferViewController *beansVC = [[BeansOfferViewController alloc]init];
        beansVC.totalBeans = self.receiveBeans.integerValue;
        beansVC.userId = self.mid;
        [self.navigationController pushViewController:beansVC animated:YES];
    }
}
 */
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat tabOffsetY = [_tableView rectForSection:1].origin.y-kTopBarHeight;
    CGFloat offsetY = scrollView.contentOffset.y;
    _isTopIsCanNotMoveTabViewPre = _isTopIsCanNotMoveTabView;
    DbLog(@"offsetY=%f  tabOffsetY=%f ",offsetY,tabOffsetY);
    if (offsetY>=tabOffsetY) {
        scrollView.contentOffset = CGPointMake(0, tabOffsetY);
        _isTopIsCanNotMoveTabView = YES;
        DbLog(@"_isTopIsCanNotMoveTabView = YES");
    }else{
        _isTopIsCanNotMoveTabView = NO;
        DbLog(@"_isTopIsCanNotMoveTabView = NO");
    }
    if (!_canScroll) {
        self.tableView.contentOffset = CGPointMake(0, tabOffsetY);
    }
    if (_isTopIsCanNotMoveTabView != _isTopIsCanNotMoveTabViewPre) {
        if (!_isTopIsCanNotMoveTabViewPre && _isTopIsCanNotMoveTabView) {
            DbLog(@"滑动到顶端");
            [[NSNotificationCenter defaultCenter] postNotificationName:kGoTopNotificationName object:nil userInfo:@{@"canScroll":@"1"}];
            self.canScroll = NO;
        }
//        if (!_canScroll) {
//            self.tableView.contentOffset = CGPointMake(0, tabOffsetY);
//        }
        if(_isTopIsCanNotMoveTabViewPre && !_isTopIsCanNotMoveTabView){
            DbLog(@"离开顶端");
            
        }
    }
    
}
-(void)onCareBtn:(UIButton *)sender
{
    if (sender.tag == 100) {//还未关注
        [self onGuanzhuClick:sender];
    }else{//已关注
        [XYWAlert XYWAlertTitle:@"确定不再关注TA吗？" message:nil first:@"确定" firstHandle:^{
            [self onCancleGuanzhu:nil];
            
        } second:nil Secondhandle:nil cancle:@"取消" handle:nil];
    }
}
-(void)onChatBtn:(UIButton *)sender{
//    ChatViewController *chat = [[ChatViewController alloc]init];
    if (self.backWhenGoToChatPage) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        ChatPersonalViewController *chat = [[ChatPersonalViewController alloc]init];
        chat.mid = self.mid;
        chat.userName = self.userInfoCell.userNameLabel.text;
        chat.backWhenGoToHomePage = YES;
        [self.navigationController pushViewController:chat animated:YES];
    }
    
}
- (void)onGuanzhuClick:(UIButton *)sender {
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/social/follow",HeadUrl];
    NSDictionary *param = @{@"mid":@(self.mid)};
    
    [XYWhttpManager XYWpost:urlStr parameters:param inView:nil sucess:^(id result) {
        DbLog(@"%@",result);
        NSNumber *isFans = [result objectForKey:@"isFans"];
        NSNumber *isFollow = [result objectForKey:@"isFollow"];
        [self careStatusWithFans:isFans andFollow:isFollow];
        [self.contentTableView.tabTitleView reloadTabNumbData];
    } failure:^(NSError *error) {
        
    }];
}
-(void)onCancleGuanzhu:(UIButton *)sender
{
    //    /social/cancelfollow
    NSString *urlStr = [NSString stringWithFormat:@"%@/social/cancelfollow",HeadUrl];
    NSDictionary *param = @{@"mid":[NSString stringWithFormat:@"%ld",(long)self.mid]};
    
    [XYWhttpManager XYWpost:urlStr parameters:param inView:nil sucess:^(id result) {
        DbLog(@"%@",result);
        NSNumber *isFans = [result objectForKey:@"isFans"];
        NSNumber *isFollow = [result objectForKey:@"isFollow"];
        [self careStatusWithFans:isFans andFollow:isFollow];
        [self.contentTableView.tabTitleView reloadTabNumbData];
    } failure:^(NSError *error) {
        
    }];
}
-(void)careStatusWithFans:(NSNumber*)isFans andFollow:(NSNumber *)isFollow
{
    NSString *imgName =isFollow.intValue==1?isFans.intValue==1?@"粉丝互相关注":@"粉丝已关注":@"粉丝关注";
    self.careBtn.tag = isFollow.intValue+100;
    [self.careBtn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
}

- (void)onBackClick:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)onEditClick:(UIButton *)sender{
    EditGerenViewController *edVC = [[EditGerenViewController alloc]initWithNibName:@"EditGerenViewController" bundle:nil];
    [self.navigationController pushViewController:edVC animated:YES];
}


@end
