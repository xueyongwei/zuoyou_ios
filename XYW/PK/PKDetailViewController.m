//
//  PKDetailViewController.m
//  HDJ
//
//  Created by xueyongwei on 16/5/16.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "PKDetailViewController.h"
#import "MarqueeLabel.h"
#import "XYWAlert.h"
#import "PinglunTableViewCell.h"

#import "SocketManager.h"
#import "PinglunModel.h"
#import "PkProgressView.h"
#import "XloginAndShareManager.h"
#import "ChongZhiViewController.h"
#import "NoPinglunTableViewCell.h"

#import "PkDetailVIdeoTableViewCell.h"
#import "PkdetailUserTableViewCell.h"
#import "PkdetailDescTableViewCell.h"

#import "UHCenterViewController.h"
#import "HtmlViewController.h"

#import "ResetCoolAlert.h"
#import "LuckyAlert.h"

@interface PKDetailViewController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *pinglunView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pinglunALBotton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pinglunH;

@property (nonatomic,strong)NSMutableArray *pinglunDataSource;

@property (nonatomic,assign)NSInteger repayToId;
@property (nonatomic,copy)NSString *repayToColor;
@property (nonatomic,strong)MarqueeLabel *naviTitleLabel;
@property (nonatomic,strong)UIButton *shareBtn;

@property (nonatomic,weak)contestantVideosModel *currentVideo;
@property (nonatomic,weak)contestantVideosModel *anotherVideo;
@property (nonatomic,assign)BOOL leftPlaying;
@property (nonatomic,strong)NSNumber *praiseRestCost;
@property (nonatomic,weak)PkdetailUserTableViewCell *UserTableViewCellPointer;
@property (nonatomic,weak)ResetCoolAlert *coolAlvPointer;
@property (nonatomic,weak)ZYPlayerView *zyPlayer;
@property (nonatomic,assign)NSInteger pinglunCurrentPage;
@property (nonatomic,strong)UIButton *suolueBtn;
@property (nonatomic,assign) BOOL shoulePlayWhenAppear;
@property (nonatomic,assign) BOOL haveShared;
//分享需要的参数
@property (nonatomic,copy)NSString *descStr;
@end

@implementation PKDetailViewController
{
    BOOL ScrollPlay;
    UIButton *quxiaofenxiangBtn;
    UIButton *guideGiftBtn;
}
#pragma  mark ---懒加载

-(NSMutableArray *)pinglunDataSource{
    if (!_pinglunDataSource) {
        _pinglunDataSource = [NSMutableArray new];
    }
    return _pinglunDataSource;
}
#pragma mark ---set方法
-(void)setContestantType:(NSString *)contestantType
{
    _contestantType = contestantType;
    self.clickRightVideo = [contestantType isEqualToString:@"BLUE"]?YES:NO;
}
-(void)setClickRightVideo:(BOOL)clickRightVideo
{
    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
    if (![usf objectForKey: KGuider]) {//还没有引导，就开始引导
        _clickRightVideo = NO;
    }else{
        _clickRightVideo = clickRightVideo;
    }
}

/**
 设置是否正在播放左边视频（同时设置当前播放的视频和另一个视频）

 @param leftPlaying YES：播放的左边
 */
-(void)setLeftPlaying:(BOOL)leftPlaying
{
    _leftPlaying = leftPlaying;
    if (self.pkModel) {
        contestantVideosModel *leftVideo = self.pkModel.contestantVideos.firstObject;
        contestantVideosModel *rightVideo = self.pkModel.contestantVideos.lastObject;
        if (leftPlaying) {
            self.currentVideo = leftVideo;
            self.anotherVideo = rightVideo;
        }else{
            self.currentVideo = rightVideo;
            self.anotherVideo = leftVideo;
        }
    }
}
-(void)setYYlabel:(YYLabel *)label with:(NSInteger)number color:(UIColor *)aCloor
{
    NSMutableAttributedString *text = [NSMutableAttributedString new];
    
    NSString *nubStr;
    if (number ==0) {
        nubStr = @" 免费";
    }else{
        UIImage *img = [UIImage imageNamed:@"礼物价值金豆"];
        NSMutableAttributedString *imgText = [NSMutableAttributedString yy_attachmentStringWithContent:img contentMode:UIViewContentModeCenter attachmentSize:img.size alignToFont:[UIFont systemFontOfSize:11] alignment:YYTextVerticalAlignmentCenter];
        [text appendAttributedString:imgText];
        nubStr = [NSString stringWithFormat:@" %ld",(long)number];
    }
    [text appendAttributedString:[[NSAttributedString alloc] initWithString:nubStr attributes:@{NSForegroundColorAttributeName:aCloor}]];
    text.yy_alignment = NSTextAlignmentCenter;
    label.attributedText = text;
}
#pragma mark ---控制器方法
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self checkDeny];
    [self NotiAddObserver];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"赛事详情页面"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    if (self.shoulePlayWhenAppear) {
        [self.zyPlayer play];
        self.shoulePlayWhenAppear = NO;
    }
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (!self.zyPlayer.isPauseByUser) {
        [self.zyPlayer pause];
        self.shoulePlayWhenAppear = YES;
    }
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self removeNotiObser];
}
-(void)setPkModel:(PKModel *)pkModel
{
    _pkModel = pkModel;
    _pkId = pkModel.pkID;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.shoulePlayWhenAppear = NO;
    self.bottonPinglunFengexianH.constant = SINGLE_LINE_WIDTH;
    self.pinglunCurrentPage = 1;
    
    [self customTableView];
    
    
    [self prepareDataWithFirst:YES];
    [self preparePraiseRule];
    
    [self prepareWSpinglun:self.pinglunCurrentPage];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapEmptyWhileInput:)];
    [self.pinglunView addGestureRecognizer:tap];
    
    if (self.pkModel) {//如果是列表来的（已知model），设置当前使用的video
        //设置播放哪个视频（同时设置了当前视频和另外视频）
        self.leftPlaying = !self.clickRightVideo;
    }
}
-(void)checkDeny
{
    __weak typeof(self) wkSelf = self;
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@%@",HeadUrl,@"/users/info"] parameters:@{} inView:nil sucess:^(id result) {
        if (result && [result isKindOfClass:[NSDictionary class]]) {
            if ([result objectForKey:@"permissionDeny"]) {
                NSArray *arr = [result objectForKey:@"permissionDeny"];
                for (NSDictionary *den in arr) {
                    DbLog(@"%@",den);
                    NSString *denPattern = [den objectForKey:@"pattern"];
                    if (denPattern) {//有禁止项
                        if ([denPattern isEqualToString:@"/comment/post"]) {//禁止评论
                            wkSelf.PinglunTF.placeholder = @"禁言中";
                            wkSelf.PinglunTF.userInteractionEnabled = NO;
                        }
                    }
                }
            }
        }
    } failure:^(NSError *error) {
        
    }];
}
-(void)prepareMyInfo
{
    __weak typeof(self) wkSelf = self;
    [UserInfoManager refreshMyselfInfoFinished:^{
        [wkSelf.tableView reloadData];
    }];
}

