//
//  SetingViewController.m
//  ZuoYou
//
//  Created by xueyongwei on 16/9/29.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "SetingViewController.h"
#import "SetAutoPlayTableViewCell.h"
#import "SetCleanTableViewCell.h"
#import "SetNormalTableViewCell.h"
#import "YijianfankuiViewController.h"
#import "BlackListViewController.h"

#import "TalkingData.h"
#import "XloginAndShareManager.h"

#import "AppDelegate.h"
#import "HowLoginViewController.h"
#import "XYWAlert.h"
#import "SocketManager.h"
#import "XGPush.h"
@interface SetingViewController ()
@property (nonatomic,strong)SetCleanTableViewCell *CleanCell;
@end

@implementation SetingViewController
{
    UIButton *quxiaofenxiangBtn;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"设置";
    self.tableView.backgroundColor = [UIColor colorWithHexColorString:@"f4f4f4"];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(0.1,0,0,0);
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self calSIzeIn:self.CleanCell];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row ==0) {
        SetAutoPlayTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SetAutoPlayTableViewCell"];
        if (!cell) {
            cell =[[[NSBundle mainBundle]loadNibNamed:@"SetAutoPlayTableViewCell" owner:self options:nil]lastObject];
        }
        
        NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
        NSNumber *num = [usf objectForKey:PLAYERAUTOPLAY];
        if (num&&num.integerValue==0) {
            cell.autoSwitch.on = NO;
        }else{
            cell.autoSwitch.on = YES;
        }
        return cell;
    }else if (indexPath.row ==1){
        SetNormalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SetNormalTableViewCell"];
        if (!cell) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"SetNormalTableViewCell" owner:self options:nil]lastObject];
        }
        cell.nameLabel.text = @"分享App";
        return cell;
    }else if (indexPath.row ==2){
        SetCleanTableViewCell *cell= [tableView dequeueReusableCellWithIdentifier:@"SetCleanTableViewCell"];
        if (!cell) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"SetCleanTableViewCell" owner:self options:nil]lastObject];
        }
        self.CleanCell = cell;
        return cell;
    }
    else if (indexPath.row ==3){
        SetNormalTableViewCell *cell= [tableView dequeueReusableCellWithIdentifier:@"SetNormalTableViewCell"];
        if (!cell) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"SetNormalTableViewCell" owner:self options:nil]lastObject];
        }
        cell.nameLabel.text = @"意见反馈";
        return cell;
    }else{
        SetNormalTableViewCell *cell= [tableView dequeueReusableCellWithIdentifier:@"SetNormalTableViewCell"];
        if (!cell) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"SetNormalTableViewCell" owner:self options:nil]lastObject];
        }
        cell.nameLabel.text = @"黑名单";
        return cell;
    }
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_W, 8)];
    view.backgroundColor = [UIColor colorWithHexColorString:@"f4f4f4"];
    return view;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[[NSBundle mainBundle]loadNibNamed:@"SetingFooterView" owner:self options:nil]lastObject];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    self.versionLabel.text = [NSString stringWithFormat:@"V%@",appCurVersion] ;
    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 140;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 8;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row ==2) {
        self.CleanCell.sizeLabel.hidden = YES;
        self.CleanCell.waitView.hidden = NO;
        CoreSVPLoading(@"清理中...", NO);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self clerCache];
        });
        
    }else if (indexPath.row ==1){
        [self onShareAppCLick];
    }else if (indexPath.row ==3){
        YijianfankuiViewController *yfVC = [[YijianfankuiViewController alloc]initWithNibName:@"YijianfankuiViewController" bundle:nil];
        [self.navigationController pushViewController:yfVC animated:YES];
    }else if (indexPath.row ==4){
        BlackListViewController *blVC = [[BlackListViewController alloc]initWithStyle:UITableViewStylePlain];
        [self.navigationController pushViewController:blVC animated:YES];
    }
    
}
- (void)onShareAppCLick
{
    [TalkingDataGA onEvent:KFENXIANGAPP eventData:@{@"设置_分享APP":@(1)}];
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_W, SCREEN_H)];
    bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapShareEmpty:)];
    [bgView addGestureRecognizer:tap];
    [[UIApplication sharedApplication].keyWindow addSubview:bgView];
    //    [[UIApplication sharedApplication].windows.lastObject addSubview:bgView];
    
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
        UIButton *btnwx = [UIButton buttonWithType:UIButtonTypeCustom];
        btnwx.imageView.contentMode = UIViewContentModeScaleAspectFit;
        btnwx.frame = CGRectMake(i*SCREEN_W/4, 42+j*80, SCREEN_W/4, 71);
        [btnwx setImage:[UIImage imageNamed:@"分享微信"] forState:UIControlStateNormal];
        btnwx.tag = 100;
        [btnwx addTarget:self action:@selector(shareToWx:) forControlEvents:UIControlEventTouchDown];
        [shareBordView addSubview:btnwx];
        i++;
        UIButton *btnpyq = [UIButton buttonWithType:UIButtonTypeCustom];
        btnpyq.imageView.contentMode = UIViewContentModeScaleAspectFit;
        btnpyq.frame = CGRectMake(i*SCREEN_W/4, 42+j*80, SCREEN_W/4, 71);
        btnpyq.tag = 101;
        [btnpyq addTarget:self action:@selector(shareToWx:) forControlEvents:UIControlEventTouchDown];
        [btnpyq setImage:[UIImage imageNamed:@"分享朋友圈"] forState:UIControlStateNormal];
        [shareBordView addSubview:btnpyq];
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
    }];
    
    //    [sender.superview removeFromSuperview];
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
    }else{
        parm = @{@"to":@"pyq"};
    }
    [manager shareToWx:parm result:^(NSDictionary *userInfo) {
        if ([userInfo[@"shareState"] isEqualToString:@"sucess"]) {
            CoreSVPSuccess(@"分享成功");
            
        }
    }];
}

