//
//  UHVideosTableView.m
//  ZuoYou
//
//  Created by xueyongwei on 16/10/18.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "UHVideosTableView.h"
#import "UHVideosChallengeTableViewCell.h"

#import "ReviewMovieViewController.h"
#import "UploadVideoAlertView.h"
#import "FromMyvideosViewController.h"
#import "CaptureViewController.h"
@implementation UHVideosTableView
{
    NSInteger selectedSectionId;
    UploadVideoAlertView *alv;
}
-(UILabel *)noDataLabel
{
    if (!_noDataLabel) {
        _noDataLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_W/2-100, 100, 200, 21)];
        _noDataLabel.textAlignment = NSTextAlignmentCenter;
        _noDataLabel.text = @"还没有视频哦~";
        _noDataLabel.font = [UIFont systemFontOfSize:14];
        _noDataLabel.textColor = [UIColor colorWithHexColorString:@"999999"];
        [self customTbaleView];
    }
    return _noDataLabel;
}
-(XYWPlayer*)xywPlayer
{
    if (!_xywPlayer) {
        _xywPlayer = [[XYWPlayer alloc]initWithUrl:@"" frame:CGRectMake(0, 0, SCREEN_W, SCREEN_W) delegate:self];
        
    }
    return _xywPlayer;
}

