//
//  UserHomeTableViewController.m
//  ZuoYou
//
//  Created by xueyongwei on 16/9/18.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "UserHomeTableViewController1.h"
@interface UserHomeTableViewController1 ()

@end

@implementation UserHomeTableViewController1
//-(void)setTopSpaceHeight:(CGFloat)TopSpaceHeight
//{
//    self.tableView.contentInset = UIEdgeInsetsMake(TopSpaceHeight + 70,0,0,0);
//    CGPoint NowOffset = self.tableView.contentOffset;
//    NowOffset.y -= self.TopSpaceHeight;
//    
//    NowOffset.y += TopSpaceHeight;
//    DbLog(@" set new offsetY %f",NowOffset.y);
//    self.tableView.contentOffset = NowOffset;
//    _TopSpaceHeight  = TopSpaceHeight;
////    [self.tableView reloadData];
//}
//-(void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    CGPoint NowOffset = CGPointMake(0, self.TopSpaceHeight);
//    self.tableView.contentOffset = NowOffset;
//}
//-(void)viewDidAppear:(BOOL)animated
//{
//    CGFloat offsetY = self.tableView.contentOffset.y;
//    
//}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
}
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    // 获取当前偏移量
//    CGFloat offsetY = scrollView.contentOffset.y;
//    DbLog(@"offsetY %f",offsetY);
//    
//    CGFloat cons = (-offsetY)-70;
//    self.TopConst.constant = cons>=0?cons:0;
//    
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
