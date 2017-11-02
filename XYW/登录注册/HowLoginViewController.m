//
//  HowLoginViewController.m
//  HDJ
//
//  Created by xueyongwei on 16/6/1.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "HowLoginViewController.h"
#import "AppDelegate.h"
#import "SchemesModel.h"
#import "PKDetailViewController.h"
#import "WelcomeView.h"
#import "UserInfoManager.h"
#import "SocketManager.h"
#import "XYWAlert.h"
#import "XGPush.h"
@interface HowLoginViewController ()
//@property(nonatomic,strong)MPMoviePlayerController *moviePlayer;
//@property(nonatomic ,strong)AVAudioSession *avaudioSession;
//@property(nonatomic,strong)SchemesModel *scheme;
@end

@implementation HowLoginViewController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    if (_moviePlayer) {
//        [self.moviePlayer pause];
//    }
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"登录主页面"];
//    [self checkWelcome];
//    if (_moviePlayer) {
//        [self.moviePlayer play];
//    }
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
//    [self prepareMovie];
    [self custonLoginView];
    [self customLoginNavi];
    [self checkFirstUse];
   
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(checkWelcome) name:@"applicationDidBecomeActive" object:nil];
    
    // Do any additional setup after loading the view from its nib.
}

-(void)checkFirstUse
{
    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
    if (![usf objectForKey:KFirstUse]) {
        WelcomeView *wel = [WelcomeView new];
        __block WelcomeView *wkWel = wel;
        [wel showStartClick:^{
            [UIView animateWithDuration:0.5 animations:^{
                wkWel.transform = CGAffineTransformScale(wkWel.transform, 2, 2);
                wkWel.alpha = 0;
            } completion:^(BOOL finished) {
                for (UIView *view in wkWel.subviews) {
                    [view removeFromSuperview];
                }
                [wkWel removeFromSuperview];
                wkWel = nil;
                NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
                [usf setObject:@YES forKey:KFirstUse];
                [usf synchronize];
            }];
        }];
    }
}
-(void)checkWaitingSchemes
{
    DbLog(@"捕获了打开应用的检测，但是没有登录我不处理。");
}
-(void)schemesListen:(NSNotification *)noti
{
    DbLog(@"捕获了打开应用的通知，但是没有登录我保存在本地不做处理。");
    DbLog(@"class = %@",NSStringFromClass(self.class));
    DbLog(@"listen %@",noti);
    //保存起来，等登录后再发一次通知
    NSDictionary *dic = noti.object;
    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
    [usf setObject:dic forKey:@"SCHEMES"];
    [usf synchronize];
}
-(void)customLoginNavi
{
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithHexColorString:@"808080"]];
    //选择自己喜欢的颜色
    UIColor * color = [UIColor colorWithHexColorString:@"333333"];
    
    //这里我们设置的是颜色，还可以设置shadow等，具体可以参见api
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:18],NSFontAttributeName,color,NSForegroundColorAttributeName,nil];
    //    NSDictionary * dict = [NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
    
    [[UINavigationBar appearance] setTitleTextAttributes:dict];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 20, 35);
    btn.backgroundColor = [UIColor redColor];
    btn.contentMode = UIViewContentModeLeft;
    [btn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onBackClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                   target:nil action:nil];
    negativeSpacer.width = 10;//这个数值可以根据情况自由变化
    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc]initWithCustomView:btn];
    //    [UINavigationBar appearance]
    self.navigationItem.leftBarButtonItems = @[negativeSpacer,leftBar];
    //    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
    
}
//-(void)prepareMovie
//{
//    self.avaudioSession = [AVAudioSession sharedInstance];
//    NSError *error = nil;
//    [self.avaudioSession setCategory:AVAudioSessionCategoryAmbient error:&error];
//    
//    NSString *urlStr = [[NSBundle mainBundle]pathForResource:@"loginVideo.mp4" ofType:nil];
//    
//    NSURL *url = [NSURL fileURLWithPath:urlStr];
//    
//    _moviePlayer = [[MPMoviePlayerController alloc]initWithContentURL:url];
//    //    _moviePlayer.controlStyle = MPMovieControlStyleDefault;
//    
//    
//    [self.view addSubview:_moviePlayer.view];
//    
//    UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_W/2-63, SCREEN_H/4, 125, 85)];
//    imgV.contentMode = UIViewContentModeScaleAspectFit;
//    
//    imgV.image = [UIImage imageNamed:@"app名字+slogan"];
//    [self.view addSubview:imgV];
//    
//    [_moviePlayer.view mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.right.top.bottom.equalTo(self.view).offset(0);
//    }];
//    
//    _moviePlayer.shouldAutoplay = NO;
//    [_moviePlayer setControlStyle:MPMovieControlStyleNone];
//    [_moviePlayer setFullscreen:YES];
//    
//    [_moviePlayer setRepeatMode:MPMovieRepeatModeOne];
//    
////    [[NSNotificationCenter defaultCenter] addObserver:self
////                                             selector:@selector(playbackStateChanged)
////                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
////                                               object:_moviePlayer];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_moviePlayer];
//    //绘制登录的按钮界面
//    [self custonLoginView];
//    
//    
//}
//-(void)checkWelcome
//{
//    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
//    if ([usf objectForKey:KFirstUse]) {
//        //        [self.moviePlayer pause];
//        [_moviePlayer play];
//    }else{
//        [_moviePlayer pause];
//    }
//    [usf setObject:@YES forKey:KFirstUse];
//    [usf synchronize];
//}
//-(void)dealloc
//{
//    _moviePlayer = nil;
//    [[NSNotificationCenter defaultCenter]removeObserver:self];
//}
//-(void)moviePlayDidEnd:(NSNotification *)noti
//{
//    if ([_moviePlayer playbackState]==MPMoviePlaybackStateStopped) {
//        [_moviePlayer play];
//    }
//}