-(void)viewWillDisappear:(BOOL)animated
{
    if (self.xywPlayer.superview) {
        [self.xywPlayer xywPause];
    }
}
-(void)prepareData
{
    self.currentPage = 1;
    self.dataSource = [NSMutableArray new];
    [self prepareData:1];
}
-(void)customTbaleView
{
    //    MJRefreshAutoStateFooter *footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
    //        [self prepareData:self.currentPage];
    //    }];
    //    [footer setTitle:@"" forState:MJRefreshStateIdle];
    //    self.tableView.mj_footer = footer;
    
    //    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
    //        [self prepareData:self.currentPage];
    //    }];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

-(void)prepareData:(NSInteger)page
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/video/list",HeadUrl];
    NSDictionary *param = @{@"mid":self.userID,@"pn":@(page)};
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
            if (self.dataSource.count<3 && [(NSArray *)result count]>0) {
                [self prepareData:self.currentPage];
            }
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
        [self.noDataLabel removeFromSuperview];
        [(MJRefreshAutoStateFooter*)self.tableView.mj_footer setTitle:@"别拉啦，全都给你啦～" forState:MJRefreshStateNoMoreData];
    }
    return self.dataSource.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    MyVideoModel *model = self.dataSource[section];
    return model.canChallenge?model.versus.count+1:model.versus.count;
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    NSLog(@"will %ld",(long)section);
    if (self.dataSource.count>2) {
        if ((float)section>= self.dataSource.count-2) {
            [self prepareData:self.currentPage];
        }
    }
}
//-(void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section
//{
//
//}
//-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//
//}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyVideoModel *model = self.dataSource[indexPath.section];
    if (model.canChallenge && indexPath.row==0) {//在第一行增加个挑战的索引
        UHVideosChallengeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UHVideosChallengeTableViewCell"];
        if (!cell) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"UHVideosChallengeTableViewCell" owner:self options:nil]lastObject];
            [cell.challengeBtn addTarget:self action:@selector(onPKWithVideo:) forControlEvents:UIControlEventTouchUpInside];
        }
        cell.challengeBtn.tag = indexPath.section;
        cell.tagName.text = model.formatertagName;
        cell.statusFLag.image = [UIImage imageNamed:@"待战角标"];
        return cell;
    }
    
    UHVideosTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"UHVideosTableViewCell" owner:self options:nil]lastObject];
        if (!cell) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"UHVideosChallengeTableViewCell" owner:self options:nil]lastObject];
        }
    }
    NSInteger idx = indexPath.row;
    if (model.canChallenge) {//第一行增是挑战的索引
        idx--;
    }
    PKModel *pk = model.versus[idx];
    contestantVideosModel *leftVideo = pk.contestantVideos.firstObject;
    contestantVideosModel *rightVideo = pk.contestantVideos.lastObject;
    cell.tagName.text = pk.formatertagName;
    NSString *winType = pk.winnerVersusContestantType;
    int pk_status = 0;
    NSArray *imageNames = @[@"进行角标",@"胜利角标",@"失败角标"];
    if (!winType|| winType.length == 0) {
        pk_status = 0;
    } else if ([winType isEqualToString:@"RED"]) {
        pk_status = model.mid == leftVideo.mid ? 1 : 2;
    } else if ([winType isEqualToString:@"BLUE"]) {
        pk_status = model.mid == rightVideo.mid ? 1 : 2;
    }
    
    NSString *imgName = imageNames[pk_status];
    contestantVideosModel *left = pk.contestantVideos.firstObject;
    contestantVideosModel *right = pk.contestantVideos.lastObject;
    cell.statusFLag.image = [UIImage imageNamed:imgName];
    [UserInfoManager setNameLabel:nil headImageV:cell.leftUser corverImageV:cell.leftCorver with:@(left.mid)];
    [UserInfoManager setNameLabel:nil headImageV:cell.rightUser corverImageV:cell.rightCorver with:@(right.mid)];
    //    [self setNameLabel:nil headImageV:cell.leftUser with:left.mid];
    //    [self setNameLabel:nil headImageV:cell.rightUser with:right.mid];
    return cell;
}
-(UHVideosTableHeader *)videoHeaderInTableViewHeaderFooter:(UITableViewHeaderFooterView *)hf
{
    for (UIView *contentView in hf.contentView.subviews) {
        if ([contentView isKindOfClass:[UHVideosTableHeader class]]) {
            return (UHVideosTableHeader *)contentView;
        }
    }
    return nil;
}
-(void)addVideoHeaderTo:(UITableViewHeaderFooterView *)hf
{
    UHVideosTableHeader *header = [[[NSBundle mainBundle]loadNibNamed:@"UHVideosTableHeader" owner:self options:nil]lastObject];
    
    [hf.contentView addSubview:header];
    [header mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.left.equalTo(hf.contentView);
    }];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onPlayClick:)];
    //    header.userInteractionEnabled = YES;
    [header addGestureRecognizer:tap];
    [header.failStateBtn addTarget:self action:@selector(onDealVideoClick:) forControlEvents:UIControlEventTouchUpInside];
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString * identy = @"headFootWithVideoHeader";
    UITableViewHeaderFooterView * hf = [tableView dequeueReusableHeaderFooterViewWithIdentifier:identy];
    if (!hf) {
        NSLog(@"%li",(long)section);
        hf = [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:identy];
        [self addVideoHeaderTo:hf];
    }
    
    UHVideosTableHeader *header = [self videoHeaderInTableViewHeaderFooter:hf];
    
    MyVideoModel *model = self.dataSource[section];
    header.failStateBtn.tag = model.videoID;
    if (self.header == header) {
        [self stopPlay];
    }
    header.tag = section;
    header.videoUrl = model.m3u8;
    [header.corverImgV sd_setImageWithURL:[NSURL URLWithString:model.frontCover] placeholderImage:[UIImage imageNamed:@"00"]];
    if (model.m3u8) {//有了地址
        header.videoState = personalVideoTypeDone;
    }else{
        DbLog(@"！！！！！没有完成的视频！");
        NSDateFormatter* formater = [[NSDateFormatter alloc] init];
        NSLocale* local =[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        [formater setLocale:local];
        [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate* createDate = [formater dateFromString:model.createdDate];
        if ([createDate moreThan:10]) {
            header.videoState = personalVideoTypeFail;
        }else{
            header.videoState = personalVideoTypeWaiting;
        }
    }
    return hf;
}
-(void)onDealVideoClick:(UIButton *)sender
{
    [XYWAlert XYWAlertTitle:@"删除该视频" message:nil first:@"删除" firstHandle:^{
        [self requestDelVideo:@(sender.tag)];
    } second:nil Secondhandle:nil cancle:@"取消" handle:nil];
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
    if (model.canChallenge && indexPath.row==0) {//第一行是个挑战的索引
        return;
    }
    NSInteger idx = indexPath.row;
    if (model.canChallenge) {//第一行增是挑战的索引
        idx--;
    }
    PKModel *pk = model.versus[idx];
    //    PKDetailViewController *pdVC = [[PKDetailViewController alloc]initWithNibName:@"PKDetailViewController" bundle:nil];
    //    pdVC.pkId = pk.pkID;
    self.block(@{@"action":@"push",@"class":@"PKDetailViewController",@"calssID":@(pk.pkID)});
    //    [self.vc.navigationController pushViewController:pdVC animated:YES];
}

#pragma mark ---scrolView的代理
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [super scrollViewDidScroll:scrollView];
    
    NSArray *visibleCellindexPaths = [self.tableView indexPathsForVisibleRows];
    DbLog(@"%@",visibleCellindexPaths);
    for (NSIndexPath *indexPath in visibleCellindexPaths) {
        UITableViewHeaderFooterView *hf = [self.tableView headerViewForSection:indexPath.section];
        UHVideosTableHeader *sectionHeader = [self videoHeaderInTableViewHeaderFooter:hf];
        CGRect rect = [self.tableView rectForHeaderInSection:indexPath.section];
        DbLog(@"section rect %@",NSStringFromCGRect(rect));
        CGRect rectInSuperview = [self.tableView convertRect:rect toView:[UIApplication sharedApplication].windows.lastObject];
        DbLog(@"section rect in self %@",NSStringFromCGRect(rectInSuperview));
        if (self.header && self.header == sectionHeader) {
            if (rectInSuperview.origin.y>130&&rectInSuperview.origin.y<250) {
                //还在播放呢
            }else{
                [self.xywPlayer resetPlayer];
                [self.xywPlayer removeFromSuperview];
            }
        }else{
            //不是在播放的那个section，不管
        }
        
    }
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate) {
    }else{
        [self dealHeader];
    }
}

