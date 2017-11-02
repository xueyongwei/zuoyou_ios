//
//  VideoDetailViewController.m
//  ZuoYou
//
//  Created by xueyognwei on 17/1/20.
//  Copyright © 2017年 xueyongwei. All rights reserved.
//

#import "VideoDetailViewController.h"
#import <Google/Analytics.h>
#import "XloginAndShareManager.h"
#import "MarqueeLabel.h"
#import "ZYPlayer.h"
#import "CaptureViewController.h"
#import "UHCenterViewController.h"
@interface VideoDetailViewController ()<UIActionSheetDelegate>
@property (nonatomic,strong)MarqueeLabel *naviTitleLabel;

@property (weak, nonatomic) IBOutlet ZYPlayerView *player;
@property (weak, nonatomic) IBOutlet UIImageView *userIcon;
@property (weak, nonatomic) IBOutlet UIImageView *iconCorver;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;

@property (nonatomic,strong)UIButton *shareBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ContentrightConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ContentbottomConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ContenttopConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ContentleftConst;

@property (nonatomic,assign) BOOL shoulePlayWhenAppear;

@end

@implementation VideoDetailViewController
{
    UIButton *quxiaofenxiangBtn;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self adjustView];
    [self customView];
    UITapGestureRecognizer *tapUser = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapUser:)];
    [self.userIcon addGestureRecognizer:tapUser];
}
-(void)tapUser:(UITapGestureRecognizer *)recognizer{
    UHCenterViewController *uhVC = [[UHCenterViewController alloc]init];
    uhVC.mid = self.dataModel.mid;
    [self.navigationController pushViewController:uhVC animated:YES];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self pauseByTemporary];