-(void)custonLoginView
{
    int i = 0;
    UIView *btnSView = [UIView new];
    btnSView.frame = CGRectMake(0, SCREEN_H-130, SCREEN_W, 60);
    [self.view addSubview:btnSView];
    
    //微信
    if ([WXApi isWXAppInstalled]) {
        UIButton *btnWX = [UIButton buttonWithType:UIButtonTypeCustom];
        btnWX.titleLabel.textColor = [UIColor redColor];
        [btnWX setImage:[UIImage loadImageNamed:@"微信"] forState:UIControlStateNormal];
        btnWX.imageView.contentMode = UIViewContentModeScaleAspectFit;
        btnWX.frame = CGRectMake(i*(SCREEN_W-60)/4, 0, (SCREEN_W-60)/4, 60);
        [btnWX addTarget:self action:@selector(onshareToWX) forControlEvents:UIControlEventTouchUpInside];
        [btnSView addSubview:btnWX];
        i++;
    }
    //微博
    UIButton *btnWB = [UIButton buttonWithType:UIButtonTypeCustom];
    btnWB.titleLabel.textColor = [UIColor redColor];
    
    btnWB.frame = CGRectMake(i*(SCREEN_W-60)/4, 0, (SCREEN_W-60)/4, 60);
    [btnWB setImage:[UIImage loadImageNamed:@"微博"] forState:UIControlStateNormal];
    btnWB.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [btnWB addTarget:self action:@selector(onshareToWeibo:) forControlEvents:UIControlEventTouchUpInside];
    [btnSView addSubview:btnWB];
    i++;
    if ([QQApiInterface isQQInstalled]) {
        UIButton *btnQQ = [UIButton buttonWithType:UIButtonTypeCustom];
        btnQQ.titleLabel.textColor = [UIColor redColor];
        [btnQQ setImage:[UIImage loadImageNamed:@"QQ" ] forState:UIControlStateNormal];
        btnQQ.imageView.contentMode = UIViewContentModeScaleAspectFit;
        btnQQ.frame = CGRectMake(i*((SCREEN_W-60))/4, 0, (SCREEN_W-60)/4, 60);
        [btnQQ addTarget:self action:@selector(onshareToQQ) forControlEvents:UIControlEventTouchUpInside];
        [btnSView addSubview:btnQQ];
        i++;
    }
    
    UIButton *btnDX = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDX.titleLabel.textColor = [UIColor redColor];
    [btnDX setImage:[UIImage loadImageNamed:@"手机号"] forState:UIControlStateNormal];
    btnDX.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    btnDX.frame = CGRectMake(i*((SCREEN_W-60))/4,0, (SCREEN_W-60)/4, 60);
    [btnDX addTarget:self action:@selector(onshareToSMS) forControlEvents:UIControlEventTouchUpInside];
    [btnSView addSubview:btnDX];
    i++;
    CGRect rect = btnSView.frame;
    CGPoint center = btnSView.center;
    if (i==2) {
        rect.size.width = ((SCREEN_W-60))/4*2;
    }else if (i==3){
        rect.size.width = ((SCREEN_W-60))/4*3;
    }else if (i==4){
        rect.size.width = ((SCREEN_W-60))/4*4;
    }
    
    btnSView.frame = rect;
    btnSView.center = center;
    //协议
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"注册/登录即同意左右服务协议和隐私条款"];
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(10, [str length]-10)];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexColorString:@"888888"] range:NSMakeRange(0,[str length])];
    UIButton *xieyiBtn = [UIButton new];
    [xieyiBtn setAttributedTitle:str forState:UIControlStateNormal];
    xieyiBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    xieyiBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [xieyiBtn addTarget:self action:@selector(onXieyiTiaokuanClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:xieyiBtn];
    [xieyiBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX).with.offset(0);
        make.width.equalTo(self.view.mas_width).with.offset(10);
        make.height.mas_equalTo(25);
        make.bottom.equalTo(self.view.mas_bottom).offset(-25);
    }];
    
    //上部显示的东西
    UIImageView *logoImageView = [[UIImageView alloc]initWithImage:[UIImage loadImageNamed:@"app名字+slogan"]];
    logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:logoImageView];
    [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(105);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(85);
    }];
    //中部图片
    UIImageView *contentImageView = [[UIImageView alloc]initWithImage:[UIImage loadImageNamed:@"app豆儿"]];
    contentImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:contentImageView];
    [contentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-180);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(160);
    }];
    
}
-(void)onBackClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)onXieyiTiaokuanClick:(UIButton *)sender
{
    DengluXieyiViewController *xyVC = [[DengluXieyiViewController alloc]initWithNibName:@"DengluXieyiViewController" bundle:nil];
    [self.navigationController pushViewController:xyVC animated:YES];
}

