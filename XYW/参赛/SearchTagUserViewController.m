//
//  SearchTagViewController.m
//  ZuoYou
//
//  Created by xueyongwei on 16/11/3.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "SearchTagUserViewController.h"
#import "YYLabel.h"
#import "YYText.h"
#import "tagModel.h"
#import "TagTableViewCell.h"
#import "VideoListViewController.h"
#import "SearchUsersTableViewCell.h"
#import "UHCenterViewController.h"
#import "TagDetailViewController.h"
#define KHISTORYID @"SearchHistory"

@interface SearchTagUserViewController ()<UITextFieldDelegate>
@property (nonatomic,strong) UITextField *searchTF;
@property (nonatomic,strong)UILabel *noDataLabel;
@property (nonatomic,copy)NSString *whatUinput;
@end

@implementation SearchTagUserViewController
-(UILabel *)noDataLabel
{
    if (!_noDataLabel) {
        _noDataLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_W/2-100, SCREEN_H/3, 200, 21)];
        _noDataLabel.textAlignment = NSTextAlignmentCenter;
        _noDataLabel.text = @"没有找到，换个姿势再来一次";
        _noDataLabel.font = [UIFont systemFontOfSize:14];
        _noDataLabel.textColor = [UIColor colorWithHexColorString:@"999999"];
    }
    return _noDataLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customTableView];
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    static BOOL firstAppear = YES;
    if (firstAppear) {
        [self.searchTF becomeFirstResponder];
        firstAppear = NO;
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.searchTF.text = self.whatUinput;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.searchTF resignFirstResponder];
}
#pragma mark ---UI相关
-(void)customTableView
{
    for (int i = 0; i<2; i++) {
        NSMutableArray *arr = [NSMutableArray new];
        [self.dataSource addObject:arr];
    }
    UIView *tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_W, 10)];
    self.tableView.tableHeaderView = tableHeaderView;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.automaticallyAdjustsScrollViewInsets = YES;
    [self loadHistory];
}

-(void)customNavi
{
    [super customNavi];
    
    self.searchTF = [[UITextField alloc]initWithFrame:CGRectMake(13, 0, SCREEN_W-76, 30)];
    self.searchTF.layer.borderWidth = SINGLE_LINE_WIDTH;
    self.searchTF.layer.borderColor = [UIColor redColor].CGColor;
    self.searchTF.layer.cornerRadius = 15;
    self.searchTF.font = [UIFont systemFontOfSize:15];
    self.searchTF.leftViewMode = UITextFieldViewModeAlways;
    self.searchTF.returnKeyType = UIReturnKeySearch;
    self.searchTF.placeholder = @"搜索用户和话题";
    //    self.searchTF.textColor = [UIColor colorWithHexColorString:@"999999"];
    self.searchTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.searchTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.searchTF.delegate = self;
    UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 15)];
    imgV.contentMode = UIViewContentModeScaleAspectFit;
    imgV.image = [UIImage imageNamed:@"搜索icon"];
    self.searchTF.leftView = imgV;
    
    
    self.navigationItem.titleView = self.searchTF;
    
    UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancleBtn.frame = CGRectMake(0, 0, 50, 30);
    cancleBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [cancleBtn setTitleColor:[UIColor colorWithHexColorString:@"333333"] forState:UIControlStateNormal];
    cancleBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [cancleBtn addTarget:self action:@selector(onCancleClick) forControlEvents:UIControlEventTouchUpInside];
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    UIBarButtonItem *bar = [[UIBarButtonItem alloc]initWithCustomView:cancleBtn];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -5;//修正间隙
    
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,bar];
}

