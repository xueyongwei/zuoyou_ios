//
//  RootViewController.m
//  HDJ
//
//  Created by xueyongwei on 16/5/6.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "RootViewController.h"
#import "AppDelegate.h"
#import "HowLoginViewController.h"
#import "HotTagTableViewCell.h"
#import "TagTableViewCell.h"
#import "SearchTagViewController.h"
#import "ShouYeViewController.h"
#import "VersusListViewController.h"
#import "PersonalViewController.h"
#import "PKViewController.h"
#import "MatchViewController.h"
#import "ChoseTagToJoinViewController.h"
#import "XYWAlert.h"
#import "tagModel.h"
#import "ItmHeaderView.h"

#import "CaptureViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SBCaptureToolKit.h"
#import <AVFoundation/AVFoundation.h>
#import "PlayViewController.h"
#import "CaptureVideoNavigationController.h"
#import "UIImage+Color.h"

#define kClassKey   @"rootVCClassString"
#define kTitleKey   @"title"
#define kImgKey     @"imageName"
#define kSelImgKey  @"selectedImageName"

#define standOutHeight 12.0f // 中间突出部分的高度

@interface RootViewController ()<CAAnimationDelegate,UITabBarControllerDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (nonatomic,assign)BOOL loginOther;
@property (nonatomic,strong)UIVisualEffectView *selectTagView;
@property (nonatomic,strong)UIButton *closeBtn;
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *dataSource;
@property (nonatomic,strong)NSMutableArray *searchResultSource;
@property (nonatomic,strong)UITextField *searchTF;
@property (nonatomic,strong)YYLabel *searchLabel;
@property (nonatomic,copy)NSMutableAttributedString *searchPlaceHold;
@property (nonatomic,assign)BOOL showSearchResults;
@property (nonatomic,strong)ItmHeaderView *headerViewItmTitleLabel;
@end

@implementation RootViewController
-(NSMutableAttributedString*)searchPlaceHold
{
    if (!_searchPlaceHold) {
        UIFont *font =[UIFont systemFontOfSize:15];
        _searchPlaceHold = [NSMutableAttributedString new];
        UIImage *image = [UIImage imageNamed:@"搜索icon"];
        image = [UIImage imageWithCGImage:image.CGImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
        NSMutableAttributedString *imgContent = [NSMutableAttributedString yy_attachmentStringWithContent:image contentMode:UIViewContentModeScaleAspectFit attachmentSize:CGSizeMake(15, 15) alignToFont:font alignment:YYTextVerticalAlignmentCenter];
        [_searchPlaceHold appendAttributedString:imgContent];
        [_searchPlaceHold appendAttributedString:[[NSAttributedString alloc] initWithString:@" 搜索话题" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexColorString:@"999999"],NSFontAttributeName:font}]];
        _searchPlaceHold.yy_alignment = NSTextAlignmentCenter;
    }
    return _searchPlaceHold;
}
-(NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [NSMutableArray new];
    }
    return _dataSource;
}
-(NSMutableArray *)searchResultSource
{
    if (!_searchResultSource) {
        _searchResultSource = [NSMutableArray new];
    }
    return _searchResultSource;
}
-(UITableView *)tableView
{
    if (!_tableView) {
        CGFloat selectW = _selectTagView.contentView.bounds.size.width;
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, selectW, _selectTagView.contentView.bounds.size.height - 60) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        
        UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, selectW, 80)];
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, selectW, 44)];
        titleLabel.text = @"设置话题";
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.textColor = [UIColor colorWithHexColorString:@"333333"];
        [headerView addSubview:titleLabel];
        
        UIButton *nxtBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        nxtBtn.frame = CGRectMake(selectW-60, 0, 50, 44);
        [nxtBtn setTitle:@"下一步" forState:UIControlStateNormal];
        nxtBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        nxtBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [nxtBtn setTitleColor:[UIColor colorWithHexColorString:@"333333"] forState:UIControlStateNormal];
        [nxtBtn addTarget:self action:@selector(onNxtClick:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:nxtBtn];
        
        
        UIView *searchBgView = [[UIView alloc]initWithFrame:CGRectMake(13, 44, SCREEN_W-26, 30)];
        searchBgView.layer.borderWidth = SINGLE_LINE_WIDTH;
        searchBgView.layer.borderColor = [UIColor redColor].CGColor;
        searchBgView.layer.cornerRadius = 15;
        
        [headerView addSubview:searchBgView];
        
        UITextField *tf = [[UITextField alloc]initWithFrame:CGRectMake(12.5, 0, searchBgView.bounds.size.width-15, 30)];
        [tf addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        tf.placeholder = @"请输入4-14字的PK话题";
        tf.returnKeyType = UIReturnKeyDone;
        tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        tf.delegate = self;
        
        tf.font = [UIFont systemFontOfSize:15];
        self.searchTF = tf;
        [searchBgView addSubview:tf];
        
        _tableView.tableHeaderView = headerView;
    }
    return _tableView;
}
-(ItmHeaderView *)headerViewItmTitleLabel
{
    if (!_headerViewItmTitleLabel) {
        ItmHeaderView *itmTitleLabel = [[[NSBundle mainBundle]loadNibNamed:@"ItmHeaderView" owner:self options:nil]lastObject];
        itmTitleLabel.frame = CGRectMake(0, 79, SCREEN_W, 19);
        itmTitleLabel.headerLabel.text = @"推荐话题";
        _headerViewItmTitleLabel = itmTitleLabel;
    }
    return _headerViewItmTitleLabel;
}