#pragma mark --- 评论输入框Delegate
-(void)textFieldDidChange:(UITextField *)textField
{
    if (textField == self.PinglunTF) {
        if (textField.text.length > 1000) {
            textField.text = [textField.text substringToIndex:1000];
        }
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length<1) {
        CoreSVPCenterMsg(@"请输入评论内容");
        return NO;
    }else if (textField.text.length<2){
        CoreSVPCenterMsg(@"内容过少");
        return NO;
    }else if (textField.text.length>1000){
        CoreSVPCenterMsg(@"最多输入1000字哦～");
        return NO;
    }
    NSMutableDictionary *param = [NSMutableDictionary new];
    [param setObject:[self only1Space:textField.text] forKey:@"content"];
    [param setObject:[NSString stringWithFormat:@"%ld",(long)self.pkModel.pkID] forKey:@"versusId"];
    
    if (self.repayToId) {
        [param setObject:[NSString stringWithFormat:@"%ld",(long)self.repayToId] forKey:@"referredId"];
    }
    if (self.repayToColor.length>0) {
        [param setObject:self.repayToColor forKey:@"referredContestant"];
    }
    [textField resignFirstResponder];
    __weak typeof(self) wkSelf = self;
    __weak typeof(textField) wkTF = textField;
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@%@",HeadUrl,@"/comment/post"] parameters:param inView:nil sucess:^(id result) {
        if (result && ![result objectForKey:@"errCode"]) {
            DbLog(@"%@",result);
            wkTF.text = @"";
            wkTF.placeholder = @"说点什么吧…";
            wkSelf.repayToId = 0;
            wkSelf.repayToColor = @"";
            CoreSVPCenterMsg(@"评论已发送");
        }
    } failure:^(NSError *error) {
        
    }];
    
    return YES;
}
#pragma mark ---prepare准备数据
-(void)preparePraiseRule
{
    __weak typeof(self) wkSelf = self;
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@/versus/praiseRule",HeadUrl] parameters:nil inView:nil sucess:^(id result) {
        wkSelf.praiseRestCost = [result objectForKey:@"praiseRestCost"];
        
    } failure:^(NSError *error) {
        
    }];
}
-(void)prepareDataWithFirst:(BOOL)first
{
    __weak typeof(self) wkSelf = self;
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@%@%ld",HeadUrl,@"/versus/",(long)self.pkId] parameters:nil inView:nil sucess:^(id result) {
        if (result) {
            NSNumber *errCode = [result objectForKey:@"errCode"];
            if (errCode.integerValue == 3001) {//视频被下架
                CoreSVPCenterMsg([result objectForKey:@"errMsg"]);
                [wkSelf.navigationController popViewControllerAnimated:YES];
                return ;
            }
            BOOL shouldCustomSuoLue = YES;
            if (wkSelf.pkModel) {
                shouldCustomSuoLue = NO;
            }
            PKModel *model = [PKModel mj_objectWithKeyValues:result];
            self.pkModel  = model;
            if (first) {
                wkSelf.naviTitleLabel.text = wkSelf.pkModel.formatertagName;
                wkSelf.leftPlaying = !wkSelf.clickRightVideo;
                if (shouldCustomSuoLue) {
                    PkDetailVIdeoTableViewCell *cell = [wkSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0 ]];
                    cell.PlayerView.placeholderImageUrl = self.currentVideo.frontCover;
                    [cell.PlayerView setVideoURL:[NSURL URLWithString:self.currentVideo.m3u8]];
//                    [[SDWebImageDownloader sharedDownloader]downloadImageWithURL:[NSURL URLWithString:self.currentVideo.frontCover] options:SDWebImageDownloaderHighPriority progress:nil completed:nil];
//                    [[SDWebImageDownloader sharedDownloader]downloadImageWithURL:[NSURL URLWithString:self.anotherVideo.frontCover] options:SDWebImageDownloaderHighPriority progress:nil completed:nil];
                    [wkSelf customSuolueVideo:cell];
                    
                }
                [wkSelf.tableView reloadData];
            }else{
                [wkSelf updataPkdetailinfoTableViewCell];
            }
        }
    } failure:^(NSError *error) {
        
    }];

}
-(void)prepareWSpinglun:(NSInteger)page
{
    __weak typeof(self) wkSelf = self;
    [[SocketManager defaultManager] sendMsg:[NSString stringWithFormat:@"{uri:\"public/pk/loadCmt?versusId=%@&pn=%@\"}",@(wkSelf.pkId),@(page)]];
}