-(void)stopPlay
{
    [self.xywPlayer resetPlayer];
    [self.xywPlayer removeFromSuperview];
}
-(void)play
{
    if (self.xywPlayer.superview) {
        [self.xywPlayer xywPlay];
    }
}
-(void)pause
{
    if (self.xywPlayer.superview) {
        [self.xywPlayer xywPlay];
    }
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self dealHeader];
}
-(void)dealHeader
{
    NSArray *visibleCellindexPaths = [self.tableView indexPathsForVisibleRows];
    DbLog(@"%@",visibleCellindexPaths);
    for (NSIndexPath *indexPath in visibleCellindexPaths) {
        CGRect rect = [self.tableView rectForHeaderInSection:indexPath.section];
        DbLog(@"section rect %@",NSStringFromCGRect(rect));
        CGRect rectInSuperview = [self.tableView convertRect:rect toView:[UIApplication sharedApplication].windows.lastObject];
        DbLog(@"section rect in self %@",NSStringFromCGRect(rectInSuperview));
        if (rectInSuperview.origin.y>130&&rectInSuperview.origin.y<250) {
            DbLog(@"there be!!!!!");
            UITableViewHeaderFooterView *hf = [self.tableView headerViewForSection:indexPath.section];
            self.header = [self videoHeaderInTableViewHeaderFooter:hf];
            if ([self.xywPlayer.playerUrl isEqualToString:self.header.videoUrl]) {
                if (self.header.autoPlay) {
                    [self.header addSubview:self.xywPlayer];
                }
            }else{
                [self wantPlay:NO];
            }
            break;
        }
    }
}
-(void)onPlayClick:(UITapGestureRecognizer *)recognizer
{
    UHVideosTableHeader *header = (UHVideosTableHeader *)recognizer.view;
    MyVideoModel *model = self.dataSource[recognizer.view.tag];
    if (model.m3u8) {
        if (self.header != header) {
            [self.xywPlayer resetPlayer];
            [self.xywPlayer removeFromSuperview];
            self.header = header;
        }
        [self wantPlay:YES];
    }else{
        CoreSVPCenterMsg(@"播放地址无效");
    }
    
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
-(void)requestDelVideo:(NSNumber *)videoID
{
    //    /v1/video/delete?id=
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@/video/delete",HeadUrl] parameters:@{@"id":videoID} inView:nil sucess:^(id result) {
        if ([result objectForKey:@"errCode"]) {
            CoreSVPCenterMsg([result objectForKey:@"errMsg"]);
        }else{
            CoreSVPCenterMsg([result objectForKey:@"msg"]);
            __weak typeof(self) wkSelf = self;
            [self.dataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                MyVideoModel *model = obj;
                if (model.videoID == videoID.integerValue) {
                    *stop = YES;
                    if (*stop == YES) {
                        [wkSelf.dataSource removeObjectAtIndex:idx];
                        [wkSelf.tableView reloadData];
                    }
                }
            }];
        }
    } failure:^(NSError *error) {
        
    }];
}

