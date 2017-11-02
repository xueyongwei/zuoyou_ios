//
//  TagDetailTableViewController.m
//  ZuoYou
//
//  Created by xueyognwei on 17/1/22.
//  Copyright © 2017年 xueyongwei. All rights reserved.
//

#import "TagDetailTableViewController.h"
#import "VersusListViewController.h"
#import "VideoListViewController.h"
#import "TagDetailitmHeaderView.h"
@interface TagDetailTableViewController ()
@property (nonatomic,assign)NSInteger currentIndex;
@end

@implementation TagDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customChildrenVC];
    // Do any additional setup after loading the view.
}
-(void)customChildrenVC
{
    //热战区
    VersusListViewController *rzVC = [[VersusListViewController alloc]initWithStyle:UITableViewStylePlain];
    rzVC.requestURL = [NSString stringWithFormat:@"/versus/search?tagId=%@&stage=start",self.tagID];
    rzVC.noMoreDataMessage = @"暂时没有正在进行中的PK";
    rzVC.noMoreDataPage = YES;
    [self addChildViewController:rzVC];
    [rzVC viewDidLoad];
    //挑战区
    VideoListViewController *tzVC = [[VideoListViewController alloc]initWithStyle:UITableViewStylePlain];
    //    tzVC.view.frame = self.view.bounds;
    tzVC.tagID = self.tagID;
    tzVC.tagName = self.tagName;
    [self addChildViewController:tzVC];
    [tzVC viewDidLoad];
    //已结束
    VersusListViewController *dmVC = [[VersusListViewController alloc]initWithStyle:UITableViewStylePlain];
    dmVC.requestURL = [NSString stringWithFormat:@"/versus/search?tagId=%@&stage=end",self.tagID];
    dmVC.noMoreDataMessage = @"暂时没有已经结束的PK";
    [self addChildViewController:dmVC];
    [dmVC viewDidLoad];
    
    self.currentIndex = 0;
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section ==0) {
        return 1;
    }
    ZYTableViewController *zyTVC = self.childViewControllers[self.currentIndex];
    
    return [zyTVC tableView:zyTVC.tableView numberOfRowsInSection:section];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section ==0) {
        return nil;
    }
    TagDetailitmHeaderView *hf = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"itmHeaderView"];
    if (!hf) {
        hf = [[TagDetailitmHeaderView alloc] initWithReuseIdentifier:@"itmHeaderView"];
//        hf.delegate = self;
    }
    return hf;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section==0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
        }
        cell.textLabel.text = @"这个是话题的描述啊，呵呵呵呵呵额";
        return cell;
    }else{
        ZYTableViewController *zyTVC = self.childViewControllers[self.currentIndex];
        return [zyTVC tableView:zyTVC.tableView cellForRowAtIndexPath:indexPath];
//        XYWTableViewDelegate *delegete = self.tableViewDelegates[self.currentIndex];
//        return [delegete tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@",indexPath);
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0?0.1:50;
}
-(void)TagDetailitmHeaderViewOnItmSelect:(NSInteger)index
{
    self.currentIndex = index;
    [self.tableView reloadData];
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