-(NSArray *)prepareShareData
{
    NSMutableArray *shares = [NSMutableArray new];
    if ([QQApiInterface isQQInstalled]) {
        [shares addObject:@"pengyouquan"];
        [shares addObject:@"weixin"];
    }
    [shares addObject:@"weibo"];
    if ([WXApi isWXAppInstalled]) {
        [shares addObject:@"qq"];
        [shares addObject:@"kongjian"];
    }
    [shares addObject:@"fuzhi"];
    return shares;
}
-(void)prepareUploadPlayTimes
{
    contestantVideosModel *video = self.leftPlaying?self.pkModel.contestantVideos.firstObject:self.pkModel.contestantVideos.lastObject;
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyMMddHHmmss"];
    NSLocale* local =[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    [formater setLocale:local];
    NSString *ts = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]*1000];
    
    NSString *vc = [NSString stringWithFormat:@"id=%ld&ts=%@%@",(long)video.VideoId,ts,SECUREKEY];
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@%@",HeadUrl,@"/video/incPlayTime"] parameters:@{@"id":[NSString stringWithFormat:@"%ld",(long)video.VideoId],@"ts":ts,@"vc":vc.md5} inView:nil sucess:^(id result) {
        if (result) {
            DbLog(@"%@",result);
        }
    } failure:^(NSError *error) {
        
    }];
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
    UITapGestureRecognizer *tp1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapEmptyWhileInput:)];
    [shareBordView addGestureRecognizer:tp1];
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
    [self stopPauseByTemporary];
    UIView *shareBord = quxiaofenxiangBtn.superview;
    CGRect rec = shareBord.frame;
    rec.origin.y = SCREEN_H;
    [UIView animateWithDuration:0.2 animations:^{
        shareBord.frame = rec;
    } completion:^(BOOL finished) {
        [quxiaofenxiangBtn.superview.superview removeFromSuperview];
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
-(void)tapEmptyWhileInput:(UITapGestureRecognizer *)recogizer{//点击空白处
    [self.view endEditing:YES];
    if (![self.PinglunTF.placeholder isEqualToString:@"禁言中"]) {
        self.PinglunTF.placeholder = @"说点什么吧...";
    }
    
    //    self.PinglunTF.text = @"";
    self.repayToId = 0;
    self.repayToColor = @"";
    //    if (self.PinglunTF.text.length==0) {
    //
    //    }
}

-(void)onTapShareEmpty:(UITapGestureRecognizer *)recogizer
{
    [self onQuxiaoShareClick:self.shareBtn];
//    [recogizer.view removeFromSuperview];
    //    [self.PlayerView goOnPlay];
}
-(void)onVideoSuoLueCLick:(UIButton *)sender{//点击了角落的视频缩略图
    sender.userInteractionEnabled = NO;
    [self stopSuolueAnimation];
    
    [TalkingDataGA onEvent:KDIANJISUOLUETU eventData:@{@"点击_视频缩略图":@(1)}];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"PK详情页"
                                                          action:@"点击视频缩略图"
                                                           label:nil
                                                           value:@1] build]];
    __weak typeof(self) wkSelf = self;
    [UIView animateWithDuration:0.6 animations:^{
        sender.frame = CGRectMake(0, 0, SCREEN_W, SCREEN_W);
    } completion:^(BOOL finished) {
        if (finished) {
            sender.userInteractionEnabled = YES;
            
            if (wkSelf.leftPlaying) {//左边正在播放，选中右边
                sender.frame = CGRectMake(5, SCREEN_W-120, 85, 85);
                
                wkSelf.leftPlaying = NO;
                [wkSelf.suolueBtn sd_setImageWithURL:[NSURL URLWithString:self.anotherVideo.frontCover] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"00"]];
//                [wkSelf.suolueBtn setBackgroundImage:[[SDImageCache sharedImageCache] imageFromDiskCacheForKey:wkSelf.anotherVideo.frontCover] forState:UIControlStateNormal];
                wkSelf.suolueBtn.layer.borderColor = [UIColor colorWithHexColorString:@"ff4a4b"].CGColor;
                [wkSelf.zyPlayer resetToPlayNewURL];
                wkSelf.zyPlayer.placeholderImageUrl = wkSelf.currentVideo.frontCover;
                [wkSelf.zyPlayer setVideoURL:[NSURL URLWithString:wkSelf.currentVideo.m3u8]];
                BOOL isWIFI = [[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi];
                if (isWIFI) {//wifi环境
                    NSNumber *autoPlay = [[NSUserDefaults standardUserDefaults] objectForKey:PLAYERAUTOPLAY];
                    if (!autoPlay || autoPlay.integerValue == 1) {//且没设置wifi不播放，或者设置了Wi-Fi播放
                        [self.zyPlayer autoPlayTheVideo];
                    }
                }
                [wkSelf.tableView reloadData];
                
            }else{//右边正在播放，选中左边
                sender.frame = CGRectMake(SCREEN_W-90, SCREEN_W-120, 85, 85);
                
                wkSelf.leftPlaying = YES;
                
                [wkSelf.suolueBtn sd_setImageWithURL:[NSURL URLWithString:self.anotherVideo.frontCover] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"00"]];
//                [wkSelf.suolueBtn setBackgroundImage:[[SDImageCache sharedImageCache] imageFromDiskCacheForKey:wkSelf.anotherVideo.frontCover] forState:UIControlStateNormal];
                wkSelf.suolueBtn.layer.borderColor = [UIColor colorWithHexColorString:@"03a9f3"].CGColor;
                
                [wkSelf.zyPlayer resetToPlayNewURL];
                wkSelf.zyPlayer.placeholderImageUrl = wkSelf.currentVideo.frontCover;
                [wkSelf.zyPlayer setVideoURL:[NSURL URLWithString:wkSelf.currentVideo.m3u8]];
                BOOL isWIFI = [[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi];
                if (isWIFI) {//wifi环境
                    NSNumber *autoPlay = [[NSUserDefaults standardUserDefaults] objectForKey:PLAYERAUTOPLAY];
                    if (!autoPlay || autoPlay.integerValue == 1) {//且没设置wifi不播放，或者设置了Wi-Fi播放
                        [self.zyPlayer autoPlayTheVideo];
                    }
                }
                [wkSelf.tableView reloadData];
            }
            sender.alpha = 1.0;
        }
        
    }];
}
- (void)onLeftGiftsClick {
    [self praiseOnLeft:YES];
}
- (void)onRightGiftsClick {
    [self praiseOnLeft:NO];
}

