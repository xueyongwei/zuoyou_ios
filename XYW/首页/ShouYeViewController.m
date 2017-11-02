//
//  ShouYeViewController.m
//  HDJ
//
//  Created by xueyongwei on 16/5/9.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "ShouYeViewController.h"
//#import "JingXuanViewController.h"
//#import "ChosenTableViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "VersusListViewController.h"
#import "XiaoxiSessionModel.h"
#import "UITabBar+badge.h"
#import "XYWAlert.h"
#import "ReviewMovieViewController.h"
#import "ChartsViewController.h"
#import "UIImage+Color.h"
#import "ChosenWithBannerViewController.h"
#import "GlobalInstance.h"
#import "MessageHelper.h"

#pragma mark --- UploadProgressWindow
@interface UploadProgressWindow()

@end
@implementation UploadProgressWindow

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    return view == self?nil:view;
}

@end

#pragma mark --- ShouYeViewController

@interface ShouYeViewController ()<UIAlertViewDelegate,UIWebViewDelegate,UIScrollViewDelegate>
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIButton *currentChildrenBtn;
@property (nonatomic,strong) UIButton *jxBtn;
@property (nonatomic,strong) UIButton *dtBtn;
@property (nonatomic,strong) UILabel *childrenXian;
@property (nonatomic,strong) UIView *naviView;

@end

@implementation ShouYeViewController
{
    BOOL transiting;
    UIViewController *currentVC;
    
}
-(UIView *)naviView
{
    if (!_naviView) {
         _naviView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 110, 44)];
        //精选
        self.jxBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.jxBtn.frame = CGRectMake(0, 0, 50, 44);
        [self.jxBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [self.jxBtn setTitle:@"精选" forState:UIControlStateNormal];
        [self.jxBtn setTitleColor:[UIColor colorWithHexColorString:@"ff4a4b"] forState:UIControlStateSelected];
        [self.jxBtn setTitleColor:[UIColor colorWithHexColorString:@"333333"] forState:UIControlStateNormal];
        self.jxBtn.tag = 100;
        [self.jxBtn addTarget:self action:@selector(onTitBenCLick:) forControlEvents:UIControlEventTouchDown];
        [_naviView addSubview:self.jxBtn];
        //动态
        self.dtBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.dtBtn.frame = CGRectMake(60, 0, 50, 44);
        [self.dtBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [self.dtBtn setTitle:@"动态" forState:UIControlStateNormal];
        [self.dtBtn setTitleColor:[UIColor colorWithHexColorString:@"ff4a4b"] forState:UIControlStateSelected];
        [self.dtBtn setTitleColor:[UIColor colorWithHexColorString:@"333333"] forState:UIControlStateNormal];
        self.dtBtn.tag = 101;
        [self.dtBtn addTarget:self action:@selector(onTitBenCLick:) forControlEvents:UIControlEventTouchDown];
        [_naviView addSubview:self.dtBtn];
        
        self.childrenXian = [[UILabel alloc]initWithFrame:CGRectMake(0, 41.5, 50, 2.5)];
        self.childrenXian.backgroundColor = [UIColor colorWithHexColorString:@"ff4a4b"];
        [_naviView addSubview:self.childrenXian];
        
        //设置选中精选标签
        self.jxBtn.selected = YES;
        self.currentChildrenBtn = self.jxBtn;
    }
    return _naviView;
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.navigationController) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    if (self.navigationController) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}
-(void)prepareMessageList{
    [[SocketManager defaultManager] sendMsg:[NSString stringWithFormat:@"{uri:\"system/session/list\"}"]];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self customNavi];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self prepareChildrenVC];
    
    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
    NSNumber *openTimes = [usf objectForKey:GLOUBOPENTIMES];
    NSDate *date = [usf objectForKey:GLOUBXIACIZAISHUO];
    
    if ((openTimes&&openTimes.integerValue==3 && !date)||(date&&[date isPass7Days])) {//打开三次或者不再提醒超过一周
        UIAlertView *alv = [[UIAlertView alloc]initWithTitle:@"喜欢左右吗?" message:nil delegate:self cancelButtonTitle:@"下次再说" otherButtonTitles:@"喜欢去好评",@"不喜欢要吐槽", nil];
        alv.delegate = self;
        [alv show];
    }
    
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(systemsessionlistHandle:) name:@"systemsessionlist" object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(systemsessionlistHandle:) name:@"privatedialog" object:nil];
    
    //上传时进度条就显示在这个window上
    self.uploadProgressWindow = [[UploadProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.uploadProgressWindow.windowLevel = UIWindowLevelAlert;
    self.uploadProgressWindow.backgroundColor = [UIColor clearColor];
    //显示statusView，不写该段代码无法显示
    self.uploadProgressWindow.hidden = NO;
//    //不要急着连接ws，确保API先行，状态注册到radios
    [MessageHelper shareInstance].homepage = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self prepareMessageList];
    });
}
-(void)prepareChildrenVC
{
    self.scrollView = [UIScrollView new];
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.left.equalTo(self.view);
    }];
    self.scrollView.bounces = YES;
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width*2, 0);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;

    CGRect frame = self.scrollView.bounds;

    //精选
    ChosenWithBannerViewController *csVC = [[ChosenWithBannerViewController alloc]initWithStyle:UITableViewStyleGrouped];
    csVC.requestURL = @"/events/choice";
    csVC.noMoreDataPage = YES;
    csVC.view.frame = frame;
    [self addChildViewController:csVC];
    [self.scrollView addSubview:csVC.view];
    
    
    //动态
    VersusListViewController *dmVC = [[VersusListViewController alloc]initWithStyle:UITableViewStylePlain];
    dmVC.requestURL = @"/versus/follow";
    dmVC.noMoreDataMessage = @"你关注的ta还未参与PK哦~";
    frame.origin.x = self.view.bounds.size.width;
    dmVC.view.frame = frame;
    [self addChildViewController:dmVC];
    [self.scrollView addSubview:dmVC.view];
    
    currentVC = csVC;
}

