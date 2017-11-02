//
//  ZhichiBisaiViewController.m
//  HDJ
//
//  Created by xueyongwei on 16/7/27.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "ZhichiBisaiViewController.h"
#import "AppDelegate.h"
@interface ZhichiBisaiViewController ()
@property (nonatomic,strong)NSMutableArray *dataSource;
@property (nonatomic,strong)UIView *noDataView;
@end

@implementation ZhichiBisaiViewController
{
    int currentPage;
}
#pragma mark ---懒加载
-(UIView *)noDataView
{
    if (!_noDataView) {
        _noDataView = [UIView new];
        _noDataView.frame = CGRectMake(0, 60, SCREEN_W, SCREEN_W);
//        _noDataView.center = self.tableView.center;
        
        UIImageView *imageView = [UIImageView new];
        imageView.frame = CGRectMake(0, 0, SCREEN_W/3, SCREEN_W/3);
        imageView.center = CGPointMake(SCREEN_W/2, SCREEN_W/2);
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = [UIImage imageNamed:@"懒豆图片"];
        [_noDataView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_W, 21)];
        label.text = @"送过礼物的PK会出现在这里哦";
        label.textAlignment = NSTextAlignmentCenter;
        label.center = CGPointMake(SCREEN_W/2, SCREEN_W/2+SCREEN_W/6);
        label.textColor = [UIColor colorWithHexColorString:@"999999"];
        [_noDataView addSubview:label];
        
        
    }
    return _noDataView;
}

-(NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [NSMutableArray new];
    }
    return _dataSource;
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self removeTimerObser];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self addTimerObser];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.title = @"支持的比赛";
    currentPage = 1;
    DbLog(@"我要 ");
    [self prepareData:currentPage];
    
    [self prepareTabelView];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"支持的赛事页面"];
    [self customNavi];
}
- (void)fitFrameForChildViewController:(UIViewController *)chileViewController{
    CGRect frame = self.view.frame;
    frame.origin.y = 0;
    chileViewController.view.frame = frame;
}
-(void)prepareTabelView
{
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = (SCREEN_W-26)/2+110;
    self.tableView.backgroundColor = [UIColor colorWithHexColorString:@"f4f4f4"];
    __weak typeof(self) wkSelf = self;
    BangdanMjHeader *header = [BangdanMjHeader headerWithRefreshingBlock:^{
        currentPage =1;
        [wkSelf prepareData:currentPage];
    }];
    header.frame = CGRectMake(0, 0, SCREEN_W, 60);
    self.tableView.mj_header = header;
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        DbLog(@"footer 我要 ");
        [wkSelf prepareData:currentPage];
    }];
}
-(void)prepareData:(int)page
{
    DbLog(@"发起请求");
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@%@",HeadUrl,@"/users/support"] parameters:@{@"pn":[NSString stringWithFormat:@"%d",page]} inView:nil sucess:^(id result) {
        if (page ==1) {
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer resetNoMoreData];
        }
        
        DbLog(@" response %@",result);
        if ([result isKindOfClass:[NSArray class]]) {
            
            NSArray *responseArr =(NSArray *)result;
            if (page >1) {
                if (responseArr.count==0) {
                    [self.tableView.mj_footer endRefreshingWithNoMoreData];
                }else{
                    [self.tableView.mj_footer endRefreshing];
                }
            }else{
                [self.dataSource removeAllObjects];
            }
            
            currentPage ++;
            for (NSDictionary *dic  in result) {
                DbLog(@"++添加数据");
                PKModel *model = [PKModel mj_objectWithKeyValues:dic];
                
                [self.dataSource addObject:model];
            }
            DbLog(@"%@",self.dataSource);
            [self.tableView reloadData];
            
        }else
        {
            if (page > 1) {
                [self.tableView.mj_footer endRefreshing];
            }
        }
        if (self.dataSource.count==0) {
            [self.tableView addSubview:self.noDataView];
        }else{
            [self.noDataView removeFromSuperview];
        }

    } failure:^(NSError *error) {
        
    }];
 
}
#pragma mark ---通知中心
- (void)addTimerObser{
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(timerEvent) name:GLOBLETIMER object:nil];
}
- (void)timerEvent {
    for (PKModel *model  in self.dataSource) {
        [model cutDown];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIME_CELL object:nil];
}

-(void)removeTimerObser{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
#pragma mark --tableView代理方法
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.dataSource.count;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VersusNormalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VersusNormalTableViewCell"];
    if (!cell) {
        DbLog(@"创建一个新的cell");
        cell = [[[NSBundle mainBundle]loadNibNamed:@"VersusNormalTableViewCell" owner:self options:nil]lastObject];
    }
        
        PKModel *pkmodel = self.dataSource[indexPath.row];
        if (pkmodel) {
            cell.dataModel = pkmodel;
        }
        cell.pkRightPKbtn.tag = indexPath.row;
        cell.pkLeftPKbtn.tag = indexPath.row;
        
//        contestantVideosModel *leftVideo = pkmodel.contestantVideos.firstObject;
//        NSInteger leftBens = leftVideo.goldBeans+leftVideo.redBeans;
//        contestantVideosModel *rightVideo = pkmodel.contestantVideos.lastObject;
//        NSInteger rightBens = rightVideo.goldBeans+rightVideo.redBeans;
//
//        //设置用户的昵称和头像
//        
//        [UserInfoManager setNameLabel:cell.pkLeftUserNameLabel headImageV:cell.pkLeftUserIconImgV with:@(leftVideo.mid)];
//        [UserInfoManager setNameLabel:cell.pkRightUserNameLabel headImageV:cell.pkRightUserIconImgV with:@(rightVideo.mid)];
//        
//        NSURL *leftImgUrl = [NSURL URLWithString:leftVideo.frontCover];
//        NSURL *rightImgUrl = [NSURL URLWithString:rightVideo.frontCover];
//        
//        [cell.leftVideoImg sd_setImageWithURL:leftImgUrl placeholderImage:[UIImage imageNamed:@"00"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//            if ([imageURL isEqual:leftImgUrl]) {
//                cell.leftImg = image;
//            }
//        }];
//        [cell.rightVIdeoImg sd_setImageWithURL:rightImgUrl placeholderImage:[UIImage imageNamed:@"00"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//            if ([imageURL isEqual:rightImgUrl]) {
//                cell.rightImg = image;
//            }
//        }];
        
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            //左边数量
//            cell.pkLeftUserBeansLabel.text = [NSString stringWithFormat:@"%ld",(long)leftBens];
//            //右边数量
//            cell.pkRightUserBeansLabel.text = [NSString stringWithFormat:@"%ld",(long)rightBens];
//            
//            //设置pk进度条
//            NSInteger total = leftBens+rightBens;
//            if (total==0) {
//                cell.pkprogress.percent = 0.5;
//            }else{
//                if (rightBens == 0){//
//                    cell.pkprogress.percent = 0.98;
//                }else{
//                    cell.pkprogress.percent = (float)leftBens/total;
//                }
//            }
//            cell.pkTitleLabel.text = pkmodel.tagName;
//            cell.timeLabel.text = [pkmodel currentTimeString];
//            //设置获胜获得金豆数
//            cell.huoshegnLabel.attributedText = pkmodel.huoshengText;
//            [cell updateWinType];
//        });
//        
//    });
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PKDetailViewController *detailV = [[PKDetailViewController alloc]initWithNibName:@"PKDetailViewController" bundle:nil];
    detailV.pkModel = self.dataSource[indexPath.row];
    
    [self.navigationController pushViewController:detailV animated:YES];
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