-(void)shareToWeibo
{
    [self onQuxiaoShareClick:nil];
    XloginAndShareManager *manager = [XloginAndShareManager defaultManager];
    manager.shareData = [self shareData];
    [manager shareToWb:nil result:^(NSDictionary *userInfo) {
        if ([userInfo[@"shareState"] isEqualToString:@"sucess"]) {
            CoreSVPSuccess(@"分享成功");
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
    }else{
        parm = @{@"to":@"qqzone"};
    }
    [manager shareToQQ:parm result:^(NSDictionary *userInfo) {
        if ([userInfo[@"shareState"] isEqualToString:@"sucess"]) {
            CoreSVPSuccess(@"分享成功");
            
        }
    }];
}
-(void)shareToCopyBoard
{
    [self onQuxiaoShareClick:nil];
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = [[self shareData] objectForKey:@"shareUrl"];
    CoreSVPCenterMsg(@"已复制到剪切板");
}
-(void)shareToMore
{
    [self onQuxiaoShareClick:nil];
    CoreSVPLoading(@"wait...", NO);
    UIActivityViewController * activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[[self shareData]]
                                                                                          applicationActivities:nil];
    [self presentViewController:activityViewController
                       animated:YES
                     completion:^{
                         [CoreSVP dismiss];
                     }];
}
-(void)onTapShareEmpty:(UITapGestureRecognizer *)recogizer
{
    [self onQuxiaoShareClick:nil];
    //    [recogizer.view removeFromSuperview];
}

#pragma mark ---手势点击等事件的handle
-(NSDictionary *)shareData
{
    //    self.shareData[@"shareUrl"]] title:self.shareData[@"shareTitle"] description:self.shareData[@"shareDesc"] previewImageURL: [NSURL URLWithString:self.shareData[@"shareImgUrl"]]];
    NSDictionary *dic = @{@"shareUrl":@"http://zuoyoupk.com",@"shareTitle":@"左右-视界任你左右！",@"shareDesc":@"全球首款短视频PK+创意变现app等你来战！",@"shareImg":[UIImage imageNamed:@"zuoyou180"],@"shareImgUrl":@"http://static.zuoyoupk.com/launcher/ic_launcher.png"};
    return dic;
}

-(void)tapEmptyWhileInput:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
}
-(void)clerCache
{
    
    [TalkingDataGA onEvent:KQINGCHUHUANCUN eventData:@{@"设置_清理缓存":@(1)}];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"设置"
                                                          action:@"点击清除缓存"
                                                           label:nil
                                                           value:@1] build]];
    //清理缓存目录
    [self cleanCachesAtPath:[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
    //清理拍摄的视频
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *videosPath = [documentPath stringByAppendingPathComponent:@"videos"];
    [self cleanCachesAtPath:videosPath];
    //清理sdwebimage缓存
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.CleanCell.sizeLabel.text = @"0M";
            self.CleanCell.sizeLabel.hidden = NO;
            self.CleanCell.waitView.hidden = YES;
            [CoreSVP dismiss];
            CoreSVPCenterMsg(@"清理完成");
        });
    }];
    
}
// 计算目录大小
- (CGFloat)folderSizeAtPath:(NSString *)path{
    // 利用NSFileManager实现对文件的管理
    NSFileManager *manager = [NSFileManager defaultManager];
    CGFloat size = 0;
    if ([manager fileExistsAtPath:path]) {
        // 获取该目录下的文件，计算其大小
        NSArray *childrenFile = [manager subpathsAtPath:path];
        for (NSString *fileName in childrenFile) {
            NSString *absolutePath = [path stringByAppendingPathComponent:fileName];
            size += [manager attributesOfItemAtPath:absolutePath error:nil].fileSize;
        }
        // 将大小转化为M
        return size / 1024.0 / 1024.0;
    }
    return 0;
}
// 根据路径删除文件
- (void)cleanCachesAtPath:(NSString *)path{
    // 利用NSFileManager实现对文件的管理
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        // 获取该路径下面的文件名
        NSArray *childrenFiles = [fileManager subpathsAtPath:path];
        for (NSString *fileName in childrenFiles) {
            // 拼接路径
            NSString *absolutePath = [path stringByAppendingPathComponent:fileName];
            // 将文件删除
            [fileManager removeItemAtPath:absolutePath error:nil];
        }
    }
}
-(void)calSIzeIn:(SetCleanTableViewCell *)cell
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGFloat temSize = [self folderSizeAtPath:[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
        CGFloat documentSize = [self folderSizeAtPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]stringByAppendingPathComponent:@"videos"]];
        CGFloat totalSize = temSize + documentSize;
        NSString *sizeStr = totalSize >50 ?@"大于50M":[NSString stringWithFormat:@"%.0fM",totalSize];
        DbLog(@"大小%@",sizeStr);
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.sizeLabel.text = sizeStr;
            cell.sizeLabel.hidden = NO;
            cell.waitView.hidden = YES;
        });
    });
    
}

