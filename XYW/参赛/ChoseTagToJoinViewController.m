//
//  ChoseTagToJoinViewController.m
//  ZuoYou
//
//  Created by xueyognwei on 16/12/16.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "ChoseTagToJoinViewController.h"
#import "SearchTagViewController.h"

#import "UIImage+ImageEffects.h"
#import "YYText.h"
#import "YYLabel.h"

@interface ChoseTagToJoinViewController ()
@property (nonatomic,strong)UIButton *closeBtn;
@end

@implementation ChoseTagToJoinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择话题";
    [self customUI];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view bringSubviewToFront:self.closeBtn];
    CABasicAnimation* ba = [CABasicAnimation animationWithKeyPath:@"transform"];
    ba.autoreverses = NO;
    ba.duration = 0.5;
    ba.removedOnCompletion = NO;
    ba.fillMode = kCAFillModeForwards;
    ba.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI_2, 0, 0, 1)];
    [self.closeBtn.layer addAnimation:ba forKey:nil];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}
-(void)setBackGroundImage:(UIImage *)backGroundImage
{
    _backGroundImage = backGroundImage;
    UIImageView *bgView = [[UIImageView alloc]initWithImage:[self.backGroundImage applyLightEffect]];
    bgView.frame = CGRectMake(0, 0, backGroundImage.size.width, backGroundImage.size.height);
    self.tableView.backgroundView = bgView;
    
}
-(void)customUI
{
    self.tableView.backgroundView = [[UIImageView alloc]initWithImage:self.backGroundImage];
    
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeBtn addTarget:self action:@selector(onCloseBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.closeBtn setImage:[UIImage loadImageNamed:@"选择话题btn"] forState:UIControlStateNormal];
    [self.view addSubview:self.closeBtn];
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-7);
        make.height.with.mas_equalTo(47);
    }];
    YYLabel *searchLabel = [[YYLabel alloc]initWithFrame:CGRectMake(13, 0, SCREEN_W-26, 30)];
    searchLabel.layer.borderWidth = SINGLE_LINE_WIDTH;
    searchLabel.layer.borderColor = [UIColor redColor].CGColor;
    
    UIFont *font =[UIFont systemFontOfSize:15];
    
    NSMutableAttributedString *searchPlaceHold = [NSMutableAttributedString new];
    UIImage *image = [UIImage imageNamed:@"搜索icon"];
    image = [UIImage imageWithCGImage:image.CGImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    NSMutableAttributedString *imgContent = [NSMutableAttributedString yy_attachmentStringWithContent:image contentMode:UIViewContentModeScaleAspectFit attachmentSize:CGSizeMake(15, 15) alignToFont:font alignment:YYTextVerticalAlignmentCenter];
    [searchPlaceHold appendAttributedString:imgContent];
    [searchPlaceHold appendAttributedString:[[NSAttributedString alloc] initWithString:@" 搜索更多PK话题" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexColorString:@"999999"],NSFontAttributeName:font}]];
    searchLabel.attributedText = searchPlaceHold;
    
    searchLabel.textAlignment = NSTextAlignmentCenter;
    searchPlaceHold.yy_alignment = NSTextAlignmentCenter;
    
    searchLabel.layer.cornerRadius = 15;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onSearchClick)];
    [searchLabel addGestureRecognizer:tap];
    self.tableView.tableHeaderView = searchLabel;
}
-(void)onSearchClick
{
    SearchTagViewController *shVC = [[SearchTagViewController alloc]initWithStyle:UITableViewStylePlain];
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:shVC];
    [navi setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:navi animated:YES completion:nil];
    
}
-(void)onCloseBtn:(UIButton *)sender
{
    CABasicAnimation* ba = [CABasicAnimation animationWithKeyPath:@"transform"];
    ba.autoreverses = NO;
    ba.duration = 0.3;
    ba.removedOnCompletion = NO;
    ba.fillMode = kCAFillModeForwards;
    ba.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI_4, 0, 0, 1)];
    [sender.layer addAnimation:ba forKey:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
    
}
#pragma mark ---tableView的代理
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
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
