//
//  MatchViewController.m
//  ZuoYou
//
//  Created by xueyongwei on 16/11/3.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "MatchViewController.h"
#import "SearchTagUserViewController.h"
#import "YYText.h"
#import "YYLabel.h"
#import "tagModel.h"
#import "HotTagTableViewCell.h"
#import "TagNormalTableViewCell.h"
//#import "StarUserTableViewCell.h"
#import "StarUsersTableViewCell.h"
//#import "TagDetailViewController.h"
#import "TagDetailViewController.h"
#import "StarUserIconNameCollectionViewCell.h"
#import "ItmHeaderView.h"
#import "UHCenterViewController.h"

@interface MatchViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic,strong)UICollectionView *collectionView;
@property (nonatomic,assign)NSInteger dataReadyCount;
@end

@implementation MatchViewController
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.navigationController) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.navigationController) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    for (int i = 0; i<3; i++) {//三个分组，三个素组
        NSMutableArray *arr = [NSMutableArray new];
        [self.dataSource addObject:arr];
    }
    [self customTableView];
    //自定义导航栏可手势返回
    if (self.navigationController) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}
-(void)customTableView
{
    self.dataReadyCount = 0;
    [self prepareData];
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_W, 7.5)];
    self.tableView.tableHeaderView  = headerView;
}
-(void)prepareData
{
    //明星用户
    [self requreSrarUser:NO];
    //最热话题
    [self requreHotTag:NO];
    //最新话题
    [self requreNewTag];
}
-(void)requreSrarUser:(BOOL)animation
{
    __weak typeof(self) wkSelf = self;
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@%@",HeadUrl,@"/users/recommend"] parameters:nil inView:nil sucess:^(id result) {
        [wkSelf.tableView.mj_header endRefreshing];
        DbLog(@"%@",result);
        if ([result isKindOfClass:[NSArray class]]) {
            NSMutableArray *starUserArr = wkSelf.dataSource[0];
            [starUserArr removeAllObjects];
            for (NSDictionary *tag in result) {
                UserInfoModel *model = [UserInfoModel mj_objectWithKeyValues:tag];
                [starUserArr addObject:model];
            }
            if (animation) {
                [wkSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
            }else{
                self.dataReadyCount ++;
                if (self.dataReadyCount ==wkSelf.dataSource.count) {
                    [wkSelf.tableView reloadData];
                }
            }
        }
    } failure:^(NSError *error) {
        [wkSelf.tableView.mj_header endRefreshing];
    }];
}
-(void)requreHotTag:(BOOL)animation
{
    __weak typeof(self) wkSelf = self;
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@%@",HeadUrl,@"/tag/choice"] parameters:nil inView:nil sucess:^(id result) {
        [wkSelf.tableView.mj_header endRefreshing];
        DbLog(@"%@",result);
        if ([result isKindOfClass:[NSArray class]]) {
            NSMutableArray *hotTagArr = wkSelf.dataSource[1];
            [hotTagArr removeAllObjects];
            for (NSDictionary *tag in result) {
                tagModel *model = [tagModel mj_objectWithKeyValues:tag];
                [hotTagArr addObject:model];
            }
            self.dataReadyCount ++;
            if (self.dataReadyCount ==wkSelf.dataSource.count) {
                [wkSelf.tableView reloadData];
            }
        }
    } failure:^(NSError *error) {
        [wkSelf.tableView.mj_header endRefreshing];
    }];
}
-(void)requreNewTag
{
    __weak typeof(self) wkSelf = self;
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@%@",HeadUrl,@"/tag/newest"] parameters:nil inView:nil sucess:^(id result) {
        [wkSelf.tableView.mj_header endRefreshing];
        DbLog(@"%@",result);
        if ([result isKindOfClass:[NSArray class]]) {
            NSMutableArray *hotTagArr = wkSelf.dataSource[2];
            [hotTagArr removeAllObjects];
            for (NSDictionary *tag in result) {
                tagModel *model = [tagModel mj_objectWithKeyValues:tag];
                [hotTagArr addObject:model];
            }
            self.dataReadyCount ++;
            if (self.dataReadyCount ==wkSelf.dataSource.count) {
                [wkSelf.tableView reloadData];
            }
        }
    } failure:^(NSError *error) {
        [wkSelf.tableView.mj_header endRefreshing];
    }];
}
#pragma mark tableView代理方法
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return 1;
    }
    return [self.dataSource[section] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            StarUsersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StarUsersTableViewCell"];
            if (!cell) {
                cell = [[[NSBundle mainBundle]loadNibNamed:@"StarUsersTableViewCell" owner:self options:nil]lastObject];
                cell.collectionView.dataSource = self;
                cell.collectionView.delegate = self;
                [cell.collectionView registerNib:[UINib nibWithNibName:@"StarUserIconNameCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"StarUserIconNameCollectionViewCell"];
                self.collectionView = cell.collectionView;
            }
            [cell.collectionView reloadData];
            return cell;
        }
            break;
        case 1:
        {
            HotTagTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HotTagTableViewCell"];
            if (!cell) {
                cell =[[[NSBundle mainBundle]loadNibNamed:@"HotTagTableViewCell" owner:self options:nil]lastObject];
            }
            tagModel *model = self.dataSource[indexPath.section][indexPath.row];
            if (model.activity) {
                cell.tagNameLabel.attributedText = [self attributedTagName:model.formatertagName];
            }else{
                cell.tagNameLabel.text = model.formatertagName;
            }
            
            [cell.TagThumbImageView sd_setImageWithURL:[NSURL URLWithString:model.frontCover] placeholderImage:[UIImage imageNamed:@"00"]];
            return cell;
        }
            break;
        case 2:
        {
            tagModel *model = self.dataSource[indexPath.section][indexPath.row];
            TagNormalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TagNormalTableViewCell"];
            if (!cell) {
                cell = [[[NSBundle mainBundle]loadNibNamed:@"TagNormalTableViewCell" owner:self options:nil]lastObject];
            }
            if (model.activity) {
                cell.tagNameLabel.attributedText = [self attributedTagName:model.formatertagName];
            }else{
                cell.tagNameLabel.text = model.formatertagName;
            }
//            cell.tagNameLabel.text = model.formatertagName;
            return cell;
        }
            break;
        default:
            break;
    }
    return nil;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *hf = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"matchHf"];
    ItmHeaderView *headerView = hf.contentView.subviews.firstObject;;
    if (!hf) {
        hf = [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:@"matchHf"];
        headerView = [[[NSBundle mainBundle]loadNibNamed:@"ItmHeaderView" owner:self options:nil]lastObject];
        [hf.contentView addSubview:headerView];
        hf.backgroundColor = [UIColor whiteColor];
        headerView.backgroundColor = [UIColor whiteColor];
        [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.bottom.equalTo(hf.contentView);
        }];
        [headerView.rightBtn setImage:[UIImage loadImageNamed:@"刷新btn"] forState:UIControlStateNormal];
        [headerView.rightBtn setTitle:@" 换一换" forState:UIControlStateNormal];
        [headerView.rightBtn.titleLabel setFont:[UIFont systemFontOfSize:11]];
        [headerView.rightBtn addTarget:self action:@selector(onChangeStarUser:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    headerView.rightBtn.hidden = section!=0;
    headerView.headerLabel.text = section==0?@"明星用户":(section==1?@"最热话题":@"最新话题");
    return hf;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc]initWithFrame:CGRectZero];
}
- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor colorWithHexColorString:@"f4f4f4"];
}
-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    view.backgroundColor = [UIColor whiteColor];
    view.tintColor = [UIColor whiteColor];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return;
    }
    NSArray *tags = self.dataSource[indexPath.section];
    tagModel *model = tags[indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TagDetailViewController *tgDetailVC = [[TagDetailViewController alloc]initWithNibName:@"TagDetailViewController" bundle:nil];
    tgDetailVC.tagID = model.tagID;
    tgDetailVC.tagName = model.formatertagName;
    tgDetailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:tgDetailVC animated:YES];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 85;
            break;
        case 1:
            return 55;
            break;
        case 2:
            return 40;
            break;
    }
    return 44;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section ==2) {
        return 0.1;
    }
    return 7.5;
}