#pragma mark ---数据相关
-(void)searchTag
{
    [self.tableView reloadData];
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@/tag/searchTagAndMember",HeadUrl] parameters:@{@"key":self.searchTF.text,@"pn":@"1"} inView:nil sucess:^(id result) {
        DbLog(@"%@",result);
        [self.dataSource.firstObject removeAllObjects];
        [self.dataSource.lastObject removeAllObjects];
        
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSArray *members = [result objectForKey:@"members"];
            if (members.count>0) {
                NSMutableArray *memberSource = self.dataSource.firstObject;
                for (NSDictionary *dic in members) {
                    UserInfoModel *user = [UserInfoModel mj_objectWithKeyValues:dic];
                    [memberSource addObject:user];
                }
            }
            
            NSArray *tags = [result objectForKey:@"tags"];
            if (tags.count>0) {
                NSMutableArray *tagSource = self.dataSource.lastObject;
                for (NSDictionary *dic in tags) {
                    tagModel *tag = [tagModel mj_objectWithKeyValues:dic];
                    [tagSource addObject:tag];
                }
            }
            [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
        
    }];
}
#pragma mark ---tableView的代理
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger total = [self.dataSource[0] count]+ [self.dataSource[1] count];
    
    if (total==0 && self.searchTF.text.length>0) {
        if (self.searchTF.text.length==1) {
            //一个字的时候空白
            if (self.noDataLabel.superview) {
                [self.noDataLabel removeFromSuperview];
            }
        }else{
            [self.tableView addSubview:self.noDataLabel];
        }
        
    }else{
        if (self.noDataLabel.superview) {
            [self.noDataLabel removeFromSuperview];
        }
    }
    return self.dataSource.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [self.dataSource[section] count];
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section ==0) {
        return [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0.1)];
    }
    UIButton *clearHistoryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    clearHistoryBtn.frame = CGRectMake(0, 0, SCREEN_W, 40);
    clearHistoryBtn.backgroundColor = [UIColor whiteColor];
    clearHistoryBtn.clipsToBounds = YES;
    [clearHistoryBtn setTitle:@"清空搜索记录" forState:UIControlStateNormal];
    clearHistoryBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [clearHistoryBtn setTitleColor:[UIColor colorWithHexColorString:@"999999"] forState:UIControlStateNormal];
    [clearHistoryBtn addTarget:self action:@selector(onClearHistoryClick:) forControlEvents:UIControlEventTouchUpInside];
    clearHistoryBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    
    return clearHistoryBtn;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.01;
    }
    NSInteger total = [self.dataSource[0] count]+ [self.dataSource[1] count];
    return self.searchTF.text.length>0?0.01:total>0?40.0:0.01;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section ==0) {
        SearchUsersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchUsersTableViewCell"];
        if (!cell) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"SearchUsersTableViewCell" owner:self options:nil]lastObject];
        }
        UserInfoModel *user = self.dataSource[indexPath.section][indexPath.row];
        [UserInfoManager setNameLabel:cell.userNameLabel headImageV:cell.userIconImageVIew corverImageV:cell.userCorverImageView with:@(user.mid)];
        return cell;
    }
    TagTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TagTableViewCell"];
    if (!cell) {
        cell =[[[NSBundle mainBundle]loadNibNamed:@"TagTableViewCell" owner:self options:nil]lastObject];
    }
    if (self.searchTF.text.length>0) {
        cell.IconConstH.constant = 0;
    }else{
        cell.iconImgV.image = [UIImage imageNamed:@"历史_icon"];
        cell.iconHeightconst.constant = 20;
        cell.IconConstH.constant = 30;
    }
    
    tagModel *model = self.dataSource[indexPath.section][indexPath.row];
    if (model.activity) {
        cell.tagNameLabel.attributedText = [self attributedTagName:model.formatertagName];
    }else{
        cell.tagNameLabel.text = model.formatertagName;
    }
//    cell.tagNameLabel.text = model.formatertagName;
    cell.idxLabel.text = @"";
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section==0?55:40;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section ==0) {//用户
        NSArray *users = self.dataSource[0];
        UserInfoModel *user = users[indexPath.row];
        UHCenterViewController *uc = [[UHCenterViewController alloc]init];
        uc.mid = user.mid;
        uc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:uc animated:YES];
        return;
    }
    NSArray *tags = self.dataSource[1];
    
    tagModel *model = tags[indexPath.row];
    [self saveHistory:model];
//    self.searchTF.text = model.tagName;
    
    
    TagDetailViewController *tgDetailVC = [[TagDetailViewController alloc]initWithNibName:@"TagDetailViewController" bundle:nil];
    tgDetailVC.tagID = model.tagID;
    tgDetailVC.tagName = model.formatertagName;
    tgDetailVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:tgDetailVC animated:YES];
}