-(UIVisualEffectView *)selectTagView
{
    if (!_selectTagView) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        _selectTagView = [[UIVisualEffectView alloc]initWithEffect:effect];
        _selectTagView.frame = CGRectMake(0, 0, SCREEN_W, SCREEN_H);
        
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn addTarget:self action:@selector(onCloseBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_closeBtn setImage:[UIImage loadImageNamed:@"选择话题btn"] forState:UIControlStateNormal];
        [_selectTagView.contentView addSubview:_closeBtn];
        [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_selectTagView.contentView);
            make.bottom.equalTo(_selectTagView.contentView).offset(-7);
            make.height.with.mas_equalTo(47);
        }];
    }
    return _selectTagView;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self customTabbar];
    [self rootAddChildrenVCs];
    [self startListenNotification];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(resetUploadStatus) name:kCaptureViewControllerStopRecod object:nil];
}
-(void)resetUploadStatus{
    _closeBtn.layer.transform = CATransform3DMakeRotation(M_PI_4, 0, 0, 1);
    _selectTagView.alpha = 0;
    [_selectTagView removeFromSuperview];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}
#pragma mark ---数据相关
-(void)prepareHotTagData
{
    __weak typeof(self) wkSelf = self;
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@%@",HeadUrl,@"/tag/choice"] parameters:nil inView:nil sucess:^(id result) {
        [self.tableView.mj_header endRefreshing];
        DbLog(@"%@",result);
        if ([result isKindOfClass:[NSArray class]]) {
            [wkSelf.dataSource removeAllObjects];
            for (NSDictionary *tag in result) {
                tagModel *model = [tagModel mj_objectWithKeyValues:tag];
                [wkSelf.dataSource addObject:model];
            }
            [wkSelf.tableView reloadData];
        }
    } failure:^(NSError *error) {
        [wkSelf.tableView.mj_header endRefreshing];
    }];
}