#pragma mark ---collectionView代理
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dataSource[section] count];
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    StarUserIconNameCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"StarUserIconNameCollectionViewCell" forIndexPath:indexPath];
    NSArray *users = self.dataSource[0];
    UserInfoModel *model = users[indexPath.item];
    [UserInfoManager setNameLabel:cell.userNameLabel headImageV:cell.userIcon corverImageV:cell.corverImgV with:@(model.mid)];
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *users = self.dataSource[0];
    UserInfoModel *user = users[indexPath.item];
    UHCenterViewController *uc = [[UHCenterViewController alloc]init];
    uc.mid = user.mid;
    uc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:uc animated:YES];
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger width = (int)(collectionView.bounds.size.width/5+0.5);
    CGSize size = CGSizeMake(width, 85) ;
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
#pragma mark 绘制界面
-(void)customNavi
{
    [super customNavi];
    YYLabel *searchLabel = [[YYLabel alloc]initWithFrame:CGRectMake(13, 0, SCREEN_W-26, 30)];
    searchLabel.layer.borderWidth = SINGLE_LINE_WIDTH;
    searchLabel.layer.borderColor = [UIColor redColor].CGColor;
    
    UIFont *font =[UIFont systemFontOfSize:15];
    
    NSMutableAttributedString *searchPlaceHold = [NSMutableAttributedString new];
    UIImage *image = [UIImage imageNamed:@"搜索icon"];
    image = [UIImage imageWithCGImage:image.CGImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    NSMutableAttributedString *imgContent = [NSMutableAttributedString yy_attachmentStringWithContent:image contentMode:UIViewContentModeScaleAspectFit attachmentSize:CGSizeMake(15, 15) alignToFont:font alignment:YYTextVerticalAlignmentCenter];
    [searchPlaceHold appendAttributedString:imgContent];
    [searchPlaceHold appendAttributedString:[[NSAttributedString alloc] initWithString:@" 搜索用户和话题" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexColorString:@"999999"],NSFontAttributeName:font}]];
    searchLabel.attributedText = searchPlaceHold;
    
    searchLabel.textAlignment = NSTextAlignmentCenter;
    searchPlaceHold.yy_alignment = NSTextAlignmentCenter;
    
    searchLabel.layer.cornerRadius = 15;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onSearchClick)];
    [searchLabel addGestureRecognizer:tap];
    
    self.navigationItem.titleView = searchLabel;
}
#pragma mark 点击
-(void)onChangeStarUser:(UIButton *)sender
{
    [self requreSrarUser:YES];
}
-(void)onSearchClick{
    SearchTagUserViewController *shVC = [[SearchTagUserViewController alloc]initWithStyle:UITableViewStylePlain];
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:shVC];
    [navi setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:navi animated:YES completion:nil];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
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
