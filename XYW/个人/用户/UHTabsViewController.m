//
//  UHTabsViewController.m
//  ZuoYou
//
//  Created by xueyongwei on 16/9/19.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "UHTabsViewController.h"

@interface UHTabsViewController ()

@end

@implementation UHTabsViewController
-(void)cannotScroll
{
    self.scrollView.userInteractionEnabled =YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
// UHexploitsTableViewController *hep = [[UHexploitsTableViewController alloc]init];
//    [self addChildViewController:hep];
//    [self.view addSubview:hep.view];
    [self xywInit];
    
    // Do any additional setup after loading the view from its nib.
}
-(void)xywInit
{
    self.scrollView.pagingEnabled = YES;
    
    {
        UHexploitsTableViewController *hep = [[UHexploitsTableViewController alloc]init];
        hep.tableView.scrollEnabled = NO;
        [self addChildViewController:hep];
        [self.scrollView addSubview:hep.view];
        hep.view.frame = CGRectMake(0, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
    }{
        UHVideosTableViewController *hvd = [[UHVideosTableViewController alloc]initWithStyle:UITableViewStyleGrouped];
        hvd.tableView.scrollEnabled = NO;
        [self addChildViewController:hvd];
        [self.scrollView addSubview:hvd.view];
        hvd.view.frame = CGRectMake(SCREEN_W, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
    }{
        UHCaresTableViewController *hcr = [UHCaresTableViewController new];
        hcr.tableView.scrollEnabled = NO;
        [self addChildViewController:hcr];
        [self.scrollView addSubview:hcr.view];
        hcr.view.frame = CGRectMake(SCREEN_W*2, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
    }{
        UHFansTableViewController *hfs = [UHFansTableViewController new];
        hfs.tableView.scrollEnabled = NO;
        [self addChildViewController:hfs];
        [self.scrollView addSubview:hfs.view];
        hfs.view.frame = CGRectMake(SCREEN_W*3, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
    }
    
    self.scrollView.contentSize = CGSizeMake(SCREEN_W*4, 0);
    
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
