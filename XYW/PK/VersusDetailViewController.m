//
//  VersusDetailViewController.m
//  ZuoYou
//
//  Created by xueyongwei on 2016/12/7.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "VersusDetailViewController.h"
#import "VideoPlayerTableViewCell.h"
#import "PkdetailUserTableViewCell.h"
#import "PkdetailDescTableViewCell.h"
#import "PkdetailinfoTableViewCell.h"
#import "PinglunTableViewCell.h"

#import "SocketManager.h"
#import "XloginAndShareManager.h"

@interface VersusDetailViewController ()
@property (weak, nonatomic) IBOutlet UIView *inputWindow;

@property (nonatomic,strong)NSNumber *praiseRestCost;
@property (nonatomic,assign)BOOL leftPlaying;
@property (nonatomic,assign)NSInteger currentPage;
@end

@implementation VersusDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.pkModel) {
        self.versusId = self.pkModel.pkID;
    }
    
    [self customTableView];
    [self prepareData];
    
}
-(void)customTableView
{
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 200;
    [self.view bringSubviewToFront:self.inputWindow];
}
#pragma mark ---准备数据
-(void)prepareData{
    self.versusId = self.pkModel.pkID;
    [self prepareVersusData];
    [self preparePraiseRule];
    self.currentPage = 1;
    [self prepareWSpinglun:self.currentPage];
    [self prepareShareData];
}
#pragma mark ---prepare准备数据
//点赞规则
-(void)preparePraiseRule
{
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@/versus/praiseRule",HeadUrl] parameters:nil inView:nil sucess:^(id result) {
        self.praiseRestCost = [result objectForKey:@"praiseRestCost"];
        
    } failure:^(NSError *error) {
        
    }];
}
//准备赛事相关的数据
-(void)prepareVersusData
{
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@%@%ld",HeadUrl,@"/versus/",(long)self.versusId] parameters:nil inView:nil sucess:^(id result) {
        if (result) {
            NSNumber *errCode = [result objectForKey:@"errCode"];
            if (errCode.integerValue == 3001) {//视频被下架
                CoreSVPCenterMsg([result objectForKey:@"errMsg"]);
                [self.navigationController popViewControllerAnimated:YES];
                return ;
            }
            //更新pkModel
            self.pkModel  = [PKModel mj_objectWithKeyValues:result];
        }
    } failure:^(NSError *error) {
        
    }];
    
}

//请求评论数据
-(void)prepareWSpinglun:(NSInteger)page
{
    [[SocketManager defaultManager] sendMsg:[NSString stringWithFormat:@"{uri:\"public/pk/loadCmt?versusId=%@&pn=%@\"}",@(self.versusId),@(page)]];
}
//获取可分享的渠道
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
//上传播放次数
-(void)requestToUploadPlayTimes
{
    contestantVideosModel *video = [self currentPlayingVideo];
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
//当前正在播放的video
-(contestantVideosModel *)currentPlayingVideo
{
    return self.leftPlaying?self.pkModel.contestantVideos.firstObject:self.pkModel.contestantVideos.lastObject;
}

#pragma mark ---tableView代理
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section==0?4:self.dataSource.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section ==0) {
        if (indexPath.row == 0 ) {//播放器
            VideoPlayerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VideoPlayerTableViewCell"];
            if (!cell) {
                cell = [[[NSBundle mainBundle]loadNibNamed:@"VideoPlayerTableViewCell" owner:self options:nil]lastObject];
            }
            cell.playerView.placeholderImageUrl = [self currentPlayingVideo].frontCover;
            [cell.playerView setVideoURL:[NSURL URLWithString:[self currentPlayingVideo].m3u8]];
            return cell;
        }else if (indexPath.row ==1){//用户头像及时间
            PkdetailUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PkdetailUserTableViewCell"];
            if (!cell) {
                cell = [[[NSBundle mainBundle]loadNibNamed:@"PkdetailUserTableViewCell" owner:self options:nil]lastObject];
            }
            return cell;
        }else if (indexPath.row == 2){//视频描述
            PkdetailDescTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PkdetailDescTableViewCell"];
            if (!cell) {
                cell = [[[NSBundle mainBundle]loadNibNamed:@"PkdetailDescTableViewCell" owner:self options:nil]lastObject];
            }
            [self updataPkdetailinfoTableViewCell];
            return cell;
        }else {//pk对战情况
            PkdetailinfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PkdetailinfoTableViewCell"];
            if (!cell) {
                cell = [[[NSBundle mainBundle]loadNibNamed:@"PkdetailinfoTableViewCell" owner:self options:nil]lastObject];
            }
            return cell;
        }
    }
    //评论列表
    PinglunTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PinglunTableViewCellID"];
    if (!cell) {
        cell = (PinglunTableViewCell*)[[[NSBundle mainBundle]loadNibNamed:@"PinglunTableViewCell" owner:self options:nil]lastObject];
    }
    return cell;
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
@end
