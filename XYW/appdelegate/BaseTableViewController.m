//
//  BaseTableViewController.m
//  ZuoYou
//
//  Created by xueyongwei on 16/9/13.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "BaseTableViewController.h"
#import "PKDetailViewController.h"
#import "SchemesModel.h"

@interface BaseTableViewController ()

@end

@implementation BaseTableViewController
-(NSMutableDictionary *)userDataDic
{
    if (!_userDataDic) {
        _userDataDic = [NSMutableDictionary new];
    }
    return _userDataDic;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexColorString:@"f4f4f4"];
    self.tableView.backgroundColor = [UIColor colorWithHexColorString:@"f4f4f4"];
    [self customNavi];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self prepareSchemes];
    
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self removeSchemeNoti];
}
-(void)removeSchemeNoti
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"SCHEMES" object:nil];
}
-(void)prepareSchemes
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(schemesListen:) name:@"SCHEMES" object:nil];
}

-(void)schemesListen:(NSNotification *)noti
{
    DbLog(@"class = %@",NSStringFromClass(self.class));
    DbLog(@"listen %@",noti);
    NSDictionary *dic = noti.object;
    SchemesModel *model = [SchemesModel mj_objectWithKeyValues:dic];
    if (model.pkID&&model.pkID>0) {
        PKDetailViewController *dvc = [[PKDetailViewController alloc]initWithNibName:@"PKDetailViewController" bundle:nil];
        dvc.pkId = model.pkID;
        [self.navigationController pushViewController:dvc animated:YES];
    }
}

-(void)customNavi{//自定义了返回键和标题栏属性，之类请继承不覆盖
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -3;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 60, 30);
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [btn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"back_click"] forState:UIControlStateHighlighted];
    
    [btn addTarget:self action:@selector(onBackClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.leftBarButtonItems = @[negativeSpacer,leftBar];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor colorWithHexColorString:@"333333"]}];
    
}
-(void)onBackClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    DbLog(@"清理内存图片缓解内存压力");
    //清理一下图片内存缓存。
    [[SDImageCache sharedImageCache] clearMemory];
    
}


@end
