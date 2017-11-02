//
//  VideoListViewController.m
//  ZuoYou
//
//  Created by xueyongwei on 16/11/3.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "VideoListViewController.h"
#import "VideosModel.h"

#import "TagDetailViewController.h"

#import "ReviewMovieViewController.h"
#import "UploadVideoAlertView.h"
#import "FromMyvideosViewController.h"

#import "VideoWithTagTableViewCell.h"
 #import <MediaPlayer/MediaPlayer.h>
#import "FromLocalALbumViewController.h"
#import "CaptureViewController.h"
#import "VideoDetailViewController.h"

@interface VideoListViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (nonatomic,assign)NSInteger currentPage;
@property (nonatomic,strong)UIButton *noDataBtn;
@property (nonatomic,assign)BOOL requestingData;
@property (nonatomic,strong)NSNumber *selectIndexRow;
@property (nonatomic,assign)BOOL canScroll;
@property (nonatomic,strong) void(^finishRefreshBlock)(void);
@end

@implementation VideoListViewController

-(UIButton *)noDataBtn
{
    if (!_noDataBtn) {
        _noDataBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_noDataBtn setImage:[UIImage imageNamed:@"上传视频豆豆-red"] forState:UIControlStateNormal];
        _noDataBtn.tag = self.tagID.integerValue;
        [_noDataBtn addTarget:self action:@selector(onUploadVideo:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _noDataBtn;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self zyInit];
    [self customTabelView];
    self.edgesForExtendedLayout = UIRectEdgeNone;
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
-(void)refreshData:(void(^)(void))finishBlock{
    self.finishRefreshBlock = finishBlock;
    self.currentPage = 1;
    [self.tableView.mj_footer resetNoMoreData];
    [self prepareData:self.currentPage];
}
#pragma mark ---初始化操作
-(void)zyInit
{
    self.currentPage = 1;
    self.requestingData = NO;
}
-(void)customNavi
{
    [super customNavi];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -3;
    //右上角上传按钮
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    btn.frame = CGRectMake(0, 0, 44, 60);
    btn.tag = self.tagID.integerValue;
    [btn addTarget:self action:@selector(onUploadVideo:) forControlEvents:UIControlEventTouchDown];
    [btn setImage:[UIImage imageNamed:@"上传"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"上传"] forState:UIControlStateHighlighted];
    UIBarButtonItem *itm = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,itm];
}
-(void)customTabelView
{
    self.tableView.backgroundColor = [UIColor colorWithHexColorString:@"f4f4f4"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 125;
    __weak typeof(self) wkSelf = self;
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
       [wkSelf prepareData:self.currentPage];
    }];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

-(void)prepareData:(NSInteger)page
{
    self.requestingData = YES;
    NSString *url = [NSString stringWithFormat:@"%@%@",HeadUrl,@"/video/search"];
    NSMutableDictionary *param = [NSMutableDictionary new];
    [param setObject:@(page) forKey:@"pn"];
    if (self.tagID) {
        [param setObject:self.tagID forKey:@"tagId"];
    }
    [XYWhttpManager XYWpost:url parameters:param inView:nil sucess:^(id result) {
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
        VideosModel *model = [VideosModel mj_objectWithKeyValues:dic];
        [self.dataSource addObject:model];
    }
    DbLog(@"%@",self.dataSource);
    [self.tableView reloadData];
    self.currentPage ++;
}
#pragma mark --tableView代理方法

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.dataSource.count<1) {
        [self.tableView addSubview:self.noDataBtn];
        [self.noDataBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.tableView).offset(100);
            make.centerX.equalTo(self.tableView);
            make.width.height.mas_equalTo(200);
        }];
    }else{
        if (self.noDataBtn.superview) {
            [self.noDataBtn removeFromSuperview];
        }
    }
    return self.dataSource.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellTypeIsWithTag) {//带tag标签的
        VideoWithTagTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VideoWithTagTableViewCell"];
        if (!cell) {
            DbLog(@"创建一个新的cell");
            cell = [[[NSBundle mainBundle]loadNibNamed:@"VideoWithTagTableViewCell" owner:self options:nil]lastObject];
            [cell.pkBtn addTarget:self action:@selector(onPKWithVideo:) forControlEvents:UIControlEventTouchUpInside];
            UITapGestureRecognizer *tapTitle = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapTitleTagNameLabel:)];
            [cell.tagNameLabel addGestureRecognizer:tapTitle];