-(void)searchTag
{
    if (!self.showSearchResults) {//确保显示的是搜素结果
        self.showSearchResults = YES;
    }
    [self.searchResultSource removeAllObjects];
    [self.tableView reloadData];
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@/tag/search",HeadUrl] parameters:@{@"key":self.searchTF.text,@"pn":@"1"} inView:nil sucess:^(id result) {
        DbLog(@"%@",result);
        if ([result isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dic in result) {
                tagModel *model = [tagModel mj_objectWithKeyValues:dic];
                [self.searchResultSource addObject:model];
            }
            [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark ---tableView 相关
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.showSearchResults) {
        return 0.1 ;
    }else{
        return 20;
    }
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.showSearchResults) {
        return [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0.1)];
    }else{
        return self.headerViewItmTitleLabel ;
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.showSearchResults) {
        self.headerViewItmTitleLabel.hidden = YES;
        return self.searchResultSource.count;
    }else{
        self.headerViewItmTitleLabel.hidden = NO;
        return self.dataSource.count;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.showSearchResults) {
        TagTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TagTableViewCell"];
        if (!cell) {
            cell =[[[NSBundle mainBundle]loadNibNamed:@"TagTableViewCell" owner:self options:nil]lastObject];
            cell.sepreatConstH.constant = 0;
            cell.backgroundColor = [UIColor clearColor];
        }
        cell.IconConstH.constant = 0;
//        if (self.searchTF.text.length>0) {
//            cell.IconConstH.constant = 0;
//        }else{
//            cell.iconImgV.image = [UIImage imageNamed:@"历史_icon"];
//            cell.iconHeightconst.constant = 20;
//            cell.IconConstH.constant = 30;
//        }
        tagModel *model = self.searchResultSource[indexPath.row];
        if (model.activity) {
            cell.tagNameLabel.attributedText = [self attributedTagName:model.formatertagName];
        }else{
            cell.tagNameLabel.text = model.formatertagName;
        }
//        cell.tagNameLabel.text = model.formatertagName;
        cell.idxLabel.text = @"";
        return cell;
    }else{
        HotTagTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@""];
        if (!cell) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"HotTagTableViewCell" owner:self options:nil]lastObject];
            cell.backgroundColor = [UIColor clearColor];
            cell.sepHeightConst.constant = 0;
        }
        tagModel *model = self.dataSource[indexPath.row];
        [cell.TagThumbImageView sd_setImageWithURL:[NSURL URLWithString:model.frontCover] placeholderImage:[UIImage imageNamed:@"00"]];
        if (model.activity) {
            cell.tagNameLabel.attributedText = [self attributedTagName:model.formatertagName];
        }else{
            cell.tagNameLabel.text = model.formatertagName;
        }
        return cell;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.showSearchResults) {
        return 40;
    }else{
        return 55;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.showSearchResults) {
        tagModel *model = self.searchResultSource[indexPath.row];
//        CaptureVideoNavigationController *navCon = [[CaptureVideoNavigationController alloc] init];
        CaptureViewController *captureViewCon = [[CaptureViewController alloc] initWithNibName:@"CaptureViewController" bundle:nil];
        captureViewCon.tagId = model.tagID;
        captureViewCon.tagName = model.formatertagName;
        captureViewCon.challenge = @"false";
        CaptureVideoNavigationController *navCon = [[CaptureVideoNavigationController alloc] initWithRootViewController:captureViewCon];
        //    navCon.notChangeStatusWhenDealloc = YES;
        //    [navCon pushViewController:captureViewCon animated:YES];
        [self presentViewController:navCon animated:YES completion:nil];
        
//        [navCon pushViewController:captureViewCon animated:YES];
//        [self.navigationController presentViewController:navCon animated:YES completion:nil];
    }else{
        tagModel *model = self.dataSource[indexPath.row];
        
        CaptureViewController *captureViewVC = [[CaptureViewController alloc] initWithNibName:@"CaptureViewController" bundle:nil];
        captureViewVC.tagId = model.tagID;
        captureViewVC.tagName = model.formatertagName;
        captureViewVC.challenge = @"false";
        CaptureVideoNavigationController *navCon = [[CaptureVideoNavigationController alloc] initWithRootViewController:captureViewVC];
        //    navCon.notChangeStatusWhenDealloc = YES;
        //    [navCon pushViewController:captureViewCon animated:YES];
        [self presentViewController:navCon animated:YES completion:nil];
    }
