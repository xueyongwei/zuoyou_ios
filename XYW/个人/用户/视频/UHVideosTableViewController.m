//
//  UHVideosTableViewController.m
//  ZuoYou
//
//  Created by xueyongwei on 16/9/19.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "UHVideosTableViewController.h"
#import "XYWPlayer.h"
#import "XYWAlert.h"
@interface UHVideosTableViewController ()<XYWPlayerDelegate>
@property (nonatomic,strong)NSMutableArray *dataSource;
@property (nonatomic,strong)UHVideosTableHeader *header;
@property (nonatomic,strong)XYWPlayer *xywPlayer;

@property (nonatomic,strong)UILabel *noDataLabel;
@property (nonatomic,assign)NSInteger currentPage;
@end

@implementation UHVideosTableViewController
-(UILabel *)noDataLabel
{
    if (!_noDataLabel) {
        _noDataLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_W/2-100, 100, 200, 21)];
        _noDataLabel.textAlignment = NSTextAlignmentCenter;
        _noDataLabel.text = @"还没有视频哦~";
        _noDataLabel.font = [UIFont systemFontOfSize:14];
        _noDataLabel.textColor = [UIColor colorWithHexColorString:@"999999"];
    }
    return _noDataLabel;
}
-(XYWPlayer*)xywPlayer
{
    if (!_xywPlayer) {
        _xywPlayer = [[XYWPlayer alloc]initWithUrl:@"" frame:self.header.frame delegate:self];
        
    }
    return _xywPlayer;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.xywPlayer.superview) {
        [self.xywPlayer xywPause];
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.xywPlayer.superview) {
        [self.xywPlayer xywPlay];
    }
//    [self prepareData:1];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentPage = 1;
    self.dataSource  = [NSMutableArray new];
    [self customTbaleView];
    [self prepareData:1];
}
-(void)customTbaleView
{
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    BangdanMjHeader *header = [BangdanMjHeader headerWithRefreshingBlock:^{
//        [self prepareData:1];
//    }];
//    header.frame = CGRectMake(0, 0, SCREEN_W, 60);
//    self.tableView.mj_header = header;
    __weak typeof(self) wkSelf = self;
    MJRefreshAutoStateFooter *footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
        [wkSelf prepareData:self.currentPage];
    }];
    [footer setTitle:@"" forState:MJRefreshStateIdle];
    self.tableView.mj_footer = footer;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

-(void)prepareData:(NSInteger)page
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/video/list",HeadUrl];
    NSDictionary *param = @{@"mid": @(self.mid),@"pn":@(page)};
    [XYWhttpManager XYWpost:urlStr parameters:param inView:nil sucess:^(id result) {
        DbLog(@"%@",result);
        
        if (page <= 1) {
            [self.tableView.mj_header endRefreshing];
            if ([(NSArray *)result count]>0){
                [self.dataSource removeAllObjects];
            }
        }else{
            if ([(NSArray *)result count]>0) {
                [self.tableView.mj_footer endRefreshing];
            }else{
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
                return ;
            }
            
        }
        if ([result isKindOfClass:[NSArray class]]) {
            
            for (NSDictionary *dic in (NSArray*)result) {
                MyVideoModel *model = [MyVideoModel mj_objectWithKeyValues:dic];
                [self.dataSource addObject:model];
            }
            [self.tableView reloadData];
            self.currentPage ++;
        }
    } failure:^(NSError *error) {
        if (page <= 1) {
            [self.tableView.mj_header endRefreshing];
        }else{
            [self.tableView.mj_footer endRefreshing];
        }
    }];
}
#pragma mark ---tableVIew的代理
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.dataSource.count ==0) {
        [self.tableView addSubview:self.noDataLabel];
        [(MJRefreshAutoStateFooter*)self.tableView.mj_footer setTitle:@"" forState:MJRefreshStateNoMoreData];
    }else{
        [(MJRefreshAutoStateFooter*)self.tableView.mj_footer setTitle:@"别拉啦，全都给你啦～" forState:MJRefreshStateNoMoreData];
        [self.noDataLabel removeFromSuperview];
    }
    return self.dataSource.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    MyVideoModel *model = self.dataSource[section];
    return model.versus.count;
}
-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    NSLog(@"will %ld",(long)section);
    self.header = (UHVideosTableHeader*)view;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UHVideosTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"UHVideosTableViewCell" owner:self options:nil]lastObject];
    }
    MyVideoModel *model = self.dataSource[indexPath.section];
    PKModel *pk = model.versus[indexPath.row];
    cell.tagName.text = pk.formatertagName;
    NSString *imgName = pk.winnerVersusContestantId>5?pk.winnerVersusContestantId==self.mid?@"角标_胜利":@"角标_失败":@"角标_进行";
    contestantVideosModel *left = pk.contestantVideos.firstObject;
    contestantVideosModel *right = pk.contestantVideos.lastObject;
    cell.statusFLag.image = [UIImage imageNamed:imgName];
    [UserInfoManager setNameLabel:nil headImageV:cell.leftUser corverImageV:cell.leftUser with:@(left.mid)];
    [UserInfoManager setNameLabel:nil headImageV:cell.rightUser corverImageV:cell.rightUser with:@(right.mid)];
    return cell;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    MyVideoModel *model = self.dataSource[section];
    static NSString *hIdentifier = @"hIdentifier";
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:hIdentifier];
    if(header == nil) {
        header = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:hIdentifier];
        UIImageView *corverImgV = [[UIImageView alloc]init];
        [corverImgV sd_setImageWithURL:[NSURL URLWithString:model.frontCover] placeholderImage:[UIImage imageNamed:@"00"] options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if ([imageURL isEqual:[NSURL URLWithString:model.frontCover]]) {
                corverImgV.image = image;
            }
        }];
        [header addSubview:corverImgV];
        [corverImgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(header).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        UIImageView *playImgV  = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"播放按钮"]];
        playImgV.userInteractionEnabled = YES;
        [corverImgV addSubview:playImgV];
        [playImgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(corverImgV);
            make.size.mas_equalTo(CGSizeMake(65, 65));
        }];
    }
    
    NSArray*subview = [header subviews];
    UIImageView* imgV = nil;
    for (id v in subview) {
        if ([v isKindOfClass:[UIImageView class]]) {
            imgV = (UIImageView *)v;
            break;
        }
    }
    if(imgV)
    {
        [imgV sd_setImageWithURL:[NSURL URLWithString:model.frontCover] placeholderImage:[UIImage imageNamed:@"00"] options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if ([imageURL isEqual:[NSURL URLWithString:model.frontCover]]) {
                imgV.image = image;
            }
        }];
    }
    
    return header;
    
