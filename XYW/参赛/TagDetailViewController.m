//
//  TagDetailViewController.m
//  ZuoYou
//
//  Created by xueyongwei on 16/11/3.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "TagDetailViewController.h"
#import "VersusListViewController.h"
#import "VideoListViewController.h"
#import "ReviewMovieViewController.h"
#import "UploadVideoAlertView.h"
#import "FromMyvideosViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "CaptureViewController.h"
#import "SimultaneouslyGestureRecognizerTableView.h"

#import "TagDetailitmHeaderView.h"
#import "TagDetailDescTableViewCell.h"
#import "ValueChartsTableViewController.h"
#import "MarqueeLabel.h"
@interface tagActivity :NSObject
@property (nonatomic,copy)NSString *startDate;
@property (nonatomic,copy)NSString *endDate;
@property (nonatomic,copy)NSString *desc;
@property (nonatomic,copy)NSString *duration;

-(NSString *)timeText;
@end
@implementation tagActivity
-(NSString *)timeText{
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    NSLocale* local =[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    [formater setLocale:local];
    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //    NSDate* start = [formater dateFromString:self.startDate];
    NSDate* end = [formater dateFromString:self.endDate];
    if ([[NSDate date] laterDate:end]) {
        return @"该活动已结束，获胜场次将不再计入排行榜。";
    }
    return [NSString stringWithFormat:@"%@-%@",[self.startDate substringToIndex:8],[self.endDate substringToIndex:8]];
}
@end

@interface TagDetailViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet SimultaneouslyGestureRecognizerTableView *tableView;
@property (nonatomic,strong) UIButton *currentChildrenBtn;
@property (nonatomic,assign)BOOL canScroll;
@property (nonatomic,strong)tagActivity *activity;
@property (nonatomic,assign)CGFloat descHeight;
@property (nonatomic,strong) TagDetailDescTableViewCell *tagDescCell;
@property (nonatomic,strong) UITableViewCell *tagContentCell;
@property (nonatomic,strong)UIButton *currentItmBtn;
@property (nonatomic,strong) ZYTableViewController *currentVC;
@property (nonatomic,strong)MarqueeLabel *titleView;

@property (nonatomic, assign) BOOL isTopIsCanNotMoveTabView;
@property (nonatomic, assign) BOOL isTopIsCanNotMoveTabViewPre;

@end

@implementation TagDetailViewController
{
//    BOOL transiting;
//    
//    UploadVideoAlertView *alv;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.tableView.delegate = nil;
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.tableView.delegate = self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self customChildrenVC];
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //    self.navigationItem.title = [NSString stringWithFormat:@"#%@#",self.tagName];
    
    [self customTableView];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cancleLockNoti) name:@"tagDetailfatherCanScroll" object:nil];
    [self requestTagDetail];
}
-(void)requestTagDetail{
    //    /v1/tag/detail?id=
    NSString *uri = [NSString stringWithFormat:@"%@/tag/detail",HeadUrl];
    NSDictionary *param = @{@"id":self.tagID};
    [XYWhttpManager XYWpost:uri parameters:param inView:nil sucess:^(id result) {
        DbLog(@"%@",result);
        if (result[@"errCode"]) {
            
        }else{
            self.tagName = result[@"name"];
            //            self.navigationItem.title = [NSString stringWithFormat:@"#%@#",self.tagName];
            //            self.titleView.text = [NSString stringWithFormat:@"#%@#",self.tagName];
            if (result[@"activity"]) {
                tagActivity *activity = [tagActivity mj_objectWithKeyValues:result[@"activity"]];
                self.activity = activity;
                [self customNavi];
                
                [self.tableView reloadData];
            }
        }
    } failure:^(NSError *error) {
        CoreSVPCenterMsg(error.localizedDescription);
        DbLog(@"%@",error.localizedDescription);
    }];
}
-(void)refreshData{
    if ([self.currentVC respondsToSelector:@selector(refreshData:)]) {
        [self.currentVC refreshData:^{
            [self.tableView.mj_header endRefreshing];
        }];
    }
}
-(void)customTableView{
    self.canScroll = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = SCREEN_W;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    //    __weak typeof(self) wkSelf = self;
    
    BangdanMjHeader *header = [BangdanMjHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    //    BangdanMjHeader *header = [BangdanMjHeader headerWithRefreshingBlock:^{
    //        if ([wkSelf.currentVC respondsToSelector:@selector(refreshData:)]) {
    //            [wkSelf.currentVC refreshData:^{
    //                [header endRefreshing];
    //            }];
    //        }
    //    }];
    self.tableView.mj_header = header;
}

-(void)cancleLockNoti{
    //    self.tableView.scrollEnabled = YES;
    self.canScroll = YES;
    self.tableView.showsVerticalScrollIndicator = YES;
}
-(void)customNavi
{
    [super customNavi];
//    MarqueeLabel *label = [[MarqueeLabel alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width-120, 44)];
    MarqueeLabel *label = [[MarqueeLabel alloc]initWithFrame:CGRectMake(0, 0, 120, 44)];
    label.marqueeType = MLLeftRight;
    label.rate = 60.0f;
    label.fadeLength = 10.0f;
    label.leadingBuffer = 0.0f;
    label.trailingBuffer = 44;
    label.textAlignment = NSTextAlignmentCenter;
    self.tagName = [self.tagName stringByReplacingOccurrencesOfString:@"#" withString:@""];
    label.text = [NSString stringWithFormat:@"#%@#",self.tagName];
    self.navigationItem.titleView = label;
    self.titleView = label;
    
    if (self.activity) {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -3;
        //右上角上传按钮
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        btn.frame = CGRectMake(0, 0, 44, 44);
        [btn addTarget:self action:@selector(onRankingClick:) forControlEvents:UIControlEventTouchDown];
        [btn setImage:[UIImage imageNamed:@"榜单icon"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"榜单icon-click"] forState:UIControlStateHighlighted];
        
        //    [btn setImage:[UIImage imageNamed:@"上传"] forState:UIControlStateNormal];
        //    [btn setImage:[UIImage imageNamed:@"上传"] forState:UIControlStateHighlighted];
        UIBarButtonItem *itm = [[UIBarButtonItem alloc]initWithCustomView:btn];
        self.navigationItem.rightBarButtonItems = @[negativeSpacer,itm];
    }else{
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -3;
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        btn.frame = CGRectMake(0, 0, 44, 44);
        btn.userInteractionEnabled = NO;
//        [btn addTarget:self action:@selector(onRankingClick:) forControlEvents:UIControlEventTouchDown];
//        [btn setImage:[UIImage imageNamed:@"榜单icon"] forState:UIControlStateNormal];
//        [btn setImage:[UIImage imageNamed:@"榜单icon-click"] forState:UIControlStateHighlighted];
        
        //    [btn setImage:[UIImage imageNamed:@"上传"] forState:UIControlStateNormal];
        //    [btn setImage:[UIImage imageNamed:@"上传"] forState:UIControlStateHighlighted];
        UIBarButtonItem *itm = [[UIBarButtonItem alloc]initWithCustomView:btn];
        self.navigationItem.rightBarButtonItems = @[negativeSpacer,itm];
    }
    
    
}
-(void)onRankingClick:(UIButton *)sender{
    ValueChartsTableViewController *valChartsVC = [[ValueChartsTableViewController alloc]initWithStyle:UITableViewStylePlain];
    valChartsVC.chartsType = ChartsTypePraise_activity_rank;
    valChartsVC.tagId = self.tagID.integerValue;
    valChartsVC.title = @"获胜排行榜";
    [self.navigationController pushViewController:valChartsVC animated:YES];
}
-(void)customChildrenVC
{
    //热战区
    VersusListViewController *rzVC = [[VersusListViewController alloc]initWithStyle:UITableViewStylePlain];
    rzVC.shouldCareWhetherCanScroll = YES;
    rzVC.requestURL = [NSString stringWithFormat:@"/versus/search?tagId=%@&stage=start",self.tagID];
    rzVC.noMoreDataMessage = @"暂时没有正在进行中的PK";
    rzVC.noMoreDataPage = YES;
    //    rzVC.view.frame = self.view.bounds;
    [self addChildViewController:rzVC];
    //挑战区
    VideoListViewController *tzVC = [[VideoListViewController alloc]initWithStyle:UITableViewStylePlain];
    tzVC.shouldCareWhetherCanScroll = YES;
    //    tzVC.view.frame = self.view.bounds;
    tzVC.tagID = self.tagID;
    tzVC.tagName = self.tagName;
    [self addChildViewController:tzVC];
    //已结束
    VersusListViewController *jsVC = [[VersusListViewController alloc]initWithStyle:UITableViewStylePlain];
    jsVC.shouldCareWhetherCanScroll = YES;
    jsVC.requestURL = [NSString stringWithFormat:@"/versus/search?tagId=%@&stage=end",self.tagID];
    jsVC.noMoreDataMessage = @"暂时没有已经结束的PK";
    
    //    dmVC.view.frame = self.view.bounds;
    [self addChildViewController:jsVC];
    
    //    [self.view addSubview:rzVC.view];
    //    [rzVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.top.equalTo(self.tagsView.mas_bottom);
    //        make.left.equalTo(self.view.mas_left);
    //        make.right.equalTo(self.view.mas_right);
    //        make.bottom.equalTo(self.view.mas_bottom);
    //    }];
    
    self.currentVC = rzVC;
}
- (IBAction)onTagIemCLick:(UIButton *)sender {
    if (sender == self.currentItmBtn) {
        return;
    }
    self.currentItmBtn.selected = NO;
    sender.selected = YES;
    self.currentItmBtn = sender;
    [self changeChildrenVC:sender.tag-100];
    //    self.currentVC = self.childViewControllers[sender.tag-100];
    //    [self.tableView reloadData];
}
//
//-(void)addVersusListView
//{
//    VersusListViewController *listView = [[VersusListViewController alloc]initWithStyle:UITableViewStylePlain];
//    listView.requestURL = @"/events/choice";
//    [self addChildViewController:listView];
//    [self.view addSubview:listView.view];
//    [listView.view mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.tagsView.mas_bottom);
//        make.left.equalTo(self.view.mas_left);
//        make.right.equalTo(self.view.mas_right);
//        make.bottom.equalTo(self.view.mas_bottom);
//    }];
//    
//}
- (IBAction)onUploadVideoClick:(UIButton *)sender {
    [self selecteFromPhotos];
}
-(void)onUploadVideo:(UIButton *)sender
{
    [self selecteFromPhotos];
    
}
-(void)selecteFromPhotos
{
    CaptureVideoNavigationController *navCon = [[CaptureVideoNavigationController alloc] init];
    navCon.showStatusWhenDealloc = YES;
    CaptureViewController *captureViewCon = [[CaptureViewController alloc] initWithNibName:@"CaptureViewController" bundle:nil];
    captureViewCon.challenge = @"false";
    captureViewCon.tagId = self.tagID;
    captureViewCon.tagName = [NSString stringWithFormat:@"#%@#",self.tagName];
    [navCon pushViewController:captureViewCon animated:YES];
    [self presentViewController:navCon animated:YES completion:nil];}
//-(void)selecteFromPersonalPage
//{
//    [alv disMiss];
//    FromMyvideosViewController *fmVC = [FromMyvideosViewController new];
//    fmVC.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:fmVC animated:YES];
//}
//- (IBAction)onTagBtnClick:(UIButton *)sender {
//    self.currentChildrenBtn.selected = NO;
//    sender.selected = YES;
//    self.currentChildrenBtn = sender;
//    [self changeToVC:sender.tag-100];
//}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section ==0) {
        return self.activity?1:0;
    }
    return 1;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section ==0) {
        UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"emptyHeader"];
        if (!view) {
            view = [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:@"emptyHeader"];
            view.frame =CGRectMake(0, 0, 0, 0.1);
        }
        return view;
    }else{
        UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"itemHeader"];
        if (!view) {
            view = [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:@"itemHeader"];
            TagDetailitmHeaderView *tagitemHeader = [[[NSBundle mainBundle]loadNibNamed:@"TagDetailitmHeaderView" owner:self options:nil]lastObject];
            [view addSubview:tagitemHeader];
            [tagitemHeader mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.right.bottom.left.equalTo(tagitemHeader.superview);
            }];
            self.currentItmBtn = tagitemHeader.rzBtn;
        }
        return view;
        
        //        UIView *view =[[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
        //        view.backgroundColor = [UIColor redColor];
        //        return view;
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section ==0) {
        TagDetailDescTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TagDetailDescTableViewCell"];
        if (!cell) {
            cell =[[[NSBundle mainBundle]loadNibNamed:@"TagDetailDescTableViewCell" owner:self options:nil]lastObject];
            self.tagDescCell = cell;
        }
        cell.contentLabel.text = self.activity.desc;
        cell.timeLabel.text = self.activity.duration;
        return cell;
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contentCellID"];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"contentCellID"];
            DbLog(@"children %@",self.childViewControllers);
            [cell.contentView addSubview:self.currentVC.view];
            //            UIView *vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
            //            vi.backgroundColor = [UIColor greenColor];
            //            [cell.contentView addSubview:vi];
            [self.currentVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.right.bottom.left.equalTo(self.currentVC.view.superview);
                //                make.top.equalTo(self.currentVC.view.superview.mas_bottom);
                //                make.left.equalTo(cell.contentView.mas_left);
                //                make.right.equalTo(cell.contentView.mas_right);
                //                make.bottom.equalTo(cell.contentView.mas_bottom);
            }];
            self.tagContentCell = cell;
        }
        return cell;
    }
}