#pragma mark ---action的handle
-(void)onClearHistoryClick:(UIButton *)sender
{
    NSUserDefaults *usdf = [NSUserDefaults standardUserDefaults];
    NSMutableArray *savedHistoryArr = [NSMutableArray arrayWithArray:[usdf objectForKey:KHISTORYID]];
    [savedHistoryArr removeAllObjects];
    [usdf setObject:savedHistoryArr forKey:KHISTORYID];
    [usdf synchronize];
    [self.dataSource.lastObject removeAllObjects];
    [self.tableView reloadData];
}
-(void)onCancleClick
{
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark ---taxtField代理方法
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length>0) {
        [self searchTag];
    }
    return YES;
}
-(void)textFieldDidChange:(UITextField *)textField
{
    self.whatUinput = self.searchTF.text;
    UITextRange *selectedRange = [textField markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textField positionFromPosition:selectedRange.start offset:0];
    
    //如果在变化中是高亮部分在变，就不要计算字符了
    if (selectedRange && pos) {
        return;
    }
    
    if(textField.text.length==0){
        [self loadHistory];
    }else if (textField.text.length ==1){
        [self.dataSource.firstObject removeAllObjects];
        [self.dataSource.lastObject removeAllObjects];
        [self.tableView reloadData];
    }else if(textField.text.length>1){
        [self searchTag];
    }
}
#pragma mark 本地纪录
-(void)loadHistory
{
    [self.dataSource.firstObject removeAllObjects];
    [self.dataSource.lastObject removeAllObjects];
    NSUserDefaults *usdf = [NSUserDefaults standardUserDefaults];
    NSMutableArray *savedHistoryArr = [usdf objectForKey:KHISTORYID];
    NSMutableArray *tasSource = self.dataSource.lastObject;
    for (NSData *modelData in savedHistoryArr) {
        tagModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:modelData];
        [tasSource addObject:model];
    }
    [self.tableView reloadData];
}
-(void)saveHistory:(tagModel *)model
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUserDefaults *usdf = [NSUserDefaults standardUserDefaults];
        
        
        NSMutableArray *savedHistoryArr = [NSMutableArray arrayWithArray:[usdf objectForKey:KHISTORYID]];
        if (savedHistoryArr.count == 10) {
            [savedHistoryArr removeObjectAtIndex:9];
        }
        
        [savedHistoryArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            tagModel *localModel = [NSKeyedUnarchiver unarchiveObjectWithData:obj];
            if (localModel.tagID.integerValue == model.tagID.integerValue) {
                *stop = YES;
                if (*stop == YES) {
                    [savedHistoryArr removeObjectAtIndex:idx];
                }
            }
        }];
        NSData *modelData = [NSKeyedArchiver archivedDataWithRootObject:model];
        [savedHistoryArr insertObject:modelData atIndex:0];
        
        [usdf setObject:savedHistoryArr forKey:KHISTORYID];
        [usdf synchronize];
    });
}
//-(void)saveHistory
//{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSUserDefaults *usdf = [NSUserDefaults standardUserDefaults];
//        NSMutableArray *savedHistoryArr = [NSMutableArray arrayWithArray:[usdf objectForKey:KHISTORYID]];
//        NSString *tagName = self.searchTF.text;
//        [savedHistoryArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            tagModel *localModel = [NSKeyedUnarchiver unarchiveObjectWithData:obj];
//            if ([localModel.tagName isEqualToString:tagName]) {
//                *stop = YES;
//                if (*stop == YES) {
//                    [savedHistoryArr removeObjectAtIndex:idx];
//                }
//            }
//        }];
//        tagModel *model = [tagModel new];
//        model.tagName = tagName;
//        NSData *modelData = [NSKeyedArchiver archivedDataWithRootObject:model];
//        [savedHistoryArr insertObject:modelData atIndex:0];
//        [usdf setObject:savedHistoryArr forKey:KHISTORYID];
//        [usdf synchronize];
//    });
//}
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
