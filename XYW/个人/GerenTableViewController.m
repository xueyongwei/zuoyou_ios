//
//  GerenTableViewController.m
//  HDJ
//
//  Created by xueyongwei on 16/6/30.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "GerenTableViewController.h"

@interface GerenTableViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet LDProgressView *TaskProgressView;
@property (nonatomic,strong)UIView *tbHdView;
@end

@implementation GerenTableViewController
{
    float autoH;
}
-(UIView *)tbHdView
{
    if (!_tbHdView) {
        _tbHdView = [[[NSBundle mainBundle]loadNibNamed:@"GerenTBHeadView" owner:self options:nil]lastObject];
        [self customProgressView:self.TaskProgressView];
    }
    return _tbHdView;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self customNavi];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self customTbaleView];
    [self customFeGexian];
    
}

-(void)customFeGexian
{
    self.FGCH.constant = 1/[UIScreen mainScreen].scale;
    self.FGXH1.constant = 1/[UIScreen mainScreen].scale;
    self.FGXH2.constant = 1/[UIScreen mainScreen].scale;
    self.FGXH3.constant = 1/[UIScreen mainScreen].scale;
    self.FGXH4.constant = SINGLE_LINE_WIDTH;
}
-(void)customProgressView:(LDProgressView*)progressView
{
    progressView.color = [UIColor redColor];
    progressView.flat = @YES;
    progressView.showText = @NO;
    progressView.showBackgroundInnerShadow = @NO;
    progressView.progress = 0.30;
    progressView.animate = @YES;
    progressView.background = [UIColor colorWithHexColorString:@"e6e6e6"];
}


-(void)customTbaleView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
//        self.tableView.sectionHeaderHeight = 268;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}
-(void)customNavi
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 60, 16)];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithHexColorString:@"333333"];
    label.text = @"我";
    label.font = [UIFont systemFontOfSize:17];
    self.tabBarController.navigationItem.titleView = label;
    
    UIButton *setBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [setBtn setImage:[UIImage imageNamed:@"设置"] forState:UIControlStateNormal];
    setBtn.frame = CGRectMake(0, 0, 18, 18);
    [setBtn addTarget:self action:@selector(onSetClick:) forControlEvents:UIControlEventTouchUpInside];
    self.tabBarController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:setBtn];
    
}
-(void)onSetClick:(UIButton *)sender
{
    SettingViewController *setVC = [[SettingViewController alloc]initWithNibName:@"SettingViewController" bundle:nil];
    [self.navigationController pushViewController:setVC animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"renwuCellID"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"renwuCellID"];
    }
    return cell;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.tbHdView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 380;
    //    return self.tbHdView.frame.size.height;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1f;
}

#pragma mark - Item CLick

- (IBAction)onUserClick:(UIButton *)sender {
    EditGerenViewController *egVC = [[EditGerenViewController alloc]initWithNibName:@"EditGerenViewController" bundle:nil];
    [self.tabBarController.navigationController pushViewController:egVC animated:YES];
    //    [self.navigationController pushViewController:egVC animated:YES];
}
- (IBAction)onZhanghuClick:(UIButton *)sender {
    ChongZhiViewController *czVC = [[ChongZhiViewController alloc]initWithNibName:@"ChongZhiViewController" bundle:nil];
    [self.navigationController pushViewController:czVC animated:YES];
}
- (IBAction)onXiaoxiClick:(UIButton *)sender {
    XiaoxiViewController *xxVC = [[XiaoxiViewController alloc]initWithNibName:@"XiaoxiViewController" bundle:nil];
    [self.navigationController pushViewController:xxVC animated:YES];
}
- (IBAction)onShouYiClick:(UIButton *)sender {
    ShouYiTableViewController *syVC =[[ShouYiTableViewController alloc]initWithNibName:@"ShouYiTableViewController" bundle:nil];
    [self.navigationController pushViewController:syVC animated:YES];
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
