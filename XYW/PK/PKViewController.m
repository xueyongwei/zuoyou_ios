//
//  PKViewController.m
//  ZuoYou
//
//  Created by xueyongwei on 16/11/3.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "PKViewController.h"
#import "VersusListViewController.h"
#import "VideoListViewController.h"
@interface PKViewController ()<UIScrollViewDelegate>
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIButton *currentChildrenBtn;
@property (nonatomic,strong) UIButton *jxBtn;
@property (nonatomic,strong) UIButton *dtBtn;
@property (nonatomic,strong) UIButton *bdBtn;
@property (nonatomic,strong) UILabel *childrenXian;
@property (nonatomic,strong) UIView *naviView;
@end

@implementation PKViewController
{
    BOOL transiting;
    UIViewController *currentVC;
    
}
-(UIView *)naviView
{
    if (!_naviView) {
        _naviView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 230, 44)];
        //热战区
        self.jxBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.jxBtn.frame = CGRectMake(0, 0, 70, 44);
        [self.jxBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [self.jxBtn setTitle:@"热战区" forState:UIControlStateNormal];
        [self.jxBtn setTitleColor:[UIColor colorWithHexColorString:@"ff4a4b"] forState:UIControlStateSelected];
        [self.jxBtn setTitleColor:[UIColor colorWithHexColorString:@"333333"] forState:UIControlStateNormal];
        self.jxBtn.tag = 100;
        [self.jxBtn addTarget:self action:@selector(onTitBenCLick:) forControlEvents:UIControlEventTouchDown];
        [_naviView addSubview:self.jxBtn];
        //挑战区
        self.dtBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.dtBtn.frame = CGRectMake(80, 0, 70, 44);
        [self.dtBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [self.dtBtn setTitle:@"挑战区" forState:UIControlStateNormal];
        [self.dtBtn setTitleColor:[UIColor colorWithHexColorString:@"ff4a4b"] forState:UIControlStateSelected];
        [self.dtBtn setTitleColor:[UIColor colorWithHexColorString:@"333333"] forState:UIControlStateNormal];
        self.dtBtn.tag = 101;
        [self.dtBtn addTarget:self action:@selector(onTitBenCLick:) forControlEvents:UIControlEventTouchDown];
        [_naviView addSubview:self.dtBtn];
        //已结束
        self.bdBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.bdBtn.frame = CGRectMake(160, 0, 70, 44);
        [self.bdBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [self.bdBtn setTitle:@"已结束" forState:UIControlStateNormal];
        [self.bdBtn setTitleColor:[UIColor colorWithHexColorString:@"ff4a4b"] forState:UIControlStateSelected];
        [self.bdBtn setTitleColor:[UIColor colorWithHexColorString:@"333333"] forState:UIControlStateNormal];
        self.bdBtn.tag = 102;
        [self.bdBtn addTarget:self action:@selector(onTitBenCLick:) forControlEvents:UIControlEventTouchDown];
        [_naviView addSubview:self.bdBtn];
        
        
        self.childrenXian = [[UILabel alloc]initWithFrame:CGRectMake(0, 41.5, 70, 2.5)];
        self.childrenXian.backgroundColor = [UIColor colorWithHexColorString:@"ff4a4b"];
        [_naviView addSubview:self.childrenXian];
        
        //设置选中精选标签
        self.jxBtn.selected = YES;
        self.currentChildrenBtn = self.jxBtn;
    }
    return _naviView;
}
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
    [self customNavi];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self prepareChildrenVC];
    
}

-(void)customNavi
{
    self.navigationItem.titleView = self.naviView;
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
//    //自定义导航栏可手势返回
//    if (self.navigationController) {
//        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
//        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
//    }
//    
//    self.navigationItem.titleView = self.naviView;
//    //自定义导航栏可手势返回
//    if (self.navigationController) {
//        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
//        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
//    }
}

-(void)prepareChildrenVC
{
    self.scrollView = [UIScrollView new];
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.left.equalTo(self.view);
    }];
    self.scrollView.bounces = YES;
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width*3, 0);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    
    CGRect frame = self.scrollView.bounds;
    
    //热战区
    VersusListViewController *rzVC = [[VersusListViewController alloc]initWithStyle:UITableViewStylePlain];
    rzVC.requestURL = @"/versus/search?tagId=&stage=start";
    rzVC.noMoreDataMessage = @"暂时没有正在进行中的PK";
    rzVC.view.frame = frame;
    [self addChildViewController:rzVC];
    [self.scrollView addSubview:rzVC.view];
    
    //挑战区
    frame.origin.x = self.view.bounds.size.width;
    VideoListViewController *tzVC = [[VideoListViewController alloc]initWithStyle:UITableViewStylePlain];
    tzVC.cellTypeIsWithTag = YES;
    tzVC.view.frame =frame;
    [self addChildViewController:tzVC];
    [self.scrollView addSubview:tzVC.view];
    
    //已结束
    frame.origin.x = self.view.bounds.size.width*2;
    VersusListViewController *dmVC = [[VersusListViewController alloc]initWithStyle:UITableViewStylePlain];
    dmVC.requestURL = @"/versus/search?tagId=&stage=end";
    dmVC.noMoreDataMessage = @"暂时没有已经结束的PK";
    dmVC.view.frame = frame;
    [self addChildViewController:dmVC];
    [self.scrollView addSubview:dmVC.view];

    currentVC = rzVC;
}
-(void)onTitBenCLick:(UIButton *)sender
{
    CGRect rec = self.childrenXian.frame;
    rec.origin.x = 80*(sender.tag -100);
    [UIView animateWithDuration:0.2 animations:^{
        self.childrenXian.frame = rec;
    }];
    
    self.currentChildrenBtn.selected = NO;
    sender.selected = YES;
    [self changeToVC:sender.tag-100];
    self.currentChildrenBtn = sender;
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint offSet = scrollView.contentOffset;
    CGFloat idx = offSet.x/self.view.width;
    
    UIButton *btn = [self.naviView viewWithTag:idx +100];
    if (self.currentChildrenBtn != btn) {
        CGRect rec = self.childrenXian.frame;
        rec.origin.x = 80*idx;
        [UIView animateWithDuration:0.2 animations:^{
            self.childrenXian.frame = rec;
        }];
        self.currentChildrenBtn.selected = NO;
        btn.selected = YES;
        self.currentChildrenBtn = btn;
    }
    
    
}
-(void)changeToVC:(NSInteger)idx
{
    [self.scrollView setContentOffset:CGPointMake(idx*self.view.bounds.size.width, 0) animated:YES];
    return;
    
//    UIViewController *nxtVC = [self.childViewControllers objectAtIndex:idx];
//    if (transiting||(currentVC == nxtVC)) {
//        return;
//    }
//    transiting = YES;
//    nxtVC.view.frame = self.view.bounds;
//    [self transitionFromViewController:currentVC toViewController:nxtVC duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
//        
//    } completion:^(BOOL finished) {
//        if (finished) {
//            [nxtVC didMoveToParentViewController:self];
//            [currentVC willMoveToParentViewController:nil];
//            transiting = NO;
//            currentVC = nxtVC;
//        }else{
//            
//        }
//    }];
    
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