/**
 抽奖机会！
 */
-(void)goodLucky{
    LuckyAlert *alert = [[[NSBundle mainBundle]loadNibNamed:@"LuckyAlert" owner:self options:nil]lastObject];
    __weak typeof(self) wkSelf = self;
//    http://api.hongdoujiao.net:9090/v1/misc/lottery/index?token=rcmoy3qqizz8ttkm42597113ceddfe10
    [alert showIn:self.navigationController.view tips:@"" okClick:^{
        HtmlViewController *html = [[HtmlViewController alloc]init];
        html.url = [NSString stringWithFormat:@"%@/misc/lottery/index?token=%@",@"http://api.zuoyoupk.com/v1",[UserInfoManager mySelfInfoModel].token];
        [wkSelf.navigationController pushViewController:html animated:YES];
    }];
}

-(void)praiseOnLeft:(BOOL)left
{
    contestantVideosModel *video = left?self.pkModel.contestantVideos.firstObject:self.pkModel.contestantVideos.lastObject;
    if ([self.pkModel.currentTimeString isEqualToString:@"已结束"] ||[self.pkModel.currentTimeString isEqualToString:@"00:00:00"]) {
        CoreSVPCenterMsg(@"PK已经结束");
        return;
    }
    
    [self onPraiseWithversusId:@(self.pkModel.pkID) versusContestantId:@(video.versusContestantId)];
    
}
-(void)onPraiseWithversusId:(NSNumber *)versusId versusContestantId:(NSNumber *)versusContestantId
{
    if (!versusId || !versusContestantId) {
        DbLog(@"参数不能为空");
        return;
    }
    __weak typeof(self) wkSelf = self;
    NSDictionary *param = @{@"versusId":versusId,@"versusContestantId":versusContestantId};
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@/versus/praise",HeadUrl] parameters:param inView:nil sucess:^(id result) {
        if ([result objectForKey:@"errCode"]) {
            NSString *errCode = [NSString stringWithFormat:@"%@",[result objectForKey:@"errCode"]];
            if (errCode.integerValue == 3007) {//正在冷却呢
                NSMutableAttributedString *titleText = [NSMutableAttributedString new];
                UIFont *font = [UIFont systemFontOfSize:11];
                NSString *title = @"23：44后可点赞，使用";
                [titleText appendAttributedString:[[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexColorString:@"888888"],NSFontAttributeName:font}]];
                UIImage *image = [UIImage imageNamed:@"胜方获得金豆"];
                image = [UIImage imageWithCGImage:image.CGImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
                NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:image contentMode:UIViewContentModeScaleAspectFit attachmentSize:CGSizeMake(15, 12) alignToFont:font alignment:YYTextVerticalAlignmentCenter];
                [titleText appendAttributedString:attachText];
                [titleText appendAttributedString:[[NSAttributedString alloc] initWithString:@"x3" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexColorString:@"ffc133"],NSFontAttributeName:font}]];
                [titleText appendAttributedString:[[NSAttributedString alloc] initWithString:@"跳过等待" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexColorString:@"888888"],NSFontAttributeName:font}]];
                titleText.yy_alignment = NSTextAlignmentRight;
                ResetCoolAlert *alv = [[[NSBundle mainBundle]loadNibNamed:@"ResetCoolAlert" owner:wkSelf options:nil]lastObject];
                wkSelf.coolAlvPointer = alv;
                [alv showWithTime:wkSelf.pkModel.praiseInfo.praiseColdDownSec praiseRestCost:wkSelf.praiseRestCost showIn:wkSelf.navigationController.view tips:[result objectForKey:@"errMsg"] okClick:^{
                    [wkSelf resetPraise];
                }];
                
            }else{
                CoreSVPCenterMsg([result objectForKey:@"errMsg"]);
            }
        }else{
            CoreSVPCenterMsg([result objectForKey:@"msg"]);
            //更新下这个冷却
//            PraiseInfoModel *pariseInfo = [PraiseInfoModel mj_objectWithKeyValues:result];
//            self.pkModel.praiseInfo = pariseInfo;
            [wkSelf prepareDataWithFirst:NO];
        }
    } failure:^(NSError *error) {
        
    }];
}
//重置冷却时间
-(void)resetPraise
{
    NSDictionary *param = @{@"versusId":[NSString stringWithFormat:@"%ld",(long)self.pkModel.pkID]};
    __weak typeof(self) wkSelf = self;
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@/versus/resetPraise",HeadUrl] parameters:param inView:nil sucess:^(id result) {
        [wkSelf.coolAlvPointer canUse:YES];
        if ([result objectForKey:@"errCode"]) {
            NSString *errCode = [NSString stringWithFormat:@"%@",[result objectForKey:@"errCode"]];
            if (errCode.integerValue == 1012) {//余额不足
                [XYWAlert XYWAlertTitle:@"无金豆可用，充值获取更多金豆" message:nil first:@"充值" firstHandle:^{
                    [wkSelf goToChongzhi];
                } second:nil Secondhandle:nil cancle:@"取消" handle:^{
                    
                }];
            }else{
                CoreSVPCenterMsg([result objectForKey:@"errMsg"]);
            }
        }else{
            //更新下这个冷却
            CoreSVPCenterMsg([result objectForKey:@"msg"]);
            PraiseInfoModel *pariseInfo = [PraiseInfoModel mj_objectWithKeyValues:result];
            wkSelf.pkModel.praiseInfo = pariseInfo;
            [wkSelf.coolAlvPointer dismiss];
        }
    } failure:^(NSError *error) {
        [wkSelf.coolAlvPointer canUse:YES];
    }];
}

