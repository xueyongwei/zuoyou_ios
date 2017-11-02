//
//  FromMyvideosViewController.m
//  ZuoYou
//
//  Created by xueyongwei on 16/11/7.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "FromMyvideosViewController.h"
#import "MyvideosCollectionViewCell.h"
#import "MyVideoModel.h"
//#import "AddDescViewController.h"
#import "ReviewMovieViewController.h"
@interface FromMyvideosViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic,strong)UICollectionView *collectionView;
@property (nonatomic,strong)NSMutableArray *dataSource;
@property (nonatomic,assign)NSInteger currentPage;
@end

@implementation FromMyvideosViewController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = [NSMutableArray new];
    self.navigationItem.title = @"我的视频";
    [self customCollections];
    // Do any additional setup after loading the view.
}

-(void)prepareData:(NSInteger)page
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/video/list",HeadUrl];
    NSDictionary *param = @{@"mid":[UserInfoManager mySelfInfoModel].mid,@"pn":@(page),@"challenge":@"true"};
    [XYWhttpManager XYWpost:urlStr parameters:param inView:nil sucess:^(id result) {
        DbLog(@"%@",result);
        
        if (page <= 1) {
            [self.collectionView.mj_header endRefreshing];
            if ([(NSArray *)result count]>0){
                [self.dataSource removeAllObjects];
            }
        }else{
            if ([(NSArray *)result count]>0) {
                [self.collectionView.mj_footer endRefreshing];
            }else{
                [self.collectionView.mj_footer endRefreshingWithNoMoreData];
                return ;
            }
        }
        if ([result isKindOfClass:[NSArray class]]) {
            
            for (NSDictionary *dic in (NSArray*)result) {
                MyVideoModel *model = [MyVideoModel mj_objectWithKeyValues:dic];
                [self.dataSource addObject:model];
            }
            [self.collectionView reloadData];
            
            self.currentPage ++;
//            if (self.dataSource.count<5 && self.collectionView.mj_footer.state!= MJRefreshStateNoMoreData) {
//                [self prepareData:self.currentPage];
//            }
        }
    } failure:^(NSError *error) {
        if (page <= 1) {
            [self.collectionView.mj_header endRefreshing];
        }else{
            [self.collectionView.mj_footer endRefreshing];
        }
    }];
}

-(void)customCollections
{
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.view);
    }];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"MyvideosCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"MyvideosCollectionViewCell"];
    self.automaticallyAdjustsScrollViewInsets = NO;
    __weak typeof(self) wkSelf = self;
    BangdanMjHeader *header = [BangdanMjHeader headerWithRefreshingBlock:^{
        wkSelf.currentPage = 1;
        [wkSelf prepareData:1];
    }];
    header.frame = CGRectMake(0, 0, SCREEN_W, 60);
    self.collectionView.mj_header = header;
    [header beginRefreshing];
    self.collectionView.mj_footer = [MJRefreshBackStateFooter footerWithRefreshingBlock:^{
       [wkSelf prepareData:self.currentPage];
    }];

}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = (SCREEN_W-15)/4;
    
    return (CGSize){width,width};
}


//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
//{
//    return UIEdgeInsetsMake(5, 5, 5, 5);
//}

//
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.f;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.f;
}

#pragma mark ---- UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return (CGSize){SCREEN_W,5};
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MyvideosCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"MyvideosCollectionViewCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor purpleColor];
    MyVideoModel *model = self.dataSource [indexPath.item];
    [cell.corverImgV sd_setImageWithURL:[NSURL URLWithString:model.frontCover] placeholderImage:[UIImage imageNamed:@"00"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if ([imageURL isEqual:[NSURL URLWithString:model.frontCover]]) {
            cell.corverImgV.image = image;
        }
    }];
    cell.timeLabel.text =[self timeStrWithDuration:model.durationSec];
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item+2>self.dataSource.count && self.collectionView.mj_footer.state != MJRefreshStateNoMoreData) {
        [self prepareData:self.currentPage];
    }
}


#pragma mark ---- UICollectionViewDelegate

//- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return YES;
//}
//
//// 点击高亮
//- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//}


// 选中某item
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
     MyVideoModel *model = self.dataSource [indexPath.item];
    ReviewMovieViewController *reVC = [[ReviewMovieViewController alloc]initWithNibName:@"ReviewMovieViewController" bundle:nil];
//    reVC.movieUrl = [NSURL URLWithString:model.m3u8SRC1M];
    [[UIImageView new] sd_setImageWithURL:[NSURL URLWithString:model.frontCover] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        reVC.corverImage = image;
    }];
    reVC.challenge = @"true";
    reVC.uploadTagId = @(self.uploadTagId.integerValue);
    reVC.uploadTagName = self.uploadTagName;
    reVC.videoId = [NSString stringWithFormat:@"%ld",model.videoID];
    reVC.contestantVideoId = @(self.contestantVideoId.integerValue);
    
    [self.navigationController pushViewController:reVC animated:YES];
    
//    AddDescViewController *adesc = [[AddDescViewController alloc]initWithNibName:@"AddDescViewController" bundle:nil];
//    adesc.moviePath = model.m3u8SRC1M;
//    [[UIImageView new] sd_setImageWithURL:[NSURL URLWithString:model.frontCover] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        adesc.corverImage = image;
//    }];
//    //从已有视频选择的，肯定是挑战别人
//    adesc.challenge = @"true";
//    adesc.uploadTagId = self.uploadTagId;
//    adesc.uploadTagName = self.uploadTagName;
//    adesc.videoId = [NSString stringWithFormat:@"%ld",model.videoID];
//    adesc.contestantVideoId = self.contestantVideoId;
//    [self.navigationController pushViewController:adesc animated:YES];
}
-(NSString *)timeStrWithDuration:(NSInteger)duration
{
    int m = (int)duration/60;
    int s = duration%60;
    return [NSString stringWithFormat:@"%02d:%02d",m,s];
}


@end