- (void)onshareToWeibo:(UIButton *)sender {
    XloginAndShareManager *manager = [XloginAndShareManager defaultManager];
    [manager loginWithWB:^(NSDictionary *userInfo) {
        DbLog(@"%@",userInfo);
        [self loginWhit:@"WEIBO" UserInfo:userInfo];
    }];
    
}
-(void)onshareToWX
{
    XloginAndShareManager *manager = [XloginAndShareManager defaultManager];
    [manager loginWithWX:^(NSDictionary *userInfo) {
        DbLog(@"%@",userInfo);
        [self loginWhit:@"WEIXIN" UserInfo:userInfo];
    }];
}
-(void)onshareToSMS
{
    DbLog(@"短信！");
    [self performSegueWithIdentifier:@"pushToLogin" sender:self];
}
-(void)onshareToQQ
{
    XloginAndShareManager *manager = [XloginAndShareManager defaultManager];
    [manager loginWithQQ:^(NSDictionary *userInfo) {
        DbLog(@"%@",userInfo);
        [self loginWhit:@"QQ" UserInfo:userInfo];
    }];
}
-(void)loginWhit:(NSString *)thirtParty UserInfo:(NSDictionary *)userInfo
{
    CoreSVPLoading(@"正在登录", NO);
    NSString *ts = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]*1000];
    NSString *vc = [NSString stringWithFormat:@"avatar=%@&nickname=%@&openId=%@&thirdparty=%@&ts=%@%@",userInfo[@"userImg"],userInfo[@"userName"],userInfo[@"openID"],thirtParty,ts,SECUREKEY];
