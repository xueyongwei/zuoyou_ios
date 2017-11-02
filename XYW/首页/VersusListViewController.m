//
//  VersusListViewController.m
//  ZuoYou
//
//  Created by xueyongwei on 16/10/26.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>


#import "VersusListViewController.h"
#import "PKModel.h"
#import "NoDataView.h"
#import "TagDetailViewController.h"

#import "ReviewMovieViewController.h"
#import "UploadVideoAlertView.h"
#import "FromMyvideosViewController.h"
#import "XYWTimesLimitManager.h"
#import "VersusDetailViewController.h"
#import "FromLocalALbumViewController.h"
#import "CaptureViewController.h"

#import "TagDetailTableViewController.h"
//#import "UITableView+FDTemplateLayoutCellDebug.h"

@interface VersusListViewController ()
@property (nonatomic,assign)NSInteger currentPage;
@property (nonatomic,strong)NoDataView *noDataView;
@property (nonatomic,assign)BOOL requestingData;
@property (nonatomic,assign)NSInteger clickIndexPathRoW;
@property (nonatomic,assign)BOOL canScroll;
@property (nonatomic,strong) void(^finishRefreshBlock)(void);
@end

@implementation VersusListViewController

-(NoDataView *)noDataView
{
    if (!_noDataView) {
        _noDataView = [[[NSBundle mainBundle]loadNibNamed:@"NoDataView" owner:self options:nil]lastObject];
        _noDataView.msgLabel.text = self.noMoreDataMessage;
        
    }
    return _noDataView;
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self removeTimerObser];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self createTimer];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self zyInit];
    [self customTabelView];
   
}
-(void)setShouldCareWhetherCanScroll:(BOOL)shouldCareWhetherCanScroll
{
    _shouldCareWhetherCanScroll = shouldCareWhetherCanScroll;
    if (shouldCareWhetherCanScroll) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cancleLockNoti) name:@"tagDetailVCchildrenCanScroll" object:nil];
        
    }
}
-(void)cancleLockNoti{
    //    self.tableView.scrollEnabled = YES;
    DbLog(@"%@ － cancleLockNoti",NSStringFromClass(self.class));
    self.canScroll = YES;
    
    self.tableView.showsVerticalScrollIndicator = YES;
}
#pragma mark ---初始化操作
-(void)zyInit
{
    self.currentPage = 1;
    self.requestingData = NO;
}
-(void)customTabelView
{
    __weak typeof(self) wkSelf = self;
    self.tableView.backgroundColor = [UIColor colorWithHexColorString:@"f4f4f4"];
    BangdanMjHeader *header = [BangdanMjHeader headerWithRefreshingBlock:^{
        wkSelf.currentPage = 1;
        [wkSelf.tableView.mj_footer resetNoMoreData];
        [wkSelf prepareData:self.currentPage];
    }];
    header.lastUpdatedTimeLabel.hidden = YES;
    header.frame = CGRectMake(0, 0, SCREEN_W, 60);
    self.tableView.mj_header = header;
    [header beginRefreshing];
    self.tableView.mj_footer = [MJRefreshBackStateFooter footerWithRefreshingBlock:^{
        wkSelf.noMoreDataPage?[self.tableView.mj_footer endRefreshingWithNoMoreData]:[self prepareData:self.currentPage];
    }];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.estimatedRowHeight = ([UIScreen mainScreen].bounds.size.width-kLeadingAnTringVersusNormalTableViewCell)/2 + 130;
}
-(void)refreshData:(void(^)(void))finishBlock{
    self.finishRefreshBlock = finishBlock;
    self.currentPage = 1;
    [self.tableView.mj_footer resetNoMoreData];
    [self prepareData:self.currentPage];
}
-(void)prepareData:(NSInteger)page
{
    self.requestingData = YES;
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@%@",HeadUrl,self.requestURL] parameters:@{@"pn":@(page)} inView:nil sucess:^(id result) {
        self.requestingData = NO;
        DbLog(@"请求成功,result ＝ \n%@",result);
        [self.tableView.mj_header endRefreshing];
        if (self.finishRefreshBlock) {
            self.finishRefreshBlock();
        }
        if ([result isKindOfClass:[NSArray class]] ){//返回的是数组
            if ( ((NSArray *)result).count<1) {//并且没有了内容
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }else{
                page==1?[self.dataSource removeAllObjects]:[self.tableView.mj_footer endRefreshing];
            }
        }else{
            [self.tableView.mj_footer endRefreshing];
            return ;
        }
        [self resultResolver:(NSArray *)result];
    } failure:^(NSError *error) {
        if (self.finishRefreshBlock) {
            self.finishRefreshBlock();
        }
        self.requestingData = NO;
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
    }];
}
/**
 *  解析得到的数据到数据模型
 *
 *  @param result 请求到的数据数组
 */
