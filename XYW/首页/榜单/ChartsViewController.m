//
//  ChartsViewController.m
//  ZuoYou
//
//  Created by xueyongwei on 2016/11/28.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "ChartsViewController.h"
#import "ValueChartsTableViewController.h"

static CGFloat itmHeight = 38;

@interface ChartsViewController ()<UIScrollViewDelegate>
@property (nonatomic,strong)UIButton *currentItmPointer;
@property (nonatomic,strong)UIScrollView *scrolViewPointer;

@end

@implementation ChartsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customView];
    // Do any additional setup after loading the view.
}
-(void)customView
{
    [self customItmsView];
}
//绘制itms导航按钮
-(void)customItmsView
{
    NSArray *itmsName = @[@"王者榜",@"人气榜",@"粉丝榜",@"伯乐榜"];
    UIView *LeftView = self.view;
    for (int i =0; i<itmsName.count; i++) {
        NSString *name = itmsName[i];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = 100+i;
        [btn setBackgroundColor:[UIColor whiteColor]];
        [btn setTitle:name forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithHexColorString:@"999999"] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithHexColorString:@"ff4a4b"] forState:UIControlStateSelected];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn addTarget:self action:@selector(onItmBtnCLick:) forControlEvents:UIControlEventTouchUpInside];
        if (i==0) {//当前默认分类为第一个分类
            self.currentItmPointer = btn;
        }
        [self.view addSubview:btn];
        
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            if (![LeftView isKindOfClass:[UIButton class]]) {
                make.left.equalTo(LeftView);
            }else{
                make.left.equalTo(LeftView.mas_right);
            }
            make.top.equalTo(self.view);
            make.height.mas_equalTo(itmHeight);
            make.width.equalTo(self.view).multipliedBy(1.0/itmsName.count);
        }];
        LeftView = btn;
    }
    [self customBodyScrollView];
}
//绘制中间的scrollView
-(void)customBodyScrollView
{
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, itmHeight, self.view.bounds.size.width, self.view.bounds.size.height-itmHeight-64)];
    [self.view addSubview:scrollView];
    scrollView.bounces = YES;
    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width*4, 0);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    self.scrolViewPointer = scrollView;
    
    for (int i = 0; i<4; i++) {
        ValueChartsTableViewController *valChartsVC = [[ValueChartsTableViewController alloc]initWithStyle:UITableViewStylePlain];
        valChartsVC.chartsType = i;
        valChartsVC.view.frame = CGRectMake(self.view.bounds.size.width*i, 0, self.view.bounds.size.width , scrollView.bounds.size.height);
        [self addChildViewController:valChartsVC];
        [scrollView addSubview:valChartsVC.view];
    }

    //不清楚为什么用autoLayout就不能滑动了。。。
}
//设置一个btn为当前的itm
-(void)setCurrentItmPointer:(UIButton *)currentItmPointer
{
    _currentItmPointer = currentItmPointer;
    currentItmPointer.titleLabel.font = [UIFont systemFontOfSize:15];
    currentItmPointer.selected = YES;
}
//点击一个itm
-(void)onItmBtnCLick:(UIButton *)itmBtn
{
    self.currentItmPointer.titleLabel.font = [UIFont systemFontOfSize:14];
    self.currentItmPointer.selected = NO;
    self.currentItmPointer = itmBtn;
    [self.scrolViewPointer setContentOffset:CGPointMake((itmBtn.tag-100)*SCREEN_W, 0) animated:YES];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView isKindOfClass:[UITableView class]]) {//不处理tableView的滑动
        return;
    }
    CGPoint point = scrollView.contentOffset;
    NSInteger idx = point.x/SCREEN_W+100;
    if (idx<=100) {
        idx =100;
    }else if (idx>103){
        idx = 103;
    }
    DbLog(@"%ld",(long)idx);
    UIButton *btn = (UIButton *)[self.view viewWithTag:idx];
    [self onItmBtnCLick:btn];
}








- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