-(void)dealHeadLine:(UIView *)view
{
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        UIView *nv = [[UIView alloc]initWithFrame:view.frame];
        nv.backgroundColor = [UIColor colorWithHexColorString:@"e6e6e6"];
        [view.superview addSubview:nv];
        [view removeFromSuperview];
    }else{
        for (UIView *subview in view.subviews) {
            [self dealHeadLine:subview];
        }
    }
}

-(void)customNavi
{
    //导航栏
    self.navigationItem.titleView = self.naviView;
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    //自定义导航栏可手势返回
    if (self.navigationController) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -15;//修正间隙
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 44, 44);
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [btn setImage:[UIImage imageNamed:@"榜单icon"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"榜单icon-click"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(onRankingClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,rightBar];
    //去除导航栏底部黑线和右上角黑影
//    [self dealHeadLine:self.navigationController.navigationBar];
}
-(void)onRankingClick:(UIButton *)sender
{
    ChartsViewController *bdVC = [[ChartsViewController alloc]init];
    bdVC.hidesBottomBarWhenPushed = YES;
    bdVC.title = @"榜单";
    [self.navigationController pushViewController:bdVC animated:YES];
}
-(void)onTitBenCLick:(UIButton *)sender
{
    if (sender == self.currentChildrenBtn) {
        return;
    }
    CGRect rec = self.childrenXian.frame;
    rec.origin.x = 60*(sender.tag -100);
    [UIView animateWithDuration:0.2 animations:^{
        self.childrenXian.frame = rec;
    }];
    
    self.currentChildrenBtn.selected = NO;
    sender.selected = YES;
    [self changeToVC:sender.tag-100];
    self.currentChildrenBtn = sender;
}

-(void)changeToVC:(NSInteger)idx
{
    [self.scrollView setContentOffset:CGPointMake(idx*self.view.bounds.size.width, 0) animated:YES];
    return;
    
//    UIViewController *nxtVC = [self.childViewControllers objectAtIndex:idx];
//    if (transiting||(currentVC == nxtVC)) {
//        return;
//    }
//    transiting = YES;
//    nxtVC.view.frame = self.view.bounds;
//    [self transitionFromViewController:currentVC toViewController:nxtVC duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
//        
//    } completion:^(BOOL finished) {
//        if (finished) {
//            [nxtVC didMoveToParentViewController:self];
//            [currentVC willMoveToParentViewController:nil];
//            transiting = NO;
//            currentVC = nxtVC;
//        }else{
//            
//        }
//    }];
    
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint offSet = scrollView.contentOffset;
    CGFloat idx = offSet.x/self.view.width;
    
    UIButton *btn = [self.naviView viewWithTag:idx +100];
    if (self.currentChildrenBtn != btn) {
        CGRect rec = self.childrenXian.frame;
        rec.origin.x = 60*idx;
        [UIView animateWithDuration:0.2 animations:^{
            self.childrenXian.frame = rec;
        }];
        self.currentChildrenBtn.selected = NO;
        btn.selected = YES;
        self.currentChildrenBtn = btn;
    }
    
    
}
#pragma mark ---alertView代理方法
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1001) {
        if (buttonIndex ==1) {
            if ([QQApiInterface isQQInstalled]) {
                UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
                NSURL *url = [NSURL URLWithString:@"mqq://im/chat?chat_type=wpa&uin=360669782&version=1&src_type=web"];
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                webView.delegate = self;
                [webView loadRequest:request];
                [self.view addSubview:webView];
            }else{
                UIPasteboard *pboard = [UIPasteboard generalPasteboard];
                pboard.string = @"360669782";
                CoreSVPCenterMsg(@"QQ号已复制至粘贴板");
            }
        }
        return;
    }
    
    
    switch (buttonIndex) {
        case 0:{
                NSDate *now = [NSDate date];
                NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
                [usf setObject:now forKey:GLOUBXIACIZAISHUO];
                [usf synchronize];
        }
            break;
        case 1:{
            NSString *str = [NSString stringWithFormat:@"http://itunes.apple.com/us/app/id%d",1144064169];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
            NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
            [usf removeObjectForKey:GLOUBXIACIZAISHUO];
            [usf synchronize];
        }
            break;
        case 2:{
            YijianfankuiViewController *yjVC = [[YijianfankuiViewController alloc]initWithNibName:@"YijianfankuiViewController" bundle:nil];
            [self.navigationController pushViewController:yjVC animated:YES];
            NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
            [usf removeObjectForKey:GLOUBXIACIZAISHUO];
            [usf synchronize];
        }
            break;
        default:
            break;
    }
    
}