//    [self onQuxiaoShareClick:self.shareBtn];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self stopPauseByTemporary];
}
-(void)customView{
    [UserInfoManager setNameLabel:self.userNameLabel headImageV:self.userIcon corverImageV:self.iconCorver with:@(self.dataModel.mid)];
    self.descLabel.text = self.dataModel.videoDescription.length>0?self.dataModel.videoDescription:@"up主什么也没说～";
    self.naviTitleLabel.text = self.dataModel.formatertagName;
    self.player.placeholderImageUrl = self.dataModel.frontCover;
    [self.player setVideoURL:[NSURL URLWithString:self.dataModel.m3u8]];
    BOOL isWIFI = [[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi];
    if (isWIFI) {//wifi环境
        NSNumber *autoPlay = [[NSUserDefaults standardUserDefaults] objectForKey:PLAYERAUTOPLAY];
        if (!autoPlay || autoPlay.integerValue == 1) {//且没设置wifi不播放，或者设置了Wi-Fi播放
            [self.player autoPlayTheVideo];
        }
    }
    
}
- (IBAction)onChangeClick:(UIButton *)sender {
    if ([UserInfoManager isMeOfID:self.dataModel.mid]) {
        CoreSVPCenterMsg(@"试试挑战别人吧~");
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@%@",HeadUrl,@"/versus/challenge"];
    NSMutableDictionary *param = [NSMutableDictionary new];
    [param setObject:@0 forKey:@"tagID"];
    [param setObject:@0 forKey:@"contestantVideoId"];
    [param setObject:@0 forKey:@"videoId"];
    [param setObject:@"" forKey:@"description"];
    __block typeof(self) wkSelf = self;
    [XYWhttpManager XYWpost:url parameters:param inView:nil sucess:^(id result) {
        NSNumber *errCode = [result objectForKey:@"errCode"];
        if (errCode && errCode.integerValue == 3004) {
            CoreSVPCenterMsg([result objectForKey:@"errMsg"]);
            return ;
        }
        [wkSelf selecteFromPhotos];
    } failure:^(NSError *error) {
        CoreSVPCenterMsg(error.localizedDescription);
    }];

}
-(void)selecteFromPhotos
{
    CaptureViewController *captureViewCon = [[CaptureViewController alloc] initWithNibName:@"CaptureViewController" bundle:nil];
    captureViewCon.contestantVideoId = @(self.dataModel.VideoId);
    captureViewCon.tagId = @(self.dataModel.tagId);
    captureViewCon.challenge = @"true";
    captureViewCon.tagName = self.dataModel.formatertagName;
    CaptureVideoNavigationController *navCon = [[CaptureVideoNavigationController alloc] initWithRootViewController:captureViewCon];
    navCon.showStatusWhenDealloc = YES;
    [self presentViewController:navCon animated:YES completion:nil];
}

-(void)adjustView{
    self.ContenttopConst.constant = SINGLE_LINE_WIDTH;
    self.ContentbottomConst.constant = SINGLE_LINE_WIDTH;
    self.ContentleftConst.constant = SINGLE_LINE_WIDTH;
    self.ContentrightConst.constant = SINGLE_LINE_WIDTH;
}
-(void)customNavi
{
    [super customNavi];
    UIButton *rightBtn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn1.frame = CGRectMake(0, 0, 30, 38);
    rightBtn1.contentMode = UIViewContentModeScaleAspectFit;
    [rightBtn1 setImage:[UIImage imageNamed:@"分享"] forState:UIControlStateNormal];
    [rightBtn1 addTarget:self action:@selector(onShareClick:) forControlEvents:UIControlEventTouchDown];
    self.shareBtn = rightBtn1;
    
    UIButton *rightBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn2.frame = CGRectMake(0, 0, 30, 38);
    rightBtn2.contentMode = UIViewContentModeScaleAspectFit;
    [rightBtn2 setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    [rightBtn2 addTarget:self action:@selector(onMoreClick:) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -13;
    
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,[[UIBarButtonItem alloc]initWithCustomView:rightBtn2],[[UIBarButtonItem alloc]initWithCustomView:rightBtn1]];
    
    MarqueeLabel *label = [[MarqueeLabel alloc]initWithFrame:CGRectMake(20, 100, 200, 30)];
    label.marqueeType = MLLeftRight;
    label.rate = 60.0f;
    label.fadeLength = 10.0f;
    label.leadingBuffer = 0.0f;
    label.trailingBuffer = 0.0f;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = self.dataModel.formatertagName;
    self.naviTitleLabel = label;
    self.navigationItem.titleView = label;
}

/**
 临时暂停（分享，侧滑时）
 */
-(void)pauseByTemporary{
    if (!self.player.isPauseByUser) {
        [self.player pause];
        self.shoulePlayWhenAppear = YES;
    }
}

/**
 结束临时暂停
 */
-(void)stopPauseByTemporary{
    if (self.shoulePlayWhenAppear) {
        [self.player play];
        self.shoulePlayWhenAppear = NO;
    }
}
#pragma mark ---手势点击等事件的handle
-(void)onShareClick:(UIButton *)sender
{
    [self pauseByTemporary];
    UIView *bgView = [UIView new];
    bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapShareEmpty:)];
    bgView.userInteractionEnabled = YES;
    [bgView addGestureRecognizer:tap];
    [[UIApplication sharedApplication].windows.lastObject addSubview:bgView];
//    [self.navigationController.view addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.left.equalTo(bgView.superview);
    }];
    
    UIView *shareBordView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_H, SCREEN_W, 270)];
    shareBordView.backgroundColor = [UIColor whiteColor];

    [bgView addSubview:shareBordView];
    
    UILabel *fenxiangzhiLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 120, 14)];
    fenxiangzhiLabel.font = [UIFont systemFontOfSize:14];
    fenxiangzhiLabel.textColor = [UIColor colorWithHexColorString:@"333333"];
    fenxiangzhiLabel.center = CGPointMake(SCREEN_W/2, 22);
    fenxiangzhiLabel.text = @"分享至";
    fenxiangzhiLabel.textAlignment = NSTextAlignmentCenter;
    [shareBordView addSubview:fenxiangzhiLabel];
    int i= 0;int j = 0;
    if ([WXApi isWXAppInstalled]) {
        UIButton *btnpyq = [UIButton buttonWithType:UIButtonTypeCustom];
        btnpyq.imageView.contentMode = UIViewContentModeScaleAspectFit;
        btnpyq.frame = CGRectMake(i*SCREEN_W/4, 42+j*80, SCREEN_W/4, 71);
        btnpyq.tag = 101;
        [btnpyq addTarget:self action:@selector(shareToWx:) forControlEvents:UIControlEventTouchDown];
        [btnpyq setImage:[UIImage imageNamed:@"分享朋友圈"] forState:UIControlStateNormal];
        [shareBordView addSubview:btnpyq];
        i++;
        
        UIButton *btnwx = [UIButton buttonWithType:UIButtonTypeCustom];
        btnwx.imageView.contentMode = UIViewContentModeScaleAspectFit;
        btnwx.frame = CGRectMake(i*SCREEN_W/4, 42+j*80, SCREEN_W/4, 71);
        [btnwx setImage:[UIImage imageNamed:@"分享微信"] forState:UIControlStateNormal];
        btnwx.tag = 100;
        [btnwx addTarget:self action:@selector(shareToWx:) forControlEvents:UIControlEventTouchDown];
        [shareBordView addSubview:btnwx];
        i++;
    }
    if ([WeiboSDK isCanShareInWeiboAPP]) {
        UIButton *btnwb = [UIButton buttonWithType:UIButtonTypeCustom];
        btnwb.imageView.contentMode = UIViewContentModeScaleAspectFit;
        btnwb.frame = CGRectMake(i*SCREEN_W/4, 42+j*80, SCREEN_W/4, 71);
        [btnwb setImage:[UIImage imageNamed:@"分享微博"] forState:UIControlStateNormal];
        [btnwb addTarget:self action:@selector(shareToWeibo) forControlEvents:UIControlEventTouchDown];
        [shareBordView addSubview:btnwb];
        i++;
    }
    
    if ([QQApiInterface isQQInstalled]) {
        UIButton *btnqq = [UIButton buttonWithType:UIButtonTypeCustom];
        btnqq.imageView.contentMode = UIViewContentModeScaleAspectFit;
        btnqq.frame = CGRectMake(i*SCREEN_W/4, 42+j*80, SCREEN_W/4, 71);
        [btnqq setImage:[UIImage imageNamed:@"分享QQ"] forState:UIControlStateNormal];
        btnqq.tag = 200;
        [btnqq addTarget:self action:@selector(shareToQQ:) forControlEvents:UIControlEventTouchDown];
        [shareBordView addSubview:btnqq];
        i++;
        if (i==4) {
            j=1;
            i=0;
        }
        UIButton *btnkj = [UIButton buttonWithType:UIButtonTypeCustom];
        btnkj.imageView.contentMode = UIViewContentModeScaleAspectFit;
        btnkj.frame = CGRectMake(i*SCREEN_W/4, 42+j*80, SCREEN_W/4, 71);
        [btnkj setImage:[UIImage imageNamed:@"分享QQ空间"] forState:UIControlStateNormal];
        btnkj.tag = 201;
        [btnkj addTarget:self action:@selector(shareToQQ:) forControlEvents:UIControlEventTouchDown];
        [shareBordView addSubview:btnkj];
        i++;
    }
    if (i==4) {
        j=1;
        i=0;
    }
    UIButton *btnfz = [UIButton buttonWithType:UIButtonTypeCustom];
    btnfz.imageView.contentMode = UIViewContentModeScaleAspectFit;
    btnfz.frame = CGRectMake(i*SCREEN_W/4, 42+j*80, SCREEN_W/4, 71);
    [btnfz setImage:[UIImage imageNamed:@"分享复制链接"] forState:UIControlStateNormal];
    [btnfz addTarget:self action:@selector(shareToCopyBoard) forControlEvents:UIControlEventTouchDown];
    [shareBordView addSubview:btnfz];
    i++;
    if (i==4) {
        j=1;
        i=0;
    }
    UIButton *btngd = [UIButton buttonWithType:UIButtonTypeCustom];
    btngd.imageView.contentMode = UIViewContentModeScaleAspectFit;
    btngd.frame = CGRectMake(i*SCREEN_W/4, 42+j*80, SCREEN_W/4, 71);
    [btngd setImage:[UIImage imageNamed:@"分享更多"] forState:UIControlStateNormal];
    [btngd addTarget:self action:@selector(shareToMore) forControlEvents:UIControlEventTouchDown];
    [shareBordView addSubview:btngd];
    
    CGRect rec = shareBordView.frame;
    if (j<1) {
        rec.size.height-=70;
        shareBordView.frame = rec;
    }
    rec.origin.y = SCREEN_H - rec.size.height;
    UIButton *btnqx = [UIButton buttonWithType:UIButtonTypeCustom];
    btnqx.frame = CGRectMake(13, shareBordView.frame.size.height-55, SCREEN_W-25, 40);
    btnqx.layer.cornerRadius = 5;
    btnqx.backgroundColor = [UIColor colorWithHexColorString:@"f0f0f0"];
    [btnqx setTitle:@"取消" forState:UIControlStateNormal];
    [btnqx setTitleColor:[UIColor colorWithHexColorString:@"999999"] forState:UIControlStateNormal];
    [btnqx addTarget:self action:@selector(onQuxiaoShareClick:) forControlEvents:UIControlEventTouchDown];
    quxiaofenxiangBtn = btnqx;
    [shareBordView addSubview:btnqx];
    [UIView animateWithDuration:0.3 animations:^{
        shareBordView.frame = rec;
    }];
}
-(void)onQuxiaoShareClick:(UIButton *)sender
{
    UIView *shareBord = quxiaofenxiangBtn.superview;
    CGRect rec = shareBord.frame;
    rec.origin.y = SCREEN_H;
    [UIView animateWithDuration:0.2 animations:^{
        shareBord.frame = rec;
    } completion:^(BOOL finished) {
        [quxiaofenxiangBtn.superview.superview removeFromSuperview];
        [self stopPauseByTemporary];
    }];
    
    //    [sender.superview removeFromSuperview];
}
-(void)onMoreClick:(UIButton *)sender
{
    [self pauseByTemporary];
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"举报" otherButtonTitles: nil];
    [sheet showInView:self.view];
    
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self stopPauseByTemporary];
    if (buttonIndex == 0) {
        CoreSVPSuccess(@"举报成功");
        //        CoreSVPBottomMsg(@"举报成功");
    }
}
#pragma mark ---👪分享到三方平台
-(void)shareToWx:(UIButton*)sender
{
    [self onQuxiaoShareClick:nil];
    XloginAndShareManager *manager = [XloginAndShareManager defaultManager];
    manager.shareData = [self shareData];
    NSDictionary *parm;
    if (sender.tag==100) {
        parm = @{@"to":@"wx"};
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"PK详情页"
                                                              action:@"点击分享至"
                                                               label:@"微信"
                                                               value:@1] build]];
    }else{
        parm = @{@"to":@"pyq"};
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"PK详情页"
                                                              action:@"点击分享至"
                                                               label:@"朋友圈"
                                                               value:@1] build]];
    }
    __weak typeof(self) wkSelf = self;
    __weak typeof(sender) wkSender = sender;
    [manager shareToWx:parm result:^(NSDictionary *userInfo) {
        if ([userInfo[@"shareState"] isEqualToString:@"sucess"]) {
            [wkSelf shareOnce];
            CoreSVPSuccess(@"分享成功");
            if (wkSender.tag == 100) {
                [TalkingDataGA onEvent:KFENXIANGDAO eventData:@{@"分享_微信":@(1)}];
            }else{
                [TalkingDataGA onEvent:KFENXIANGDAO eventData:@{@"分享_朋友圈":@(1)}];
            }
        }
    }];
}

