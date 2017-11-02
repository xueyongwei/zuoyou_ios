//
//  DengluXieyiViewController.m
//  HDJ
//
//  Created by xueyongwei on 16/6/1.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "DengluXieyiViewController.h"
#import "SchemesModel.h"
@interface DengluXieyiViewController ()

@end

@implementation DengluXieyiViewController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"登录协议页面"];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"左右服务协议&隐私条款";
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"用户协议.html" withExtension:nil];
    
    //uiwebview加载文件的第二个方式。第一个方式在下面的注释中。
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.tableView loadRequest:request];
    // Do any additional setup after loading the view from its nib.
}
-(void)checkWaitingSchemes
{
    DbLog(@"捕获了打开应用的检测，但是没有登录我不处理。");
}
-(void)schemesListen:(NSNotification *)noti
{
    DbLog(@"捕获了打开应用的通知，但是没有登录我保存在本地不做处理。");
    DbLog(@"class = %@",NSStringFromClass(self.class));
    DbLog(@"listen %@",noti);
    //保存起来，等登录后再发一次通知
    NSDictionary *dic = noti.object;
    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
    [usf setObject:dic forKey:@"SCHEMES"];
    [usf synchronize];
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