-(void)resultResolver:(NSArray *)result
{
    for (NSDictionary *dic  in result) {
        PKModel *model = [PKModel mj_objectWithKeyValues:dic];
        if (model.tagId) {
           
            [self.dataSource addObject:model];
        }
    }
    DbLog(@"%@",self.dataSource);
    [self.tableView reloadData];
    self.currentPage ++;
}
#pragma mark ---通知中心
- (void)createTimer {
    [self removeTimerObser];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(timerEvent) name:GLOBLETIMER object:nil];
}
- (void)timerEvent {
    for (PKModel *model  in self.dataSource) {
        [model cutDown];
    }
    [self updataCells];
//    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIME_CELL object:nil];
}
-(void)updataCells
{
    for (VersusNormalTableViewCell *cell in self.tableView.visibleCells) {
        [cell updateWinType];
    }
}
-(void)removeTimerObser{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:GLOBLETIMER object:nil];
}
#pragma mark --tableView代理方法

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.dataSource.count<1) {
        [self.tableView insertSubview:self.noDataView atIndex:0];
//        [self.tableView addSubview:self.noDataView];
        [self.noDataView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.tableView).offset(100);
            make.centerX.equalTo(self.tableView);
            make.width.height.mas_equalTo(200);
        }];
    }else{
        if (self.noDataView && self.noDataView.superview) {
            [self.noDataView removeFromSuperview];
            self.noDataView = nil;
        }
    }
    return self.dataSource.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VersusNormalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VersusNormalTableViewCell"];
    if (!cell) {
        DbLog(@"创建一个新的cell");
        cell = [[[NSBundle mainBundle]loadNibNamed:@"VersusNormalTableViewCell" owner:self options:nil]lastObject];
        UITapGestureRecognizer *tapTitle = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapTitleTagNameLabel:)];
        [cell.tagHotArea addGestureRecognizer:tapTitle];
        [cell.pkLeftPKbtn addTarget:self action:@selector(onUploadVideo:) forControlEvents:UIControlEventTouchUpInside];
        [cell.pkRightPKbtn addTarget:self action:@selector(onUploadVideo:) forControlEvents:UIControlEventTouchUpInside];
    }
    PKModel *pkmodel = self.dataSource[indexPath.row];
    if (pkmodel) {
        cell.dataModel = pkmodel;
    }
    cell.pkRightPKbtn.tag = indexPath.row;
    cell.pkLeftPKbtn.tag = indexPath.row;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataSource.count>5) {
        if (indexPath.row >= self.dataSource.count-5 && self.tableView.mj_footer.state != MJRefreshStateNoMoreData && !self.noMoreDataPage && !self.requestingData) {
            [self prepareData:self.currentPage];
        }
    }
//    [cell layoutIfNeeded];
}
//消失的时候取消imageLoad
-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    __weak VersusNormalTableViewCell *cellPoint = (VersusNormalTableViewCell*)cell;
    [cellPoint.leftVideoImg sd_cancelCurrentImageLoad];
    [cellPoint.rightVIdeoImg sd_cancelCurrentImageLoad];
    [cellPoint.pkLeftUserIconImgV sd_cancelCurrentImageLoad];
    [cellPoint.pkRightUserIconImgV sd_cancelCurrentImageLoad];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    VersusDetailViewController *vc = [[VersusDetailViewController alloc]initWithStyle:UITableViewStylePlain];
//    vc.pkModel = self.dataSource[indexPath.row];
//    vc.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:vc animated:YES];
    
    VersusNormalTableViewCell *tmpCell = [tableView cellForRowAtIndexPath:indexPath];
    DbLog(@"%d",tmpCell.clickRightVideo);
    PKDetailViewController *detailV = [[PKDetailViewController alloc]initWithNibName:@"PKDetailViewController" bundle:nil];
    detailV.pkModel = self.dataSource[indexPath.row];
    detailV.hidesBottomBarWhenPushed = YES;
    detailV.clickRightVideo = tmpCell.clickRightVideo;
    [self.navigationController pushViewController:detailV animated:YES];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PKModel *model = self.dataSource[indexPath.row];
    if (model.outline && model.outline.length>0) {//有描述
        return ([UIScreen mainScreen].bounds.size.width-kLeadingAnTringVersusNormalTableViewCell)/2 + 130;
    }else{
        return ([UIScreen mainScreen].bounds.size.width-kLeadingAnTringVersusNormalTableViewCell)/2 + 105;
    }
}