#pragma mark ---通知的handle
-(void)systemsessionlistHandle:(NSNotification *)noti
{
    DbLog(@"%@",noti.userInfo);
    if ([noti.name isEqualToString:@"systemsessionlist"]) {
        WSmessageModel *model = (WSmessageModel*)noti.userInfo[@"model"];
        if (![model.body isKindOfClass:[NSArray class]]) {
            DbLog(@"is not the class we want(nsarray)!");
        }
        NSInteger totalUnreadCount = [NSString stringWithFormat:@"%@",model.extras[@"totalUnreadCount"]].integerValue;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (totalUnreadCount>0) {
                [self.tabBarController.tabBar showBadgeOnItemIndex:3];
            }else{
                [self.tabBarController.tabBar hideBadgeOnItemIndex:3];
            }
        });
//        NSArray *bodys = (NSArray *)model.body;
//        for (NSDictionary *dic in bodys) {
//            XiaoxiSessionModel *model = [XiaoxiSessionModel mj_objectWithKeyValues:dic];
//            [[GlobalInstance shareInstance].sessionListDataSource addObject:model];
//        }
    }else if ([noti.name isEqualToString:@"privatedialog"]) {
        [self prepareMessageList];
        DbLog(@"%@",[self getCurrentVC]);
    }
    
}
-(void)setTabbarUnderCount:(NSInteger)unreadCount{
    if (unreadCount>0) {
        [self.tabBarController.tabBar showBadgeOnItemIndex:3];
    }else{
        [self.tabBarController.tabBar hideBadgeOnItemIndex:3];
    }
}
- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