-(void)onPKWithVideo:(UIButton *)sender
{
    selectedSectionId = sender.tag;
    [self selecteFromPhotos];
    
    //    alv = [[[NSBundle mainBundle]loadNibNamed:@"UploadVideoAlertView" owner:self options:nil]lastObject];
    //    [alv.selecteFromPhotos addTarget:self action:@selector(selecteFromPhotos) forControlEvents:UIControlEventTouchUpInside];
    //    [alv.selecteFromPersonalPage addTarget:self action:@selector(selecteFromPersonalPage) forControlEvents:UIControlEventTouchUpInside];
    //    [alv show];
}
-(void)selecteFromPhotos
{
    CaptureVideoNavigationController *navCon = [[CaptureVideoNavigationController alloc] init];
    navCon.showStatusWhenDealloc = YES;
    CaptureViewController *captureViewCon = [[CaptureViewController alloc] initWithNibName:@"CaptureViewController" bundle:nil];
    
    MyVideoModel *model = self.dataSource[selectedSectionId];
    captureViewCon.contestantVideoId = @(model.videoID);
    captureViewCon.tagId = @(model.tagId);
    captureViewCon.challenge = @"true";
    captureViewCon.tagName = model.formatertagName;
    
    [navCon pushViewController:captureViewCon animated:YES];
    [[self getCurrentVC] presentViewController:navCon animated:YES completion:nil];
    
    //    [alv disMiss];
    //    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    //    picker.view.backgroundColor = [UIColor orangeColor];
    //    UIImagePickerControllerSourceType sourcheType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    //    picker.sourceType = sourcheType;
    //    picker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString*) kUTTypeMovie, (NSString*) kUTTypeVideo, nil];
    //    picker.delegate = self;
    //    picker.allowsEditing = YES;
    //    [[self getCurrentVC] presentViewController:picker animated:YES completion:nil];
    //    self.block(@{@"action":@"push",@"class":picker,@"calssID":@""});
}
-(void)selecteFromPersonalPage
{
    [alv disMiss];
    FromMyvideosViewController *fmVC = [FromMyvideosViewController new];
    MyVideoModel *model = self.dataSource[selectedSectionId];
    fmVC.contestantVideoId = [NSString stringWithFormat:@"%ld",(long)model.videoID];
    fmVC.uploadTagId =[NSString stringWithFormat:@"%ld",(long)model.tagId];
    fmVC.uploadTagName = model.formatertagName;
    fmVC.hidesBottomBarWhenPushed = YES;
    if ([[self getCurrentVC] isKindOfClass:[UINavigationController class]]) {
        [(UINavigationController *)([self getCurrentVC]) pushViewController:fmVC animated:YES];
    }else{
        [[self getCurrentVC].navigationController pushViewController:fmVC animated:YES];
    }
    //    [self.navigationController pushViewController:fmVC animated:YES];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSLog(@"%@",info);
    NSURL *MediaURL = [info objectForKey:@"UIImagePickerControllerMediaURL"];
    NSURL *referenceURL = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:referenceURL options:nil];
    
    //    NSURL *url = [info objectForKey:@"UIImagePickerControllerMediaURL"];
    //    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    
    float second = asset.duration.value/asset.duration.timescale;
    if (second<15 || second>180) {
        UIAlertView *shotrVideoalv = [[UIAlertView alloc]initWithTitle:@"请选择15秒~3分钟的视频参与PK" message:nil delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [shotrVideoalv show];
        [picker popViewControllerAnimated:YES];
        return;
    }
    
    [picker dismissViewControllerAnimated:YES completion:^{
        ReviewMovieViewController *rvc = [[ReviewMovieViewController alloc]initWithNibName:@"ReviewMovieViewController" bundle:nil];
        MyVideoModel *model = self.dataSource[selectedSectionId];
        rvc.contestantVideoId = @(model.videoID);
        rvc.uploadTagId = @(model.tagId);
        rvc.challenge = @"true";
        rvc.uploadTagName = model.formatertagName;
        rvc.ReferenceURL = referenceURL;
        rvc.movieUrl = MediaURL;
        rvc.hidesBottomBarWhenPushed = YES;
        UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:rvc];
        
        [[self getCurrentVC] presentViewController:navi animated:YES completion:nil];
    }];
}
- (UIViewController *)getCurrentVC{
    
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    //app默认windowLevel是UIWindowLevelNormal，如果不是，找到UIWindowLevelNormal的
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
    id  nextResponder = nil;
    UIViewController *appRootVC=window.rootViewController;
    //    如果是present上来的appRootVC.presentedViewController 不为nil
    if (appRootVC.presentedViewController) {
        nextResponder = appRootVC.presentedViewController;
    }else{
        UIView *frontView = [[window subviews] objectAtIndex:0];
        nextResponder = [frontView nextResponder]; //  这方法下面有详解
    }
    
    if ([nextResponder isKindOfClass:[UITabBarController class]]){
        UITabBarController * tabbar = (UITabBarController *)nextResponder;
        UINavigationController * nav = (UINavigationController *)tabbar.viewControllers[tabbar.selectedIndex];
        //        UINavigationController * nav = tabbar.selectedViewController ; 上下两种写法都行
        result=nav.childViewControllers.lastObject;
        
    }else if ([nextResponder isKindOfClass:[UINavigationController class]]){
        UIViewController * nav = (UIViewController *)nextResponder;
        result = nav.childViewControllers.lastObject;
    }else{
        result = nextResponder;
    }
    
    return result;
}


@end