#pragma mark ---点击事件
-(void)tapTitleTagNameLabel:(UITapGestureRecognizer *)recognizer
{
    DbLog(@"标签ID %ld",(long)recognizer.view.tag);
    UILabel *label = (UILabel *)recognizer.view;
    
    TagDetailViewController *tgDetailVC = [[TagDetailViewController alloc]initWithNibName:@"TagDetailViewController" bundle:nil];
//    TagDetailTableViewController *tgDetailVC = [[TagDetailTableViewController alloc]initWithStyle:UITableViewStylePlain];
    tgDetailVC.tagID = @(recognizer.view.tag);
    tgDetailVC.tagName = label.text;
    tgDetailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:tgDetailVC animated:YES];
}
-(void)onUploadVideo:(UIButton *)sender
{
    PKModel *pkmodel = self.dataSource[sender.tag];
    self.clickIndexPathRoW = sender.tag;
    contestantVideosModel *left = pkmodel.contestantVideos.firstObject;
    contestantVideosModel *right = pkmodel.contestantVideos.lastObject;
    NSInteger winMid = [pkmodel.winnerVersusContestantType isEqualToString:@"RED"]?left.mid:right.mid;
    if ([UserInfoManager isMeOfID:winMid]) {
        CoreSVPCenterMsg(@"试试挑战别人吧~");
        return;
    }
    NSString *url = [NSString stringWithFormat:@"%@%@",HeadUrl,@"/versus/challenge"];
    NSMutableDictionary *param = [NSMutableDictionary new];
    [param setObject:@0 forKey:@"tagID"];
    [param setObject:@0 forKey:@"contestantVideoId"];
    [param setObject:@0 forKey:@"videoId"];
    [param setObject:@"" forKey:@"description"];
    __weak typeof(self) wkSelf = self;
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
    CaptureVideoNavigationController *navCon = [[CaptureVideoNavigationController alloc] init];
    navCon.showStatusWhenDealloc = YES;
    CaptureViewController *captureViewCon = [[CaptureViewController alloc] initWithNibName:@"CaptureViewController" bundle:nil];
    PKModel *pkmodel = self.dataSource[self.clickIndexPathRoW];
    contestantVideosModel *left = pkmodel.contestantVideos.firstObject;
    contestantVideosModel *right = pkmodel.contestantVideos.lastObject;
    NSInteger contestantVideoId = [pkmodel.winnerVersusContestantType isEqualToString:@"RED"]?left.VideoId:right.VideoId;
    
    captureViewCon.challenge = @"true";
    captureViewCon.contestantVideoId = @(contestantVideoId);
    
    captureViewCon.tagId = @(pkmodel.tagId);
    captureViewCon.tagName = pkmodel.formatertagName;
    [navCon pushViewController:captureViewCon animated:YES];
    [self presentViewController:navCon animated:YES completion:nil];
    
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSLog(@"%@",info);
    NSURL *MediaURL = [info objectForKey:@"UIImagePickerControllerMediaURL"];
    NSURL *referenceURL = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:referenceURL options:nil];
    float second = asset.duration.value/asset.duration.timescale;
    if (second<15 || second>180) {
        UIAlertView *shotrVideoalv = [[UIAlertView alloc]initWithTitle:@"请选择15秒~3分钟的视频参与PK" message:nil delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [shotrVideoalv show];
        [picker popViewControllerAnimated:YES];
        return;
    }
    __weak typeof(self) wkSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        ReviewMovieViewController *rvc = [[ReviewMovieViewController alloc]initWithNibName:@"ReviewMovieViewController" bundle:nil];
        PKModel *pkmodel = wkSelf.dataSource[wkSelf.clickIndexPathRoW];
        contestantVideosModel *left = pkmodel.contestantVideos.firstObject;
        contestantVideosModel *right = pkmodel.contestantVideos.lastObject;
        NSInteger contestantVideoId = [pkmodel.winnerVersusContestantType isEqualToString:@"RED"]?left.VideoId:right.VideoId;
       
//        rvc.moviePath = MediaURL.absoluteString;
        rvc.ReferenceURL = referenceURL;
        rvc.movieUrl = MediaURL;
        rvc.uploadTagId = @(pkmodel.tagId);
        rvc.uploadTagName = pkmodel.formatertagName;
        rvc.challenge = @"true";
        rvc.contestantVideoId = @(contestantVideoId);
        rvc.hidesBottomBarWhenPushed = YES;
        UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:rvc];
        [wkSelf presentViewController:navi animated:YES completion:nil];
        //        [self.navigationController pushViewController:rvc animated:YES];
    }];
    
    
}
//-(void)selecteFromPhotos
//{
//    FromLocalALbumViewController *album = [[FromLocalALbumViewController alloc]init];
//    PKModel *pkmodel = self.dataSource[self.clickIndexPathRoW];
//    album.challenge = @"true";
//    album.uploadTagId = @(pkmodel.tagId);
//    album.uploadTagName = pkmodel.tagName;
//    contestantVideosModel *left = pkmodel.contestantVideos.firstObject;
//    contestantVideosModel *right = pkmodel.contestantVideos.lastObject;
//    NSInteger contestantVideoId = [pkmodel.winnerVersusContestantType isEqualToString:@"RED"]?left.VideoId:right.VideoId;
//    album.contestantVideoId = @(contestantVideoId);
//    album.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:album animated:YES];
//    return;
//    
//}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.shouldCareWhetherCanScroll) {
        CGFloat offsetY = scrollView.contentOffset.y;
        DbLog(@" sub-offsetY %f",offsetY);
        DbLog(@"canscrol =  %d",self.canScroll);
        if (!self.canScroll) {
            if (scrollView.contentOffset.y != 0) {
                [scrollView setContentOffset:CGPointZero];
            }
            
        }
        if (offsetY<0) {
            self.canScroll = NO;
            self.tableView.showsVerticalScrollIndicator = NO;
            [[NSNotificationCenter defaultCenter]postNotificationName:@"tagDetailfatherCanScroll" object:nil];
        }
    }
    
}

-(void)dealloc
{
    DbLog(@"VersusViewController 销毁了！");
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