//            UITapGestureRecognizer *tapLeftVideoImg = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapLeftVideoImg:)];
//            [cell.leftVideoImg addGestureRecognizer:tapLeftVideoImg];
        }
        cell.leftVideoImg.tag = indexPath.row;
        cell.pkBtn.tag = indexPath.row;
        VideosModel *videoModel = self.dataSource[indexPath.row];
        cell.descLabel.text = videoModel.outline;
        [cell.leftVideoImg sd_setImageWithURL:[NSURL URLWithString:videoModel.frontCover] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
        cell.descLabel.text = videoModel.videoDescription;
        if (videoModel.tagActivity) {
            cell.tagNameLabel.attributedText = [self attributedTagName:videoModel.formatertagName];
        }else{
            cell.tagNameLabel.text = videoModel.formatertagName;
        }
        
        cell.tagNameLabel.tag = videoModel.tagId;
       
    
        [UserInfoManager setNameLabel:cell.userNameLabel headImageV:cell.userIconImgV corverImageV:cell.userIconCorver with:@(videoModel.mid)];
//        [self setNameLabel:cell.userNameLabel headImageV:cell.userIconImgV with:videoModel.mid];
        return cell;
    }
    VideoNormalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VideoNormalTableViewCell"];
    if (!cell) {
        DbLog(@"创建一个新的cell");
        
        cell = [[[NSBundle mainBundle]loadNibNamed:@"VideoNormalTableViewCell" owner:self options:nil]lastObject];
        [cell.pkBtn addTarget:self action:@selector(onPKWithVideo:) forControlEvents:UIControlEventTouchUpInside];
        UITapGestureRecognizer *tapLeftVideoImg = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapLeftVideoImg:)];
        [cell.leftVideoImg addGestureRecognizer:tapLeftVideoImg];
    }
    cell.pkBtn.tag = indexPath.row;
    cell.leftVideoImg.tag = indexPath.row;
    VideosModel *videoModel = self.dataSource[indexPath.row];
    cell.descLabel.text = videoModel.outline;
    [cell.leftVideoImg sd_setImageWithURL:[NSURL URLWithString:videoModel.frontCover] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    cell.descLabel.text = videoModel.videoDescription;
    [UserInfoManager setNameLabel:cell.userNameLabel headImageV:cell.userIconImgV  corverImageV:cell.userIcomCorver with:@(videoModel.mid)];
//    [self setNameLabel:cell.userNameLabel headImageV:cell.userIconImgV with:videoModel.mid];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataSource.count>5) {
        if (indexPath.row >= self.dataSource.count-5 && self.tableView.mj_footer.state != MJRefreshStateNoMoreData && !self.requestingData) {
            [self prepareData:self.currentPage];
        }
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VideosModel *model = self.dataSource[indexPath.row];
    VideoDetailViewController *detailVC = [[VideoDetailViewController alloc]initWithNibName:@"VideoDetailViewController" bundle:nil];
    detailVC.dataModel = model;
    detailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailVC animated:YES];
}
#pragma mark --事件
-(void)tapTagHotArea:(UITapGestureRecognizer *)recognizer
{
    
}
-(void)tapTitleTagNameLabel:(UITapGestureRecognizer *)recognizer
{
    DbLog(@"标签ID %ld",recognizer.view.tag);
    UILabel *label = (UILabel *)recognizer.view;
    
    TagDetailViewController *tgDetailVC = [[TagDetailViewController alloc]initWithNibName:@"TagDetailViewController" bundle:nil];
    tgDetailVC.tagID = @(recognizer.view.tag);
    tgDetailVC.tagName = label.text;
    tgDetailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:tgDetailVC animated:YES];
}
-(void)onUploadVideo:(UIButton *)sender
{
    if (!self.tagID) {
        [self.tabBarController setSelectedIndex:1];
        return;
    }
    self.selectIndexRow = nil;
    [self selecteFromPhotos];
}
-(void)onPKWithVideo:(UIButton *)sender
{
    VideosModel *model = self.dataSource[sender.tag];
    
    if ([UserInfoManager isMeOfID:model.mid]) {
        CoreSVPCenterMsg(@"试试挑战别人吧~");
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@%@",HeadUrl,@"/versus/challenge"];
    NSMutableDictionary *param = [NSMutableDictionary new];
    [param setObject:@0 forKey:@"tagID"];
    [param setObject:@0 forKey:@"contestantVideoId"];
    [param setObject:@0 forKey:@"videoId"];
    [param setObject:@"" forKey:@"description"];
    [XYWhttpManager XYWpost:url parameters:param inView:nil sucess:^(id result) {
        NSNumber *errCode = [result objectForKey:@"errCode"];
        if (errCode && errCode.integerValue == 3004) {
            CoreSVPCenterMsg([result objectForKey:@"errMsg"]);
            return ;
        }
        self.selectIndexRow = @(sender.tag);
        [self selecteFromPhotos];
    } failure:^(NSError *error) {
        CoreSVPCenterMsg(error.localizedDescription);
    }];

    
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
    
    
    [picker dismissViewControllerAnimated:YES completion:^{
        ReviewMovieViewController *rvc = [[ReviewMovieViewController alloc]initWithNibName:@"ReviewMovieViewController" bundle:nil];
//        rvc.moviePath = MediaURL.absoluteString;
        rvc.ReferenceURL = referenceURL;
        rvc.movieUrl = MediaURL;
        if (self.selectIndexRow == nil) {//直接上传新视频的
            rvc.uploadTagId = self.tagID;
            rvc.challenge = @"false";
        }else{//发起挑战的
            VideosModel *model = self.dataSource[self.selectIndexRow.integerValue];
            rvc.contestantVideoId = @(model.VideoId);
            rvc.uploadTagId = @(model.tagId);
            rvc.challenge = @"true";
            rvc.uploadTagName = model.formatertagName;
        }
        rvc.hidesBottomBarWhenPushed = YES;
        UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:rvc];
        
        [self presentViewController:navi animated:YES completion:nil];
    }];
}
-(void)selecteFromPhotos
{
    CaptureVideoNavigationController *navCon = [[CaptureVideoNavigationController alloc] init];
    navCon.showStatusWhenDealloc = YES;
    CaptureViewController *captureViewCon = [[CaptureViewController alloc] initWithNibName:@"CaptureViewController" bundle:nil];
    if (self.selectIndexRow == nil) {//直接上传新视频的
        captureViewCon.tagId = self.tagID;
        captureViewCon.challenge = @"false";
        captureViewCon.tagName = self.tagName;
    }else{//发起挑战的
        VideosModel *model = self.dataSource[self.selectIndexRow.integerValue];
        captureViewCon.contestantVideoId = @(model.VideoId);
        captureViewCon.tagId = @(model.tagId);
        captureViewCon.challenge = @"true";
        captureViewCon.tagName = model.formatertagName;
    }
    [navCon pushViewController:captureViewCon animated:YES];
    [self presentViewController:navCon animated:YES completion:nil];
    
}
-(void)tapLeftVideoImg:(UITapGestureRecognizer *)recoginzer
{
    VideosModel *model = self.dataSource[recoginzer.view.tag];
    VideoDetailViewController *detailVC = [[VideoDetailViewController alloc]initWithNibName:@"VideoDetailViewController" bundle:nil];
    detailVC.dataModel = model;
    detailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailVC animated:YES];
    