#pragma mark ---alertView代理方法
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 88) {//购买礼物时金豆不足
        if (buttonIndex==0) {
            
        }else if (buttonIndex ==1){
            [self goToChongzhi];
        }
    }else{
//        [self changeRootView];
    }
}

-(void)goToChongzhi
{
    [TalkingDataGA onEvent:KQUCHONGZHI eventData:@{@"详情页_去充值":@(1)}];
//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"PK详情页"
//                                                          action:@"跳转去充值页面"
//                                                           label:[NSString stringWithFormat:@"%.2f",self.zyPlayer.controlView.videoSlider.value]
//                                                           value:@1] build]];
    ChongZhiViewController *czVC = [[ChongZhiViewController alloc]initWithNibName:@"ChongZhiViewController" bundle:nil];
    [self.navigationController pushViewController:czVC animated:YES];
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
    [manager shareToWx:parm result:^(NSDictionary *userInfo) {
        if ([userInfo[@"shareState"] isEqualToString:@"sucess"]) {
            [wkSelf shareOnce];
            CoreSVPSuccess(@"分享成功");
            if (sender.tag == 100) {
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
    contestantVideosModel *rightVidelModel = self.pkModel.contestantVideos.lastObject;
    contestantVideosModel *leftVidelModel = self.pkModel.contestantVideos.firstObject;
    NSString *type;
    NSString *shareDesc = @"来左右跟我PK吧！";
    if (self.leftPlaying) {
        shareImg = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:leftVidelModel.frontCover];
        shareImgUrl = leftVidelModel.frontCover;
        type = @"RED";
    }else{
        shareImgUrl = rightVidelModel.frontCover;
        shareImg = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:rightVidelModel.frontCover];
        type = @"BLUE";
    }
    shareTitle = self.pkModel.formatertagName;
    shareUrl = [NSString stringWithFormat:@"http://www.zuoyoupk.com/pk/%ld?&contestant=%@",(long)self.pkModel.pkID,type];
    return @{@"shareDesc":shareDesc,@"shareTitle":shareTitle,@"shareImg":shareImg,@"shareImgUrl":shareImgUrl,@"shareUrl":shareUrl};
}
#pragma mark ---通知的handle
-(void)showControlView{
    DbLog(@"显示缩略图");
    __weak typeof(self) wkSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        wkSelf.suolueBtn.alpha = 1;
    }];
}
-(void)hideControlView{
    DbLog(@"隐藏缩略图");
    __weak typeof(self) wkSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        wkSelf.suolueBtn.alpha = 0;
    }];
}
- (void)notificationCenterEventDetail:(id)sender {//每秒钟读取一下倒计时
    [self.pkModel cutDown];
    
    if (_tableView) {
        PkdetailUserTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        cell.timeLabel.text = self.pkModel.currentTimeString;
        
        [self updataPkdetailinfoTableViewCell];
    }
    
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    // 键盘的frame发生改变时调用（显示、隐藏等）
    NSDictionary *userInfo = notification.userInfo;
    // 动画的持续时间
    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    // 键盘的frame
    CGRect keyboardF = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    DbLog(@"keyb %@ screen %f %f",NSStringFromCGRect(keyboardF),SCREEN_H,SCREEN_W);
    // 执行动画
    
    if (keyboardF.origin.y<SCREEN_H) {
        self.pinglunH.constant = SCREEN_H;
    }else{
        self.pinglunH.constant = 60;
    }
    __weak typeof(self) wkSelf = self;
    [UIView animateWithDuration:duration animations:^{
        wkSelf.pinglunALBotton.constant = SCREEN_H - keyboardF.origin.y;
        
        [wkSelf.view layoutIfNeeded];
    }];
}
-(void)didReceiveWsOpen
{
    self.pinglunCurrentPage = 1;
    [self prepareWSpinglun:self.pinglunCurrentPage];
    if (self.haveShared) {
        [self requestServerShared];
    }
}
/**
 *  收到评论列表
 *
 *  @param noti 通知的内容
 *  需要更改一下cell的评论总数和评论列表，通过reloadData更新。
 */