-(void)shareToWeibo
{
    [self onQuxiaoShareClick:nil];
    XloginAndShareManager *manager = [XloginAndShareManager defaultManager];
    manager.shareData = [self shareData];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"PK详情页"
                                                          action:@"点击分享至"
                                                           label:@"微博"
                                                           value:@1] build]];
    __weak typeof(self) wkSelf = self;
    [manager shareToWb:nil result:^(NSDictionary *userInfo) {
        if ([userInfo[@"shareState"] isEqualToString:@"sucess"]) {
            CoreSVPSuccess(@"分享成功");
            [wkSelf shareOnce];
            [TalkingDataGA onEvent:KFENXIANGDAO eventData:@{@"分享_微博":@(1)}];
            
        }
    }];
}
-(void)shareToQQ:(UIButton *)sender
{
    [self onQuxiaoShareClick:nil];
    XloginAndShareManager *manager = [XloginAndShareManager defaultManager];
    manager.shareData = [self shareData];
    NSDictionary *parm;
    if (sender.tag==200) {
        parm = @{@"to":@"qq"};
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"PK详情页"
                                                              action:@"点击分享至"
                                                               label:@"QQ"
                                                               value:@1] build]];
    }else{
        parm = @{@"to":@"qqzone"};
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"PK详情页"
                                                              action:@"点击分享至"
                                                               label:@"QQ空间"
                                                               value:@1] build]];
    }
    __weak typeof(self) wkSelf = self;
    [manager shareToQQ:parm result:^(NSDictionary *userInfo) {
        if ([userInfo[@"shareState"] isEqualToString:@"sucess"]) {
            CoreSVPSuccess(@"分享成功");
            [wkSelf shareOnce];
            if (sender.tag == 200) {
                [TalkingDataGA onEvent:KFENXIANGDAO eventData:@{@"分享_QQ":@(1)}];
            }else{
                [TalkingDataGA onEvent:KFENXIANGDAO eventData:@{@"分享_QQ空间":@(1)}];
            }
        }
    }];
}
-(void)shareToCopyBoard
{
    [self onQuxiaoShareClick:nil];
    NSDictionary *shareData = [self shareData];
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = shareData[@"shareUrl"];
    [TalkingDataGA onEvent:KFENXIANGDAO eventData:@{@"分享_复制链接":@(1)}];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"PK详情页"
                                                          action:@"点击分享至"
                                                           label:@"复制"
                                                           value:@1] build]];
    CoreSVPCenterMsg(@"已复制到剪切板");
    [self shareOnce];
}
-(void)shareToMore
{
    [self onQuxiaoShareClick:nil];
    [[NSNotificationCenter defaultCenter ]removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    CoreSVPLoading(@"wait...", NO);
    NSDictionary *dic = [self shareData];
    [TalkingDataGA onEvent:KFENXIANGDAO eventData:@{@"分享_更多":@(1)}];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"PK详情页"
                                                          action:@"点击分享至"
                                                           label:@"更多"
                                                           value:@1] build]];
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:@[dic]
                                      applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[UIActivityTypeMessage,UIActivityTypeMail];
    [self presentViewController:activityViewController
                       animated:YES
                     completion:^{
                         [CoreSVP dismiss];
                         
                     }];
    [self shareOnce];
}
-(NSDictionary *)shareData
{
    NSString *shareTitle;
    UIImage *shareImg;
    NSString *shareImgUrl;
    NSString *shareUrl;
    
    NSString *shareDesc = @"够胆你就来挑战";
    shareImgUrl = self.dataModel.frontCover;
    shareImg = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:self.dataModel.frontCover];
    shareTitle = self.dataModel.formatertagName;
    
    shareUrl = [NSString stringWithFormat:@"http://api.zuoyoupk.com/v1/share/video?id=%@",@(self.dataModel.VideoId)];
    return @{@"shareDesc":shareDesc,@"shareTitle":shareTitle,@"shareImg":shareImg,@"shareImgUrl":shareImgUrl,@"shareUrl":shareUrl};
}



-(void)onTapShareEmpty:(UITapGestureRecognizer *)recogizer
{
    [self onQuxiaoShareClick:self.shareBtn];
//    [recogizer.view removeFromSuperview];
    //    [self.PlayerView goOnPlay];
}


#pragma mark ---API相关的东西
-(void)shareOnce
{
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@%@",HeadUrl,@"/share/finish"] parameters:nil inView:nil sucess:^(id result) {
        DbLog(@"%@",result);
    } failure:^(NSError *error) {
        
    }];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self.player resetPlayer];
    self.player = nil;
    DbLog(@"dealloc");
}
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