//    MPMoviePlayerViewController *playerVC = [[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL URLWithString:model.m3u8SRC1M]];
//    [self presentMoviePlayerViewControllerAnimated:playerVC];
    
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.shouldCareWhetherCanScroll) {
        CGFloat offsetY = scrollView.contentOffset.y;
        DbLog(@" sub-offsetY %f",offsetY);
        DbLog(@"canscrol =  %d",self.canScroll);
        if (!self.canScroll) {
            [scrollView setContentOffset:CGPointZero];
        }
        if (offsetY<0) {
            self.canScroll = NO;
            self.tableView.showsVerticalScrollIndicator = NO;
            [[NSNotificationCenter defaultCenter]postNotificationName:@"tagDetailfatherCanScroll" object:nil];
        }
    }
    
}
-(NSAttributedString *)attributedTagName:(NSString *)tagName
{
    // 添加表情
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ ",tagName]];
    NSTextAttachment *attch = [[NSTextAttachment alloc] init];
    // 表情图片
    attch.image = [UIImage imageNamed:@"tagName活动icon"];
    // 设置图片大小
    CGSize size = attch.image.size;
    attch.bounds = CGRectMake(0, -1, (size.width/size.height)*14, 14);
    
    // 创建带有图片的富文本
    NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:attch];
    [attri appendAttributedString:string];
    //    [attri addAttribute:NSForegroundColorAttributeName
    //                  value:[UIColor colorWithHexColorString:@"ff4a4b"]
    //                  range:NSMakeRange(0, attri.length)];
    [attri addAttributes:@{NSBaselineOffsetAttributeName:@(3),
                           NSForegroundColorAttributeName:[UIColor colorWithHexColorString:@"ff4a4b"],
                           } range:NSMakeRange(0, attri.length)];
    
    return attri;
}
@end
