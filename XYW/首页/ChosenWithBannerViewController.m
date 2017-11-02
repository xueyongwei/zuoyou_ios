//
//  ChosenWithBannerViewController.m
//  ZuoYou
//
//  Created by xueyognwei on 17/2/6.
//  Copyright © 2017年 xueyongwei. All rights reserved.
//

#import "ChosenWithBannerViewController.h"
#import "SDCycleScrollView.h"
#import "HtmlViewController.h"
#import "ZYHonCommonLayout.h"
#import "SuggestedFollowsHeaderView.h"
#import "SuggestedFollowsCollectionViewCell.h"
#import "ZYUserDefaultsManager.h"
#import "UHCenterViewController.h"
@interface BarnerModel:NSObject
@property (nonatomic,copy)NSString *image;
@property (nonatomic,copy)NSString *link;
@end
@implementation BarnerModel

@end

@interface ChosenWithBannerViewController ()<SDCycleScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,SuggestedFollowsHeaderViewDelegate,SuggestedFollowsCollectionViewCellDelegate>
@property (nonatomic,strong)NSMutableArray *barnerSource;
@property (nonatomic,strong)UICollectionView *collectionView;
@property (nonatomic,strong)SuggestedFollowsHeaderView *tableHaderView;
@property (nonatomic,strong)NSMutableArray *suggestedFollowSource;
@end

@implementation ChosenWithBannerViewController
-(NSMutableArray *)barnerSource
{
    if (!_barnerSource) {
        _barnerSource = [NSMutableArray new];
    }
    return _barnerSource;
}
-(NSMutableArray *)suggestedFollowSource
{
    if (!_suggestedFollowSource) {
        _suggestedFollowSource = [NSMutableArray new];
    }
    return _suggestedFollowSource;
}
-(SuggestedFollowsHeaderView *)tableHaderView
{
    if (!_tableHaderView) {
        _tableHaderView = [[[NSBundle mainBundle]loadNibNamed:@"SuggestedFollowsHeaderView" owner:self options:nil]lastObject];
        _collectionView = _tableHaderView.collectionView;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.allowsMultipleSelection = YES;
        
        [_collectionView registerNib:[UINib nibWithNibName:@"SuggestedFollowsCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"SuggestedFollowsCollectionViewCell"];
        _tableHaderView.delegate = self;
    }
    return _tableHaderView;
}
//-(UICollectionView *)collectionView
//{
//    if (!_collectionView) {
//        ZYHonCommonLayout *customLayout = [[ZYHonCommonLayout alloc] init]; // 自定义的布局对象
//        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:customLayout];
//        _collectionView.backgroundColor = [UIColor whiteColor];
//        _collectionView.dataSource = self;
//        _collectionView.delegate = self;
//        [self.view addSubview:_collectionView];
//        
//        // 注册cell、sectionHeader、sectionFooter
//        [_collectionView registerNib:[UINib nibWithNibName:@"SuggestedFollowsCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"SuggestedFollowsCollectionViewCell"];
////        [_collectionView registerClass:[SuggestedFollowsCollectionViewCell class] forCellWithReuseIdentifier:@"SuggestedFollowsCollectionViewCell"];
//    }
//    return _collectionView;
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self requestBannerData];
    MyselfInfoModel *my = [UserInfoManager mySelfInfoModel];
    if (my.createdDate) {
        NSDateFormatter* formater = [[NSDateFormatter alloc] init];
        NSLocale* local =[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        [formater setLocale:local];
        [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate* date = [formater dateFromString:my.createdDate];
        if (![date isPassDay:3]) {//不超过3天
            if (![ZYUserDefaultsManager isCareStarUser]) {//还未关注
                [self requreSrarUser];
            }
        }
    }
}
#pragma mark -Data
-(void)requestBannerData{
//    /v1/events/carsouselImg
    NSString *uri = [NSString stringWithFormat:@"%@/events/carsouselImg",HeadUrl];
    
    [XYWhttpManager XYWpost:uri parameters:nil inView:nil sucess:^(id result) {
        DbLog(@"%@",result);
        if ([result isKindOfClass:[NSDictionary class]] && result[@"errCode"]) {
            
        }else{
            NSArray *barners = result;
            if (barners && barners.count>0) {
                for (NSDictionary *barnerDic in barners) {
                    BarnerModel *barner = [BarnerModel mj_objectWithKeyValues:barnerDic];
                    [self.barnerSource addObject:barner];
                }
                [self addBanner];
            }
        }
    } failure:^(NSError *error) {
        CoreSVPCenterMsg(error.localizedDescription);
        DbLog(@"%@",error.localizedDescription);
    }];
}
-(void)requreSrarUser
{
    __weak typeof(self) wkSelf = self;
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@%@",HeadUrl,@"/users/recommend"] parameters:nil inView:nil sucess:^(id result) {
        [wkSelf.tableView.mj_header endRefreshing];
        DbLog(@"%@",result);
        if ([result isKindOfClass:[NSArray class]]) {
            [wkSelf.suggestedFollowSource removeAllObjects];
            
            for (NSDictionary *tag in result) {
                UserInfoModel *model = [UserInfoModel mj_objectWithKeyValues:tag];
                
                [wkSelf.suggestedFollowSource addObject:model];
            }
            [self.tableHaderView.collectionView reloadData];
            for (NSInteger i=0; i<self.suggestedFollowSource.count; i++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
                [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            }
//            [wkSelf.collectionView reloadData];
            [wkSelf.tableView reloadData];
        }
    } failure:^(NSError *error) {
        [wkSelf.tableView.mj_header endRefreshing];
    }];
}
#pragma mark -UI
-(void)addBanner
{
    NSMutableArray *imagesURLStrings = [NSMutableArray new];
    for (BarnerModel *barner in self.barnerSource) {
        [imagesURLStrings addObject:barner.image];
    }
    SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, SCREEN_W, SCREEN_W/3) delegate:self placeholderImage:[UIImage imageNamed:@"11"]];
    cycleScrollView.pageControlDotSize = CGSizeMake(10, 10);
    cycleScrollView.currentPageDotColor = [UIColor colorWithHexColorString:@"ff4a4b"];
    cycleScrollView.pageDotColor = [UIColor colorWithHexColorString:@"c1c1c1"];
    cycleScrollView.pageControlBottomOffset = -5;
    cycleScrollView.imageURLStringsGroup = imagesURLStrings;
    cycleScrollView.delegate = self;
    cycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleClassic;
    cycleScrollView.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.tableView.tableHeaderView = cycleScrollView;
}