//    [self onCloseBtn:_closeBtn];
    
    
}
#pragma mark ---TF相关的delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
//    if (textField.text.length<1) {
//        textField.hidden = YES;
//        self.searchLabel.attributedText = self.searchPlaceHold;
//    }else{
//        
//    }
    
    return YES;
}
-(void)textFieldDidChange:(UITextField *)textField
{
//    self.whatUinput = self.searchTF.text;
    UITextRange *selectedRange = [textField markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textField positionFromPosition:selectedRange.start offset:0];
    
    //如果在变化中是高亮部分在变，就不要计算字符了
    if (selectedRange && pos) {
        return;
    }
    NSString *noEmojiStr =[self disableEmoji:textField.text];
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"～@／；（）¥「」＂、[]{}#%-*+=_\\|~＜＞$€^•'@#$%^&*()_+'\""];
    NSString *normalStr = [noEmojiStr stringByTrimmingCharactersInSet:set];
    textField.text = normalStr;
    if (textField.text.length>14) {
        textField.text = [textField.text substringToIndex:14];
    }
    
    if(textField.text.length==0){
        self.showSearchResults = NO;
        [self.tableView reloadData];
    }else if (textField.text.length ==1){
        [self.searchResultSource removeAllObjects];
        self.showSearchResults = YES;
        [self.tableView reloadData];
    }else if(textField.text.length>1){
        [self searchTag];
    }
}
//禁止输入表情
- (NSString *)disableEmoji:(NSString *)text
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]" options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:text
                                                               options:0
                                                                 range:NSMakeRange(0, [text length])
                                                          withTemplate:@""];
    return modifiedString;
}
#pragma mark ---tabbar相关的
-(void)rootAddChildrenVCs
{
    ShouYeViewController *shouyeVC = [ShouYeViewController new];
    MatchViewController *matchVC = [[MatchViewController alloc]initWithStyle:UITableViewStylePlain];
    PKViewController *pkVC = [PKViewController new];
    PersonalViewController *personalVC = [PersonalViewController new];
    UIViewController *centerPlaceholder = [UIViewController new];
    NSArray *childItemsArray = @[
                                 @{kClassKey  : shouyeVC,
                                   kTitleKey  : @"首页",
                                   kImgKey    : @"tabbarIcon1",
                                   kSelImgKey : @"tabbarIcon1L"},
                                 
                                 @{kClassKey  : matchVC,
                                   kTitleKey  : @"发现",
                                   kImgKey    : @"tabbarIcon2",
                                   kSelImgKey : @"tabbarIcon2L"},
                                 @{kClassKey  : centerPlaceholder,
                                   kTitleKey  : @" ",
                                   kImgKey    : @"tabbarIconCenter",
                                   kSelImgKey : @"tabbarIconCenter"},

                                 @{kClassKey  : pkVC,
                                   kTitleKey  : @"PK",
                                   kImgKey    : @"tabbarIcon3",
                                   kSelImgKey : @"tabbarIcon3L"},
                                 
                                 @{kClassKey  : personalVC,
                                   kTitleKey  : @"个人",
                                   kImgKey    : @"tabbarIcon4",
                                   kSelImgKey : @"tabbarIcon4L"},
                                 ];
    __block int i = 100;
    __weak typeof(self) wkSelf = self;
    [childItemsArray enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
        UIViewController *vc = dict[kClassKey];
        vc.title = dict[kTitleKey];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        UITabBarItem *item = nav.tabBarItem;
        item.tag = i++;
        item.title = dict[kTitleKey];
        CGFloat fontSize = 11.0;
        if (vc == pkVC) {
            fontSize = 12.0;
        }
        item.image = [[UIImage imageNamed:dict[kImgKey]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [item setTitlePositionAdjustment:UIOffsetMake(0, -2)];
        item.selectedImage = [[UIImage imageNamed:dict[kSelImgKey]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [item setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithHexColorString:@"ff4a4b"],NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} forState:UIControlStateSelected];
        [item setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} forState:UIControlStateNormal];
        [wkSelf addChildViewController:nav];
    }];
    
//    UIButton *centerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [centerBtn addTarget:self action:@selector(onCenterBtnCLick:) forControlEvents:UIControlEventTouchUpInside];
//    centerBtn.frame = CGRectMake(SCREEN_W/2-30, 0, 60, 59);
//    [centerBtn setImage:[UIImage imageNamed:@"tabbarIconCenter"] forState:UIControlStateNormal];
//    [centerBtn setImage:[UIImage imageNamed:@"tabbarIconCenterL"] forState:UIControlStateHighlighted];
//    [self.tabBar addSubview:centerBtn];
//    [self.tabBar bringSubviewToFront:centerBtn];
    
}
-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if (viewController.tabBarItem.tag == 102) {
        [self onCenterBtnCLick:self.closeBtn];
        return NO;
    }
    return YES;
}
-(void)onCenterBtnCLick:(UIButton *)sender
{
    if (self.dataSource.count==0) {
        [self prepareHotTagData];
    }
    [self.selectTagView.contentView addSubview:self.tableView];
    self.selectTagView.alpha = 0;
    CGRect tableRect = self.tableView.frame;
    tableRect.origin.y = SCREEN_H;
    self.tableView.frame = tableRect;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [self.view addSubview:self.selectTagView];
    __weak typeof(self) wkSelf = self;
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:20 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        wkSelf.tableView.frame = CGRectMake(0, 0, tableRect.size.width, tableRect.size.height);
    } completion:^(BOOL finished) {
        
    }];