-(void)didReceiceWsPinglun:(NSNotification *)noti
{
    NSDictionary *dic = noti.userInfo;
    DbLog(@"%@",dic);
    WSmessageModel *msModel = dic[@"model"];
    if (msModel&&[msModel.body isKindOfClass:[NSArray class]]) {
        NSArray *bodys = (NSArray *)msModel.body;
        if (bodys.count>0) {
            [self.tableView.mj_footer endRefreshing];
        }else{
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
            return;
        }
        
        if (self.pinglunCurrentPage < 2) {
            [self.pinglunDataSource removeAllObjects];
        }
        
        for (NSDictionary *pl in bodys) {
            PinglunModel *plModel = [PinglunModel mj_objectWithKeyValues:pl];
            [self.pinglunDataSource addObject:plModel];
        }
        
        NSString *totalCnt = msModel.extras[@"totalCnt"];
        
        
        PkdetailinfoTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
        cell.pinglunShuLael.text =[NSString stringWithFormat:@"评论%@",totalCnt];
        if (self.pinglunCurrentPage<2) {
            [self.tableView reloadData];
        }else{
            
        }
        self.pinglunCurrentPage ++;
    }
    
}
/**
 *  收到了新的评论
 *
 *  @param noti 评论内容

 */
-(void)didReceiveNewCmt:(NSNotification *)noti
{
    if (self.pinglunDataSource.count == 0) {
        self.pinglunCurrentPage = 1;
    }else{
        WSmessageModel *model = [noti.userInfo objectForKey:@"model"];
        NSDictionary *dic = model.mj_keyValues;
        PinglunModel *plModel = [PinglunModel mj_objectWithKeyValues:dic];
        
        [self.pinglunDataSource insertObject:plModel atIndex:0];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:4 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
    }
    [self prepareWSpinglun:self.pinglunCurrentPage];
}

#pragma mark ---界面的绘制
-(void)customTableView
{
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.PinglunTF.delegate = self;
    
    [self.PinglunTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_W, 0.1f)];
    __weak typeof(self) wkSelf = self;
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [wkSelf prepareWSpinglun:wkSelf.pinglunCurrentPage];
    }];
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
    label.text = self.pkModel.formatertagName;
    self.naviTitleLabel = label;
    self.navigationItem.titleView = label;
    //    self.navigationItem.title = self.pkModel.tagName;
}

-(void)onBackClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)customSuolueVideo:(UIView *)superView{//视频缩略图界面
    if (!self.suolueBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn addTarget:self action:@selector(onVideoSuoLueCLick:) forControlEvents:UIControlEventTouchUpInside];
        btn.backgroundColor = [UIColor whiteColor];
        btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
        btn.contentHorizontalAlignment= UIControlContentHorizontalAlignmentFill;
        btn.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
        [superView addSubview:btn];
        self.suolueBtn = btn;
    }
    CGRect rect = self.clickRightVideo?CGRectMake(5, SCREEN_W-120, 85, 85):CGRectMake(SCREEN_W-90, SCREEN_W-120, 85, 85);
    
    self.suolueBtn.frame = rect;
    
    UIColor *borderColor = self.clickRightVideo?[UIColor colorWithHexColorString:@"ff4a4b"]:[UIColor colorWithHexColorString:@"03a9f3"];
    self.suolueBtn.layer.borderColor = borderColor.CGColor;
    self.suolueBtn.layer.borderWidth = 1;
    
    [self.suolueBtn sd_setImageWithURL:[NSURL URLWithString:self.anotherVideo.frontCover] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"00"]];
//    UIImage *currentCorverImg = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:self.anotherVideo.frontCover];
//    [self.suolueBtn setBackgroundImage:currentCorverImg forState:UIControlStateNormal];
    
    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
    if (![usf objectForKey: KGuider]) {//还没有引导，就开始引导
        [self beginGuide];
    }else{
        BOOL isWIFI = [[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi];
        if (isWIFI) {//wifi环境
            NSNumber *autoPlay = [usf objectForKey:PLAYERAUTOPLAY];
            if (!autoPlay || autoPlay.integerValue == 1) {//且没设置wifi不播放，或者设置了Wi-Fi播放
                [self.zyPlayer autoPlayTheVideo];
            }
        }
    }
}
#pragma mark ---🎬scrollView代理方法
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.giftViewPageView.currentPage = scrollView.contentOffset.x/SCREEN_W;
}