//    UHVideosTableHeader *header = [[UHVideosTableHeader alloc]initWithReuseIdentifier:@"UHVideosTableHeader"];
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onPlayClick:)];
//    [header addGestureRecognizer:tap];
//   
//    MyVideoModel *model = self.dataSource[section];
//    header.videoUrl = model.m3u8SRC128K;
//    [header.corverImgV sd_setImageWithURL:[NSURL URLWithString:model.frontCover] placeholderImage:[UIImage imageNamed:@""] options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        if ([imageURL isEqual:[NSURL URLWithString:model.frontCover]]) {
//            header.corverImgV.image = image;
//        }
//    }];
//    return header;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return SCREEN_W;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MyVideoModel *model = self.dataSource[indexPath.section];
    PKModel *pk = model.versus[indexPath.row];
    PKDetailViewController *pdVC = [[PKDetailViewController alloc]initWithNibName:@"PKDetailViewController" bundle:nil];
    pdVC.pkId = pk.pkID;
    [self.navigationController pushViewController:pdVC animated:YES];
}
#pragma mark ---scrolView的代理
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate) {
    }else{
        [self dealHeader];
    }
    
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self dealHeader];
}
-(void)dealHeader
{
    if (self.header) {
        CGRect rc = [self.header.superview convertRect:self.header.frame toView:self.navigationController.view];
        NSLog(@"%@ %@",NSStringFromCGRect(self.header.frame),NSStringFromCGRect(rc) );
        if (rc.origin.y>64&&rc.origin.y<self.navigationController.view.bounds.size.height-self.navigationController.view.bounds.size.width) {
            if ([self.xywPlayer.playerUrl isEqualToString:self.header.videoUrl]) {
                if (self.header.autoPlay) {
                    [self.header addSubview:self.xywPlayer];
                }
            }else{
                [self wantPlay:NO];
            }
        }else{
            [self.xywPlayer resetPlayer];
            [self.xywPlayer removeFromSuperview];
        }
    }
}
-(void)onPlayClick:(UITapGestureRecognizer *)recognizer
{
    UHVideosTableHeader *header = (UHVideosTableHeader *)recognizer.view;
    if (self.header != header) {
        [self.xywPlayer resetPlayer];
        [self.xywPlayer removeFromSuperview];
        self.header = header;
    }
    [self wantPlay:YES];
//    [self.xywPlayer changUrl:self.header.videoUrl];
//    self.header.autoPlay = YES;
//    [self.header addSubview:self.xywPlayer];
}
-(void)playDidEnd:(UIView *)player
{
    self.header.autoPlay = NO;
    [player removeFromSuperview];
}
-(void)wantPlay:(BOOL)userPlay
{
    BOOL wifi = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi;
    if (wifi) {
        NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
        NSNumber *nb = [usf objectForKey:PLAYERAUTOPLAY];
        if ([usf objectForKey:KGuider]) {
            if (nb&&nb.integerValue==0) {//设置了Wi-Fi不自动播放
                if (userPlay) {
                    [self.xywPlayer changUrl:self.header.videoUrl];
                    self.header.autoPlay = YES;
                    [self.header addSubview:self.xywPlayer];
                    [self.header bringSubviewToFront:self.xywPlayer];
                }
                return;
            }else{
                [self.xywPlayer changUrl:self.header.videoUrl];
                self.header.autoPlay = YES;
                [self.header addSubview:self.xywPlayer];
                [self.header bringSubviewToFront:self.xywPlayer];
            }
        }
    }else{//流量
        NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
        NSNumber *playInMobile = [usf objectForKey:PLAYINMOBLIE];
        if (playInMobile) {//已经设置过了是否使用流量播放
            if (playInMobile.integerValue == 1) {//允许使用流量
                [self.xywPlayer changUrl:self.header.videoUrl];
                self.header.autoPlay = YES;
                [self.header addSubview:self.xywPlayer];
                [self.header bringSubviewToFront:self.xywPlayer];
            }else{//不允许使用流量
                CoreSVPCenterMsg(@"已拒绝使用流量播放，下次启动恢复");
                return;
            }
        }else{//需要询问是否允许使用流量播放
            [XYWAlert XYWAlertTitle:@"流量提醒" message:@"正在使用蜂窝移动数据，继续使用可能产生流量费用" first:@"继续使用" firstHandle:^{
                [self.xywPlayer changUrl:self.header.videoUrl];
                self.header.autoPlay = YES;
                [self.header addSubview:self.xywPlayer];
                [self.header bringSubviewToFront:self.xywPlayer];
                [usf setObject:@1 forKey:PLAYINMOBLIE];
                [usf synchronize];
            } second:nil Secondhandle:nil cancle:@"取消" handle:^{
                [usf setObject:@0 forKey:PLAYINMOBLIE];
                [usf synchronize];
            }];
        }
        
    }
}
@end