#pragma mark - SDCycleScrollViewDelegate

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
//    NSString *msg = [NSString stringWithFormat:@"点击了第%ld张图片", (long)index+1];
    BarnerModel *barner = self.barnerSource[index];
    NSURL *url = [NSURL URLWithString:barner.link];
    if ([url.scheme isEqualToString:@"zuoyoupk"]) {
        [[UIApplication sharedApplication]openURL:url];
    }else{
        HtmlViewController *htmlVC = [[HtmlViewController alloc]init];
        htmlVC.url = barner.link;
        [self.navigationController pushViewController:htmlVC animated:YES];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.suggestedFollowSource.count>0) {
        
        return self.tableHaderView;
        
    }else{
        return [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0.1)];
    }
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.suggestedFollowSource.count>0) {
        return 130;
    }else{
        return 0.1;
    }
}
#pragma mark ---collectionView代理
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.suggestedFollowSource.count>0) {
        return 5;
    }else{
        return 0;
    }
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SuggestedFollowsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SuggestedFollowsCollectionViewCell" forIndexPath:indexPath];
    cell.delegate = self;
    
    UserInfoModel *model = self.suggestedFollowSource[indexPath.item];
    [UserInfoManager setNameLabel:nil headImageV:cell.userIconImageView memberRoul:YES with:@(model.mid)];
    
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.tableHaderView.careBtn.enabled = YES;
}
-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView.indexPathsForSelectedItems.count==0) {
        self.tableHaderView.careBtn.enabled =NO;
    }
    if (collectionView.indexPathsForSelectedItems.count ==1 && [collectionView.indexPathsForSelectedItems containsObject:indexPath]) {
        self.tableHaderView.careBtn.enabled =NO;
    }
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger width = (int)(collectionView.bounds.size.width/5);
    CGSize size = CGSizeMake(width, 110) ;
    return size;
}
//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
//{
//    return UIEdgeInsetsMake(0, 0, 0, 0);
//}
- (CGFloat) collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.1f;
}

#pragma mark -SuggestedFollowsHeaderViewDelegate
-(void)onCareClick
{
    NSMutableString *idsStr = [NSMutableString new];
    if (self.collectionView.indexPathsForSelectedItems.count==0) {
        
        return;
    }
    for (NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems) {
        UserInfoModel *user = self.suggestedFollowSource[indexPath.item];
        [idsStr appendString:[NSString stringWithFormat:@",%ld",(long)user.mid]];
    }
    [self requestToCareIdsStr:[idsStr substringFromIndex:1]];
    [self removeTableViewHeaderView];
}

-(void)onUserIconTap:(UITapGestureRecognizer *)recognizer
{
    NSInteger index = recognizer.view.tag;
//    UserInfoModel *model = self.suggestedFollowSource[index];
    UHCenterViewController *cv = [[UHCenterViewController alloc]init];
    cv.hidesBottomBarWhenPushed = YES;
    cv.mid = index;
    [self.navigationController pushViewController:cv animated:YES];
}
-(void)removeTableViewHeaderView
{
    [self.suggestedFollowSource removeAllObjects];
    [self.tableView reloadData];
    [ZYUserDefaultsManager setHaveCaredStarUser];
}
#pragma mark -request server
-(void)requestToCareIdsStr:(NSString *)ids
{
    DbLog(@"requestToCareIdsStr : %@",ids);
//    /v1/social/batchFollow?ids
    NSString *uri = [NSString stringWithFormat:@"%@/social/batchFollow",HeadUrl];
    NSDictionary *param = @{@"ids":ids};
    [XYWhttpManager XYWpost:uri parameters:param inView:nil sucess:^(id result) {
        DbLog(@"%@",result);
    } failure:^(NSError *error) {
        DbLog(@"%@",error.localizedDescription);
    }];
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