//    openID md5(avatar=9303vx&nickname=&openId=489f4b90cc&thirdparty=qqXXX#160517)
   [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@%@",HeadUrl,@"/users/checkin"] parameters:@{@"thirdparty":thirtParty,@"nickname":userInfo[@"userName"],@"avatar":userInfo[@"userImg"],@"ts":ts,@"vc":vc.md5,@"openId":userInfo[@"openID"]} inView:nil sucess:^(id result) {
       [CoreSVP dismiss];
       if (result) {
           NSNumber *errCode = [result objectForKey:@"errCode"];
           if (errCode) {
               if (errCode.integerValue == 4007) {
                   [XYWAlert XYWAlertTitle:[result objectForKey:@"errMsg"] message:nil first:nil firstHandle:nil second:nil Secondhandle:nil cancle:@"知道了" handle:nil];
                   return ;
               }
               CoreSVPCenterMsg([result objectForKey:@"errMsg"]);
               return ;
           }
           NSDictionary *userInfo = (NSDictionary*)result;
           [self refreshConnect:userInfo];
           [self changeRootView];
       }
   } failure:^(NSError *error) {
       [CoreSVP dismiss];
       CoreSVPCenterMsg(error.localizedDescription);
   }];
}
-(void)refreshConnect:(NSDictionary *)userInfo
{
    [UserInfoManager saveMyselfInfo:userInfo];
    [XYWhttpManager refreshRequestToken];
    [[SocketManager defaultManager] createWS];
    
}
-(void)dismiss
{
    for (UIView *v in self.view.subviews) {
        [v removeFromSuperview];
    }
//    _moviePlayer = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self.view removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)changeRootView
{
    [CoreSVP dismiss];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    RootViewController *lgvc = [RootViewController new];
//    RootViewController *lgvc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
    
    // 修改rootViewController
    [delegate.window addSubview:lgvc.view];
//    //停掉视频
//    [self.moviePlayer pause];
//    self.moviePlayer = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    for (UIView *view in self.view.subviews) {
        [view removeFromSuperview];
    }
    [self.view removeFromSuperview];
    
    delegate.window.rootViewController =  lgvc;
    //移除膜拜数据
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"mobaidate"];
#pragma mark --检查受否有待处理的跳转信息
    //检查受否有待处理的跳转信息
     id __weak weakSelf = self;
    dispatch_queue_t concurrentQueue = dispatch_queue_create("zuoyou.data.concurrent", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(concurrentQueue, ^{
        //异步线程处理数据
        [weakSelf talkingDataSetAccount];
        NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
        NSDictionary *dic = [usf objectForKey:@"SCHEMES"];
        if (dic&&dic[@"id"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //主线程更新界面
                DbLog(@"将通知再次传递");
                [[NSNotificationCenter defaultCenter]postNotificationName:@"SCHEMES" object:dic];
            });
        }
    });
    
}
-(void)talkingDataSetAccount
{
    dispatch_queue_t concurrentQueue = dispatch_queue_create("zuoyou.data.concurrent", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(concurrentQueue, ^{
        //异步线程处理数据
        MyselfInfoModel *my = [UserInfoManager mySelfInfoModel];
        
        TDGAAccount *acount =[TDGAAccount setAccount:[NSString stringWithFormat:@"%@",my.mid] ];
        [acount setAccountType:kAccountRegistered];
        
        [acount setAccountName:my.name];
        [acount setGameServer:@"iOS客户端"];
        [XGPush setAccount:[NSString stringWithFormat:@"%@",my.mid] successCallback:^{
            NSLog(@"[XGDemo] Set account success");
        } errorCallback:^{
            NSLog(@"[XGDemo] Set account error");
        }];
    });
}
-(void)dealloc
{
    DbLog(@"登录界面被销毁");
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