#pragma mark ---🎬tableView代理方法
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (self.pinglunDataSource.count<1) {
        return 5;
    }
    return self.pinglunDataSource.count+4;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    contestantVideosModel *leftVideo = self.pkModel.contestantVideos.firstObject;
    contestantVideosModel *rightVideo = self.pkModel.contestantVideos.lastObject;
    
    if (indexPath.row == 0) {
        PkDetailVIdeoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PkDetailVIdeoTableViewCell"];
        if (!cell) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"PkDetailVIdeoTableViewCell" owner:self options:nil]lastObject];
            self.zyPlayer = cell.PlayerView;
            if (self.pkModel) {
                cell.PlayerView.placeholderImageUrl = self.currentVideo.frontCover;
                [cell.PlayerView setVideoURL:[NSURL URLWithString:self.currentVideo.m3u8]];
                [self customSuolueVideo:cell];
            }
        }
        return cell;
    }else if (indexPath.row ==1){
        PkdetailUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PkdetailUserTableViewCell"];
        if (!cell) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"PkdetailUserTableViewCell" owner:self options:nil]lastObject];
            UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onUserTap:)];
            [cell.leftIconImgV addGestureRecognizer:tap1];
            UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onUserTap:)];
            [cell.rightIconImgV addGestureRecognizer:tap2];
            self.UserTableViewCellPointer = cell;
        }
        
        [UserInfoManager setNameLabel:cell.leftNameLabel headImageV:cell.leftIconImgV corverImageV:cell.leftType with:@(leftVideo.mid)];
        [UserInfoManager setNameLabel:cell.rightNameLabel headImageV:cell.rightIconImgV corverImageV:cell.rightType with:@(rightVideo.mid)];
        
        cell.timeLabel.text = self.pkModel.currentTimeString;
        cell.selectedRight = !self.leftPlaying;
        if (self.pkModel.winnerVersusContestantId>0) {
            if (  self.pkModel.winnerVersusContestantId==leftVideo.versusContestantId) {
                cell.leftType.image = [UIImage imageNamed:@"赛事皇冠-左"];
                cell.rightType.image = [UIImage imageNamed:@"赛事头像corver"];
            }else if (self.pkModel.winnerVersusContestantId==rightVideo.versusContestantId){
                cell.leftType.image = [UIImage imageNamed:@"赛事头像corver"];
                cell.rightType.image = [UIImage imageNamed:@"赛事皇冠-右"];
            }
        }
        
        return cell;
        
    }else if (indexPath.row ==2){
        PkdetailDescTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PkdetailDescTableViewCell"];
        if (!cell) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"PkdetailDescTableViewCell" owner:self options:nil]lastObject];
        }
        if (self.currentVideo.videoDescription.length>0) {
            cell.descLabel.text = self.currentVideo.videoDescription;
        }else{
            cell.descLabel.text = @"哦噢，up主什么也没说～";
        }
        cell.selectedRight = !self.leftPlaying;
        
        return cell;
    }else if (indexPath.row ==3){
        PkdetailinfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PkdetailinfoTableViewCell"];
        if (!cell) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"PkdetailinfoTableViewCell" owner:self options:nil]lastObject];
            cell.delegate = self;
            guideGiftBtn = cell.rightGiftBtn;
        }
        
        [self updataPkdetailinfoTableViewCell];
        
        return cell;
    }else{
        if (self.pinglunDataSource.count<1) {
            NoPinglunTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoPinglunTableViewCell"];
            if (!cell) {
                cell = [[[NSBundle mainBundle]loadNibNamed:@"NoPinglunTableViewCell" owner:self options:nil]lastObject];
            }
            DbLog(@"%@",cell);
            return cell;
        }
        PinglunTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PinglunTableViewCellID"];
        if (!cell) {
            cell = (PinglunTableViewCell*)[[[NSBundle mainBundle]loadNibNamed:@"PinglunTableViewCell" owner:self options:nil]lastObject];
            cell.userIconImgV.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onUserTap:)];
            [cell.userIconImgV addGestureRecognizer:tap];
        }
        PinglunModel *model = self.pinglunDataSource[indexPath.row-4];
        cell.pinglunModel = model;
        cell.nickNameLabel.tag = model.body.mid;
        cell.userIconImgV.tag = model.body.mid;
        [UserInfoManager setNameLabel:cell.nickNameLabel headImageV:cell.userIconImgV corverImageV:cell.userCorver with:@(model.body.mid)];
//        [self setNameLabel:cell.nickNameLabel headImageV:cell.userIconImgV with:model.body.mid];
        
        return cell;
    }
}
-(void)updataPkdetailinfoTableViewCell
{
    
    PkdetailinfoTableViewCell *infocell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    contestantVideosModel *leftVideo = self.pkModel.contestantVideos.firstObject;
    contestantVideosModel *rightVideo = self.pkModel.contestantVideos.lastObject;
    //设置支持比赛按钮的状态
    
    if ([self.pkModel.currentTimeString isEqualToString:@"已结束"] || [self.pkModel.currentTimeString isEqualToString:@"00:00:00"]) {
//        infocell.PraiseBtnLight = NO;
        infocell.praiseBtnState = versusPraiseStateEnd;
    }else if(self.pkModel.praiseInfo ) {//正在冷却呢
        if (self.pkModel.praiseInfo.versusContestantId.integerValue == leftVideo.versusContestantId) {//左边正在冷却的
            if (self.pkModel.praiseInfo.praiseColdDownSec>0) {//还在冷却中
                infocell.praiseBtnState = versusPraiseStateCoolingLeft;
            }else{//冷却完毕
                infocell.praiseBtnState = versusPraiseStateCoolingLeft|versusPraiseStateCooled;
            }
            
        }else if (self.pkModel.praiseInfo.versusContestantId.integerValue == rightVideo.versusContestantId){
            if (self.pkModel.praiseInfo.praiseColdDownSec>0) {//还在冷却中
                infocell.praiseBtnState = versusPraiseStateCoolingRight;
            }else{//冷却完毕
                infocell.praiseBtnState = versusPraiseStateCoolingRight|versusPraiseStateCooled;
            }
        }
    }else {//正在进行
        infocell.praiseBtnState = versusPraiseStateNormal;
    }
    //设置点赞数和进度条
    [infocell setL:leftVideo.praiseCnt.integerValue andR:rightVideo.praiseCnt.integerValue];
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (indexPath.row==0) {
        if (self.shoulePlayWhenAppear) {
                [self.zyPlayer play];
        }
    }
}
-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        if (!self.zyPlayer.isPauseByUser) {
            self.shoulePlayWhenAppear = YES;
            [self.zyPlayer pause];
        }
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.pinglunDataSource.count<1||indexPath.row<4) {
        return;
    }
    PinglunModel *model = self.pinglunDataSource[indexPath.row-4];
    if (!model) {
        return;
    }
    MyselfInfoModel *my = [UserInfoManager mySelfInfoModel];
    
    NSString *idstr = [NSString stringWithFormat:@"%ld",(long)model.body.mid];
    NSString *midstr = [NSString stringWithFormat:@"%@",my.mid];
    if ([midstr isEqualToString:idstr]) {
        return;
    }
    if ([self.PinglunTF.placeholder isEqualToString:@"禁言中"]) {
        return;
    }
    PinglunTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *str = [NSString stringWithFormat:@"回复%@:",cell.nickNameLabel.text];
    self.PinglunTF.placeholder = str;
    [self.PinglunTF becomeFirstResponder];
    self.repayToId = model.body.mid;
    self.repayToColor = model.extras.contestantType;
}
-(void)onUserTap:(UITapGestureRecognizer *)recognizer
{
    UHCenterViewController *uh = [[UHCenterViewController alloc]init];
    uh.mid = recognizer.view.tag;
    [self.navigationController pushViewController:uh animated:YES];
}
#pragma mark - 通知中心