//    [UIView animateWithDuration:0.3 animations:^{
//        wkSelf.tableView.frame = CGRectMake(0, 0, tableRect.size.width, tableRect.size.height);
//    }];
    [UIView animateWithDuration:0.3 animations:^{
        wkSelf.selectTagView.alpha = 1;
        
    } completion:^(BOOL finished) {
        
        CABasicAnimation* ba = [CABasicAnimation animationWithKeyPath:@"transform"];
        ba.autoreverses = NO;
        ba.duration = 0.2;
        ba.removedOnCompletion = NO;
        ba.fillMode = kCAFillModeForwards;
        ba.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI_2, 0, 0, 1)];
        [wkSelf.closeBtn.layer addAnimation:ba forKey:nil];
        
    }];
}
-(void)onCloseBtn:(UIButton *)sender
{
    CGRect tableRect = self.tableView.frame;
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    
//    [[UIApplication sharedApplication].windows.lastObject addSubview:self.selectTagView];
    __weak typeof(self) wkSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.frame = CGRectMake(0, SCREEN_H, tableRect.size.width, tableRect.size.height);
    }];
    [self resetSearceView];
    CABasicAnimation* ba = [CABasicAnimation animationWithKeyPath:@"transform"];
    ba.autoreverses = NO;
    ba.delegate = wkSelf;
    ba.duration = 0.2;
    ba.removedOnCompletion = NO;
    ba.fillMode = kCAFillModeForwards;
    ba.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI_4, 0, 0, 1)];
    [sender.layer addAnimation:ba forKey:@"closeBtnOut"];
}
-(void)resetSearceView
{
    self.searchTF.text = @"";
    self.showSearchResults = NO;
    [self.tableView reloadData];
}
-(void)onNxtClick:(UIButton *)sender{
    if (self.searchTF.text.length<1) {
        CoreSVPCenterMsg(@"请先设置PK话题");
        return;
    }
    if (self.searchTF.text.length>14 || self.searchTF.text.length<4) {
        CoreSVPCenterMsg(@"请输入4-14字的PK话题");
        return;
    }
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@/tag/check",HeadUrl] parameters:@{@"name":self.searchTF.text} inView:nil sucess:^(id result) {
        if ([result objectForKey:@"errCode"]) {
            CoreSVPCenterMsg(result[@"errMsg"]);
            DbLog(@"%@",result[@"errMsg"]);
        }else{
            CaptureVideoNavigationController *navCon = [[CaptureVideoNavigationController alloc] init];
            CaptureViewController *captureViewCon = [[CaptureViewController alloc] initWithNibName:@"CaptureViewController" bundle:nil];
            captureViewCon.tagName = [NSString stringWithFormat:@"#%@#",self.searchTF.text];
            captureViewCon.challenge = @"false";
            [navCon pushViewController:captureViewCon animated:YES];
            [self presentViewController:navCon animated:YES completion:nil];
        }
    } failure:^(NSError *error) {
        DbLog(@"%@",error.localizedDescription);
        CoreSVPCenterMsg(error.localizedDescription);
    }];

}
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if ([anim isEqual:[self.closeBtn.layer animationForKey:@"closeBtnOut"]]) {//关闭动画
        [UIView animateWithDuration:0.3 animations:^{
            _selectTagView.alpha = 0;
        } completion:^(BOOL finished) {
            [_selectTagView removeFromSuperview];
//            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
//            [UIApplication sharedApplication].windows.lastObject.windowLevel = UIWindowLevelNormal;
        }];
    }
    
}
-(void)customTabbar
{
    self.tabBar.tintColor = [UIColor colorWithHexColorString:@"ff4a4b"];
    self.tabBar.barTintColor = [UIColor whiteColor];
    
    [self.tabBar.items[2] setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11+SINGLE_LINE_WIDTH]}  forState:UIControlStateNormal];
    self.delegate = self;
    
    [self.tabBar setShadowImage:[UIImage new]];
    
    [self.tabBar setBackgroundImage:[UIImage imageFromContextWithColor:[UIColor whiteColor]]];
    
    [self.tabBar setBackgroundImage:[UIImage new]];
    [self.tabBar insertSubview:[self drawTabbarBgImageView] atIndex:0];
}
// 画背景的方法，返回 Tabbar的背景
- (UIImageView *)drawTabbarBgImageView
{
    CGFloat radius = 30;// 圆半径
    CGFloat allFloat= (pow(radius, 2)-pow((radius-standOutHeight), 2));// standOutHeight 突出高度 12
    CGFloat ww = sqrtf(allFloat);
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, -standOutHeight,SCREEN_W , CGRectGetHeight(self.tabBar.bounds) +standOutHeight)];// ScreenW设备的宽
    //    imageView.backgroundColor = [UIColor redColor];
    CGSize size = imageView.frame.size;
    CAShapeLayer *layer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(size.width/2 - ww, standOutHeight)];