- (IBAction)onLogOutClick:(UIButton *)sender {
    [XYWAlert XYWAlertTitle:@"确定退出登录？" message:nil first:@"确定" firstHandle:^{
        [TalkingDataGA onEvent:KTUICHUZHUANGHU eventData:@{@"设置_退出账户":@(1)}];
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"设置"
                                                              action:@"点击退出账户"
                                                               label:nil
                                                               value:@1] build]];
        [UserInfoManager cleanMyselfInfo];
        //清理是否已关注推荐用户
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"haveCaredStarUser"];
        
        [[SocketManager defaultManager] dropWS];
        [self changeRootView];
        [XGPush delAccount:^{
            DbLog(@"[XGDemo] Del account success");
        } errorCallback:^{
            DbLog(@"[XGDemo] Del account error");
        }];
    } second:nil Secondhandle:nil cancle:@"取消" handle:nil];
    
}
-(void)changeRootView
{
    [CoreSVP dismiss];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    HowLoginViewController *hlVC = [[UIStoryboard storyboardWithName:@"LoginStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"HowLoginViewController"];
    //修改rootVC
    [delegate.window addSubview:hlVC.view];
    [self.view removeFromSuperview];
    delegate.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:hlVC];
    [hlVC.navigationController setNavigationBarHidden:YES];
}




@end
