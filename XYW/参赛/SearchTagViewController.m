//
//  SearchTagViewController.m
//  ZuoYou
//
//  Created by xueyongwei on 16/11/3.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "SearchTagViewController.h"
#import "YYLabel.h"
#import "YYText.h"
#import "tagModel.h"
#import "TagTableViewCell.h"
#import "VideoListViewController.h"
#import "NoDataView.h"
#import "CaptureViewController.h"
#import "CreatNewTagViewController.h"

#define KHISTORYID @"SearchTagHistory"

@interface SearchTagViewController ()<UITextFieldDelegate>
@property (nonatomic,strong) UITextField *searchTF;
@property (nonatomic,strong)NoDataView *nodataView;
@property (nonatomic,copy)NSString *whatUinput;
@property (nonatomic,assign)BOOL firstAppear;
@end

@implementation SearchTagViewController
-(NoDataView *)nodataView
{
    if (!_nodataView) {
        _nodataView = [[[NSBundle mainBundle]loadNibNamed:@"NoDataView" owner:self options:nil]lastObject];
        _nodataView.msgLabel.text = @"没有找到想要PK的话题？自己创建吧！";
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"创建新话题" forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor colorWithHexColorString:@"ff4a4b"];
        btn.clipsToBounds = YES;
        btn.layer.cornerRadius = 5;
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(onCreatNewTag) forControlEvents:UIControlEventTouchUpInside];
        [_nodataView addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_nodataView);
            make.left.equalTo(_nodataView).with.offset(8);
            make.right.equalTo(_nodataView).with.offset(-8);
            make.height.mas_equalTo(50);
        }];
    }
    return _nodataView;
}
-(void)endRecoder{
    [self dismissViewControllerAnimated:NO completion:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self customTableView];
    self.firstAppear = YES;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(endRecoder) name:kCaptureViewControllerStopRecod object:nil];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.firstAppear) {
        [self.searchTF becomeFirstResponder];
        self.firstAppear = NO;
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
    self.searchTF.placeholder = @"搜索更多PK话题";
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
    [self.dataSource removeAllObjects];
    [self.tableView reloadData];
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@/tag/search",HeadUrl] parameters:@{@"key":self.searchTF.text,@"pn":@"1"} inView:nil sucess:^(id result) {
        DbLog(@"%@",result);
        if ([result isKindOfClass:[NSArray class]]) {
            [self.dataSource removeAllObjects];
            for (NSDictionary *dic in result) {
                tagModel *model = [tagModel mj_objectWithKeyValues:dic];
                [self.dataSource addObject:model];
            }
            [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
        
    }];
}
#pragma mark ---tableView的代理
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.dataSource.count==0 && self.searchTF.text.length>0) {
        if (self.searchTF.text.length==1) {
            //一个字的时候空白
            if (self.nodataView.superview) {
                [self.nodataView removeFromSuperview];
            }
        }else{
            [self.tableView addSubview:self.nodataView];
            [self.nodataView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.tableView);
                make.centerX.equalTo(self.tableView);
                make.height.mas_equalTo(self.tableView.mas_width).multipliedBy(0.8);
                make.width.mas_equalTo(self.tableView.mas_width);
            }];
        }
        
    }else{
        if (self.nodataView.superview) {
            [self.nodataView removeFromSuperview];
        }
    }
    return self.dataSource.count;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
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
    return self.searchTF.text.length>0?0.1:self.dataSource.count>0?40.0:0.1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    
    tagModel *model = self.dataSource[indexPath.row];
    if (model.activity) {
        cell.tagNameLabel.attributedText = [self attributedTagName:model.formatertagName];
    }else{
        cell.tagNameLabel.text = model.formatertagName;
    }
    
    cell.idxLabel.text = @"";
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    tagModel *model = self.dataSource[indexPath.row];
    
//    if (self.searchTF.text.length>0) {//搜索出来的
//        [tableView deselectRowAtIndexPath:indexPath animated:YES];
//        VideoListViewController *tzVC = [[VideoListViewController alloc]initWithStyle:UITableViewStylePlain];
//        tzVC.tagID = model.tagID;
//        tzVC.title = model.tagName;
//        tzVC.hidesBottomBarWhenPushed = YES;
//        self.searchTF.text = model.tagName;
        [self saveHistory:model];
    
    CaptureVideoNavigationController *navCon = [[CaptureVideoNavigationController alloc] init];
    CaptureViewController *captureViewCon = [[CaptureViewController alloc] initWithNibName:@"CaptureViewController" bundle:nil];
    captureViewCon.tagId = model.tagID;
    captureViewCon.tagName = model.formatertagName;
    captureViewCon.challenge = @"false";
    [navCon pushViewController:captureViewCon animated:YES];
    [self.navigationController presentViewController:navCon animated:YES completion:nil];
    
//        UILabel *tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_W, 25)];
//        tipLabel.backgroundColor = [UIColor colorWithHexColorString:@"ff4a4b"];
//        tipLabel.textAlignment = NSTextAlignmentCenter;
//        tipLabel.textColor = [UIColor whiteColor];
//        tipLabel.font = [UIFont systemFontOfSize:12];
//        tipLabel.text = @"选择PK标签→直接上传视频/挑战TA→生成PK卡";
//        tzVC.tableView.tableHeaderView = tipLabel;
//        [self.navigationController pushViewController:tzVC animated:YES];
    
//    }else{
//        self.searchTF.text = model.tagName;
//        [self saveHistory];
//        [self.searchTF resignFirstResponder];
//        [self searchTag];
//    }
}

#pragma mark ---action的handle
-(void)onClearHistoryClick:(UIButton *)sender
{
    NSUserDefaults *usdf = [NSUserDefaults standardUserDefaults];
    NSMutableArray *savedHistoryArr = [NSMutableArray arrayWithArray:[usdf objectForKey:KHISTORYID]];
    [savedHistoryArr removeAllObjects];
    [usdf setObject:savedHistoryArr forKey:KHISTORYID];
    [usdf synchronize];
    [self.dataSource removeAllObjects];
    [self.tableView reloadData];
}
-(void)onCancleClick
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
-(void)onCreatNewTag
{
    CreatNewTagViewController *crtVC = [[CreatNewTagViewController alloc]initWithNibName:@"CreatNewTagViewController" bundle:nil];
    crtVC.inputText = self.searchTF.text;
    [self.navigationController pushViewController:crtVC animated:YES];
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
    self.whatUinput = textField.text;
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
        [self.dataSource removeAllObjects];
        [self.tableView reloadData];
    }else if(textField.text.length>1){
        [self searchTag];
    }
}
#pragma mark 本地纪录
-(void)loadHistory
{
    [self.dataSource removeAllObjects];
    NSUserDefaults *usdf = [NSUserDefaults standardUserDefaults];
    NSMutableArray *savedHistoryArr = [usdf objectForKey:KHISTORYID];
    
    for (NSData *modelData in savedHistoryArr) {
        tagModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:modelData];
        [self.dataSource addObject:model];
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