//    NSLog(@"ww: %f", ww);
//    NSLog(@"ww11: %f", 0.5*((radius-ww)/radius));
//    CGFloat angleH = 0.5*((radius-standOutHeight)/radius);
//    NSLog(@"angleH：%f", angleH);
//    CGFloat startAngle = (1+angleH)*((float)M_PI); // 开始弧度
//    CGFloat endAngle = (2-angleH)*((float)M_PI);//结束弧度
//    // 开始画弧：CGPointMake：弧的圆心  radius：弧半径 startAngle：开始弧度 endAngle：介绍弧度 clockwise：YES为顺时针，No为逆时针
//    [path addArcWithCenter:CGPointMake((size.width)/2, radius) radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    // 开始画弧以外的部分
    [path addLineToPoint:CGPointMake(size.width/2+ww, standOutHeight)];
    [path addLineToPoint:CGPointMake(size.width, standOutHeight)];
    [path addLineToPoint:CGPointMake(size.width,size.height)];
    [path addLineToPoint:CGPointMake(0,size.height)];
    [path addLineToPoint:CGPointMake(0,standOutHeight)];
    [path addLineToPoint:CGPointMake(size.width/2-ww, standOutHeight)];
    layer.path = path.CGPath;
    layer.fillColor = [UIColor whiteColor].CGColor;// 整个背景的颜色
    layer.strokeColor = [UIColor colorWithHexColorString:@"e1e1e1"].CGColor;//边框线条的颜色
    layer.lineWidth = 0.5;//边框线条的宽
    // 在要画背景的view上 addSublayer:
    [imageView.layer addSublayer:layer];
    return imageView;
}