//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.section ==0) {
//        return 68+12;;
//    }else{
//        return [UIScreen mainScreen].bounds.size.height-114;
//    }
////    return indexPath.section ==0?100:[UIScreen mainScreen].bounds.size.height-114;
//}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize labelSize =  [self.tagDescCell.contentLabel sizeThatFits:CGSizeMake(SCREEN_W, CGFLOAT_MAX)];
    DbLog(@"UILayoutFittingCompressedSize %@",NSStringFromCGSize(labelSize));
    CGFloat height=  [self.tagDescCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height +labelSize.height ;
    //    CGFloat timeLabelH =  [self.tagDescCell.timeLabel systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height+1;
    //    self.tagDescCell.timeLabelHeightConst.constant = timeLabelH;
    if (indexPath.section ==0) {
        return height;
    }else{
        return [UIScreen mainScreen].bounds.size.height-114;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section ==0) {
        return 0.1;
    }
    return 50;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //    CGFloat height = [self.tagDescCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 1;
    
    CGSize labelSize =  [self.tagDescCell.contentLabel sizeThatFits:CGSizeMake(SCREEN_W, CGFLOAT_MAX)];
    DbLog(@"UILayoutFittingCompressedSize %@",NSStringFromCGSize(labelSize));
    CGFloat height=  [self.tagDescCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height +labelSize.height+[self.tagDescCell.timeLabel systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    //    150-44;
    //    [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    CGFloat offsetY = scrollView.contentOffset.y;
    DbLog(@" offsetY =%f  height = %f",offsetY,height);
    
    if (offsetY>=height) {
        scrollView.contentOffset = CGPointMake(0, height);
        _isTopIsCanNotMoveTabView = YES;
        DbLog(@"_isTopIsCanNotMoveTabView = YES");
    }else{
        _isTopIsCanNotMoveTabView = NO;
        DbLog(@"_isTopIsCanNotMoveTabView = NO");
    }
    if (!_canScroll) {
        self.tableView.contentOffset = CGPointMake(0, height);
    }
    if (_isTopIsCanNotMoveTabView != _isTopIsCanNotMoveTabViewPre) {
        if (!_isTopIsCanNotMoveTabViewPre && _isTopIsCanNotMoveTabView) {
            DbLog(@"滑动到顶端");
            self.canScroll = NO;
            self.tableView.showsVerticalScrollIndicator = NO;
            [[NSNotificationCenter defaultCenter]postNotificationName:@"tagDetailVCchildrenCanScroll" object:nil];
        }
    }

//    
//    if (!self.canScroll) {
//        if (offsetY!=height) {
//            [scrollView setContentOffset:CGPointMake(0, height)];
//        }
//    }
//    
//    if (offsetY>height && self.canScroll) {
//        self.canScroll = NO;
//        self.tableView.showsVerticalScrollIndicator = NO;
//        [[NSNotificationCenter defaultCenter]postNotificationName:@"tagDetailVCchildrenCanScroll" object:nil];
//    }
}
-(void)changeChildrenVC:(NSInteger)idx{
    [self.currentVC.view removeFromSuperview];
//    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"contentCellID"];
    self.currentVC = self.childViewControllers[idx];
    [self.tagContentCell.contentView addSubview:self.currentVC.view];
    [self.currentVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.left.equalTo(self.currentVC.view.superview);
    }];
}
//-(void)changeToVC:(NSInteger)idx
//{
//    UIViewController *nxtVC = [self.childViewControllers objectAtIndex:idx];
//    if (transiting||(self.currentVC == nxtVC)) {
//        return;
//    }
//    transiting = YES;
//    [self transitionFromViewController:self.currentVC toViewController:nxtVC duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
//        
//    } completion:^(BOOL finished) {
//        if (finished) {
//            [nxtVC didMoveToParentViewController:self];
//            [self.currentVC willMoveToParentViewController:nil];
//            transiting = NO;
//            self.currentVC = nxtVC;
//            [self.currentVC.view mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.top.equalTo(self.tagsView.mas_bottom);
//                make.left.equalTo(self.view.mas_left);
//                make.right.equalTo(self.view.mas_right);
//                make.bottom.equalTo(self.view.mas_bottom);
//            }];
//        }else{
//            
//        }
//    }];
//    
//}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    self.tableView = nil;
//    [self.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        [obj removeFromParentViewController];
//    }];
    DbLog(@"tagDetail释放了！");
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