//添加通知
-(void)NotiAddObserver
{
    //全局计时器的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationCenterEventDetail:)
                                                 name:GLOBLETIMER
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(prepareUploadPlayTimes)
                                                 name:@"playonce"
                                               object:nil];
    //视频播放器的通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showControlView) name:kZYPlayShowControllerNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(hideControlView) name:kZYPlayHideControllerNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:kZYPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopSuolueAnimation) name:kZYPlayRepeatPlayNotification object:nil];
    //键盘的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    //消息服务的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveWsOpen) name:@"SOCKETOPEN" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiceWsPinglun:) name:@"publicpkloadCmt" object:nil];//收到评论列表
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNewCmt:) name:@"publicpknewCmt" object:nil];//有新评论
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goodLucky) name:@"systemuserlottery" object:nil];//获得抽奖机会
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNewGItfs:) name:@"systemfinanceitem" object:nil];//有新送礼
    
    
}
//移除通知
-(void)removeNotiObser
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    //通知服务器已离开
    __weak typeof(self) wkSelf = self;
    NSString *msgToLeave = [NSString stringWithFormat:@"{\"uri\":\"public/pk/quit?versusId=%@\"}",@(wkSelf.pkModel.pkID)];
    DbLog(@"通知服务器已离开");
    [[SocketManager defaultManager] sendMsg:msgToLeave];
    
}

/**
 视频播放完毕

 @param noti 来自播放器的通知
 */
-(void)moviePlayDidEnd:(NSNotification *)noti
{
    self.suolueBtn.alpha = 1;
    UIBezierPath *path=[UIBezierPath bezierPathWithRect:self.suolueBtn.bounds];
    CAShapeLayer *arcLayer=[CAShapeLayer layer];
    arcLayer.path=path.CGPath;
    arcLayer.fillColor=[UIColor clearColor].CGColor;
    arcLayer.strokeColor=self.leftPlaying?[UIColor colorWithHexColorString:@"03a9f3"].CGColor:[UIColor colorWithHexColorString:@"ff4a4b"].CGColor;
    arcLayer.lineWidth=10*SINGLE_LINE_WIDTH;
    arcLayer.frame=self.suolueBtn.bounds;
    [self.suolueBtn.layer addSublayer:arcLayer];
    [self drawLineAnimation:arcLayer];
    __weak typeof(self) wkSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (arcLayer && arcLayer.superlayer) {
            [arcLayer removeFromSuperlayer];
            [wkSelf onVideoSuoLueCLick:wkSelf.suolueBtn];
        }
    });
}
/**
 *  取消缩略图倒计时播放另一个
 */
-(void)stopSuolueAnimation
{
    for (CALayer *layer in self.suolueBtn.layer.sublayers) {
        if ([layer isKindOfClass:[CAShapeLayer class]]) {
            [layer removeAllAnimations];
            [layer removeFromSuperlayer];
        }
    }
}
-(void)drawLineAnimation:(CALayer*)layer
{
    CABasicAnimation *bas=[CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    bas.duration=3;
    bas.fromValue=[NSNumber numberWithInteger:0];
    bas.toValue=[NSNumber numberWithInteger:1];
    [layer addAnimation:bas forKey:@"key"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self.zyPlayer resetPlayer];
    self.zyPlayer = nil;
    DbLog(@"%@释放了",self.class);
}
/**
 临时暂停（分享，侧滑时）
 */
-(void)pauseByTemporary{
    if (!self.zyPlayer.isPauseByUser) {
        [self.zyPlayer pause];
        self.shoulePlayWhenAppear = YES;
    }
}

/**
 结束临时暂停
 */
-(void)stopPauseByTemporary{
    if (self.shoulePlayWhenAppear) {
        [self.zyPlayer play];
        self.shoulePlayWhenAppear = NO;
    }
}
-(NSString *)only1Space:(NSString *)str{
    NSString *orgStr = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    while ([orgStr rangeOfString:@"  "].location != NSNotFound) {
        orgStr = [orgStr stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    }
    return orgStr;
}
#pragma mark ---API相关的东西
-(void)shareOnce
{
    self.haveShared = YES;
    
}
-(void)requestServerShared
{
    self.haveShared = NO;
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@%@",HeadUrl,@"/share/finish"] parameters:nil inView:nil sucess:^(id result) {
        DbLog(@"%@",result);
        
    } failure:^(NSError *error) {
        
    }];
}
#pragma mark ---视图VIew的delegate
-(void)onGiftSenderclick:(BOOL)left
{
    if (left) {
        
    }else{
        
    }
}
#pragma mark ---新手指导delegate
-(void)beginGuide
{
    QiehuanGuideView *guide = [QiehuanGuideView new];
    guide.delegate  = self;
    
    [guide showInView:[UIApplication sharedApplication].keyWindow maskBtn:self.suolueBtn];
}
-(void)QiehuanGuideNext
{
    [self onVideoSuoLueCLick:self.suolueBtn];
    __weak typeof(self) wkSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        liwuGuidView *guide = [liwuGuidView new];
        guide.delegate = wkSelf;
        [guide showInView:[UIApplication sharedApplication].keyWindow maskBtn:guideGiftBtn];
    });
}
-(void)liwuGuidViewNext
{
    [self onRightGiftsClick];
}

@end