-(void)onSearchClick:(UITapGestureRecognizer *)recognizer
{
//    _closeBtn.layer.transform = CATransform3DMakeRotation(M_PI_4, 0, 0, 1);
//    _selectTagView.alpha = 0;
//    [_selectTagView removeFromSuperview];
//    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
//    [UIApplication sharedApplication].windows.lastObject.windowLevel = UIWindowLevelNormal;
    
//    [self onCloseBtn:_closeBtn];
    self.searchLabel.attributedText = nil;
//    self.searchTF.hidden = NO;
    [self.searchTF becomeFirstResponder];
    /*
    SearchTagViewController *shVC = [[SearchTagViewController alloc]initWithStyle:UITableViewStylePlain];
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:shVC];
    [navi setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self.selectedViewController presentViewController:navi animated:YES completion:nil];
    */
}
#pragma mark ---重新登录相关
-(void)onLogOut {
    if (self.loginOther) {//只接收一个退出登陆信息
        return;
    }
    self.loginOther = YES;
    DbLog(@"您的账号已在别处登录,弹窗提醒");
    __weak typeof(self) wkSelf = self;
    [XYWAlert XYWAlertTitle:@"登录失效，请重新登录" message:nil first:nil firstHandle:nil second:nil Secondhandle:nil cancle:@"知道了" handle:^{
        [wkSelf changeRootViewM];
        wkSelf.loginOther = NO;
    }];
    
    [[SocketManager defaultManager] dropWS];
    [UserInfoManager cleanMyselfInfo];
}
-(void)changeRootViewM
{
    [CoreSVP dismiss];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    HowLoginViewController *hlVC = [[UIStoryboard storyboardWithName:@"LoginStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"HowLoginViewController"];
    //修改rootVC
    [delegate.window addSubview:hlVC.view];
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self.navigationController.view removeFromSuperview];
    UINavigationController *rootVc =[[UINavigationController alloc]initWithRootViewController:hlVC];
    rootVc.navigationBarHidden = YES;
    delegate.window.rootViewController = rootVc;
    self.loginOther = NO;
}
#pragma mark ---通知中心相关
//开始启动监听
-(void)startListenNotification
{
    [self addMsgListener];
    [self addNotificationCenterListner];
}
//监听WS消息
-(void)addMsgListener
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(newMsghandle:) name:@"system/pk/challenge" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(newMsghandle:) name:@"system/pk/beChallenge" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(newMsghandle:) name:@"system/finance/praise" object:nil];
}
//监听其他人发的要RootVC知道的通知
-(void)addNotificationCenterListner
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(logoutNotiHandle:) name:kShouldLogoutNoti object:nil];
}
//移除监听WS消息
-(void)removeMsgListener
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
-(void)newMsghandle:(NSNotification *)noti
{
    DbLog(@"收到新WS消息，刷新红点");
    //收到新的消息后刷新一下红点
    [[SocketManager defaultManager] sendMsg:[NSString stringWithFormat:@"{uri:\"system/session/list\"}"]];
}
#pragma mark ---通知的handle
//WS消息
-(void)systemsessionlistHandle:(NSNotification *)noti
{
    DbLog(@"%@",noti.userInfo);
    
//    WSmessageModel *model = (WSmessageModel*)noti.userInfo[@"model"];
//    if (![model.body isKindOfClass:[NSArray class]]) {
//        DbLog(@"is not the class we want(nsarray)!");
//    }
//    NSInteger totalUnreadCount = [NSString stringWithFormat:@"%@",model.extras[@"totalUnreadCount"]].integerValue;
//    if (totalUnreadCount>0) {
//        [self.tabBarController.tabBar showBadgeOnItemIndex:4];
//    }else{
//        [self.tabBarController.tabBar hideBadgeOnItemIndex:4];
//    }
    
//    NSArray *bodys = (NSArray *)model.body;
//    
//    for (NSDictionary *dic in bodys) {
//        XiaoxiSessionModel *model = [XiaoxiSessionModel mj_objectWithKeyValues:dic];
//        if ([model isSuppotrType]) {
//            if (model.unreadCount>0) {
//                [self.tabBar hideBadgeOnItemIndex:3];
//                [self.tabBar showBadgeOnItemIndex:3];
//                return;
//            }
//        }
//    }
//    [self.tabBarController.tabBar hideBadgeOnItemIndex:3];
}
//需要推出登陆消息handle
-(void)logoutNotiHandle:(NSNotification *)noti
{
    [self onLogOut];
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
