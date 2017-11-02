//
//  PKFansViewController.m
//  HDJ
//
//  Created by xueyongwei on 16/6/7.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "PKFansViewController.h"

@interface PKFansViewController ()
@property (nonatomic,assign)NSInteger currentPage;
@end

@implementation PKFansViewController

-(NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [NSMutableArray new];
    }
    return _dataSource;
}
-(void)reloadNewWorkDataSource
{
    [self prepareData:1];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.delegate delegatePlayVideo];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"PK贡献榜";
    [self customTbaleView];
    self.currentPage = 1;
    [self prepareData:self.currentPage];
    // Do any additional setup after loading the view from its nib.
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"PK贡献榜页面"];
}
-(void)customTbaleView
{
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    __weak typeof(self) wkSelf = self;
    BangdanMjHeader *header = [BangdanMjHeader headerWithRefreshingBlock:^{
        wkSelf.currentPage = 1;
        [wkSelf prepareData:self.currentPage];
    }];
    header.frame = CGRectMake(0, 0, SCREEN_W, 60);
    self.tableView.mj_header = header;
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        DbLog(@"footer 我要 ");
        [wkSelf prepareData:self.currentPage];
    }];
}
#pragma mark --- 😊准备数据
-(void)prepareData:(NSInteger)page
{
    if (self.dataSource.count==0) {
        CoreSVPLoading(@"loading", YES);
    }
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@%@",HeadUrl,@"/versus/items"] parameters:@{@"id":[NSString stringWithFormat:@"%ld",(long)self.pkID],@"pn":[NSString stringWithFormat:@"%ld",(long)page]} inView:nil sucess:^(id result) {
        [CoreSVP dismiss];
        if (![result isKindOfClass:[NSArray class]]) {
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
            return ;
        }
        NSArray *rspArr = result;
        self.currentPage++;
        if (page == 1) {
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer resetNoMoreData];
            [self.dataSource removeAllObjects];
        }else{
            if (rspArr.count>0) {
                [self.tableView.mj_footer endRefreshing];
            }else{
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
        }
        
        if (rspArr) {
            for (NSDictionary *dic in rspArr) {
                BangDanModel *model = [BangDanModel mj_objectWithKeyValues:dic];
                [self.dataSource addObject:model];
            }
            [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
        [CoreSVP dismiss];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
    }];
    
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BangDanModel *model = self.dataSource[indexPath.row];
    
    if (indexPath.row ==0) {
        Bangdan1TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Bangdan1TableViewCell"];
        if (!cell) {
            cell = (Bangdan1TableViewCell*)[[[NSBundle mainBundle]loadNibNamed:@"Bangdan1TableViewCell" owner:self options:nil]lastObject];
            cell.iconImgV.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onUserTap:)];
            [cell.iconImgV addGestureRecognizer:tap];
            cell.delegate = self;
        }
        cell.model = model;
        NSString *roal = model.contestantRole;
        if ([roal isEqualToString:@"RED"]) {
            cell.userNameLabel.textColor = [UIColor colorWithHexColorString:@"ff4a4b"];
            cell.beansLabel.textColor =[UIColor colorWithHexColorString:@"ff4a4b"];
        }else{
            cell.userNameLabel.textColor = [UIColor colorWithHexColorString:@"03a9f3"];
            cell.beansLabel.textColor =[UIColor colorWithHexColorString:@"03a9f3"];
        }
        [self customZhenying:model.contestantRole withIcon:cell.iconImgV];
        [cell.mobaiBtn addTarget:self action:@selector(onMoBaiCLick:) forControlEvents:UIControlEventTouchDown];
        cell.iconImgV.tag = model.mid;
        cell.guanzhuBtn.tag = model.mid;
        
//        [UserInfoManager setNameLabel:cell.userNameLabel headImageV:cell.iconImgV with:@(model.mid)];
        NSMutableAttributedString *bensStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"贡献 %ld 豆子",(long)model.beansVal]];
        
        cell.beansLabel.attributedText = [self douziMiaoshuStr: bensStr];
        cell.canMoBai = NO;
//        NSDate *date = [[NSUserDefaults standardUserDefaults]objectForKey:@"mobaidate"];
//        if (date && [date isToday]) {
//            cell.mobaiBtn.userInteractionEnabled = NO;
//            cell.mobaiBtn.layer.borderColor = [UIColor colorWithHexColorString:@"cdcdcd"].CGColor;
//            [cell.mobaiBtn setBackgroundColor:[UIColor colorWithHexColorString:@"cdcdcd"]];
//            [cell.mobaiBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//            [cell.mobaiBtn setTitle:@"已膜拜" forState:UIControlStateNormal];
//        }else{
//            cell.mobaiBtn.userInteractionEnabled = YES;
//            cell.mobaiBtn.layer.borderColor = [UIColor colorWithHexColorString:@"ff4a4b"].CGColor;
//            [cell.mobaiBtn setTitleColor:[UIColor colorWithHexColorString:@"ff4a4b"] forState:UIControlStateNormal];
//            [cell.mobaiBtn setTitle:@"膜拜" forState:UIControlStateNormal];
//        }
        NSInteger statusIndex = model.isFollow ? model.isFans ? 2 : 1 : 0;
        [self setCareType:statusIndex Btn:cell.guanzhuBtn];
        
        
        return cell;
    }else if (indexPath.row==1){
        Bangdan2TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Bangdan2TableViewCell"];
        if (!cell) {
            cell = (Bangdan2TableViewCell*)[[[NSBundle mainBundle]loadNibNamed:@"Bangdan2TableViewCell" owner:self options:nil]lastObject];
            cell.iconImgV.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onUserTap:)];
            [cell.iconImgV addGestureRecognizer:tap];
            cell.delegate = self;
        }
        cell.model = model;
        NSString *roal = model.contestantRole;
        if ([roal isEqualToString:@"RED"]) {
            cell.userNameLabel.textColor = [UIColor colorWithHexColorString:@"ff4a4b"];
            cell.beansLabel.textColor =[UIColor colorWithHexColorString:@"ff4a4b"];
        }else{
            cell.userNameLabel.textColor = [UIColor colorWithHexColorString:@"03a9f3"];
            cell.beansLabel.textColor =[UIColor colorWithHexColorString:@"03a9f3"];
        }
        [self customZhenying:model.contestantRole withIcon:cell.iconImgV];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.iconImgV.tag = model.mid;
        cell.guanzhuBtn.tag = model.mid;
//        [UserInfoManager setNameLabel:cell.userNameLabel headImageV:cell.iconImgV with:@(model.mid)];
        NSMutableAttributedString *bensStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"贡献 %ld 豆子",(long)model.beansVal]];
        cell.beansLabel.attributedText = [self douziMiaoshuStr: bensStr];
        NSInteger statusIndex = model.isFollow ? model.isFans ? 2 : 1 : 0;
        [self setCareType:statusIndex Btn:cell.guanzhuBtn];
        return cell;
    }else if (indexPath.row ==2){
        Bangdan3TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Bangdan3TableViewCell"];
        if (!cell) {
            cell = (Bangdan3TableViewCell*)[[[NSBundle mainBundle]loadNibNamed:@"Bangdan3TableViewCell" owner:self options:nil]lastObject];
            cell.iconImgV.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onUserTap:)];
            [cell.iconImgV addGestureRecognizer:tap];
            cell.delegate = self;
        }
        cell.model = model;
        NSString *roal = model.contestantRole;
        if ([roal isEqualToString:@"RED"]) {
            cell.userNameLabel.textColor = [UIColor colorWithHexColorString:@"ff4a4b"];
            cell.beansLabel.textColor =[UIColor colorWithHexColorString:@"ff4a4b"];
        }else{
            cell.userNameLabel.textColor = [UIColor colorWithHexColorString:@"03a9f3"];
            cell.beansLabel.textColor =[UIColor colorWithHexColorString:@"03a9f3"];
        }
        [self customZhenying:model.contestantRole withIcon:cell.iconImgV];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.iconImgV.tag = model.mid;
        cell.guanzhuBtn.tag = model.mid;
//        [UserInfoManager setNameLabel:cell.userNameLabel headImageV:cell.iconImgV with:@(model.mid)];
        NSMutableAttributedString *bensStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"贡献 %ld 豆子",(long)model.beansVal]];
        cell.beansLabel.attributedText = [self douziMiaoshuStr: bensStr];
        NSInteger statusIndex = model.isFollow ? model.isFans ? 2 : 1 : 0;
        [self setCareType:statusIndex Btn:cell.guanzhuBtn];
        return cell;
        
    }
    BangdanTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BangdanTableViewCell"];
    if (!cell) {
        cell = (BangdanTableViewCell*)[[[NSBundle mainBundle]loadNibNamed:@"BangdanTableViewCell" owner:self options:nil]lastObject];
        cell.iconImgV.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onUserTap:)];
        [cell.iconImgV addGestureRecognizer:tap];
        cell.delegate = self;
    }
    cell.bangdanJiaobiaoLabel.text = [NSString stringWithFormat:@"%d",(int)indexPath.row+1];
    cell.model = model;
    NSString *roal = model.contestantRole;
    if ([roal isEqualToString:@"RED"]) {
        cell.userNameLabel.textColor = [UIColor colorWithHexColorString:@"ff4a4b"];
        cell.beansLabel.textColor =[UIColor colorWithHexColorString:@"ff4a4b"];
    }else{
        cell.userNameLabel.textColor = [UIColor colorWithHexColorString:@"03a9f3"];
        cell.beansLabel.textColor =[UIColor colorWithHexColorString:@"03a9f3"];
    }
    [self customZhenying:model.contestantRole withIcon:cell.iconImgV];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.iconImgV.tag = model.mid;
    cell.guanzhuBtn.tag = model.mid;
//    [UserInfoManager setNameLabel:cell.userNameLabel headImageV:cell.iconImgV with:@(model.mid)];
    cell.userNameLabel.tag = model.mid;
    NSMutableAttributedString *bensStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"贡献 %ld 豆子",(long)model.beansVal]];
    cell.beansLabel.attributedText = [self douziMiaoshuStr: bensStr];
    if (indexPath.row == self.dataSource.count-1) {
        cell.fengeLabelH.constant = 0;
    }else{
        cell.fengeLabelH.constant = SINGLE_LINE_WIDTH;
    }
    NSInteger statusIndex = model.isFollow ? model.isFans ? 2 : 1 : 0;
    [self setCareType:statusIndex Btn:cell.guanzhuBtn];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0) {
        return 175;
        //            return 150;
    }else if (indexPath.row<3){
        return 130;
    }
    return 65;
}
/**
 *  用户的阵营
 *
 */
-(void)customZhenying:(NSString *)roal withIcon:(UIImageView *)imgV
{
    imgV.layer.borderWidth = 1;
//    imgV.clipsToBounds = YES;
    imgV.layer.borderColor = [roal isEqualToString:@"RED"]?[UIColor colorWithHexColorString:@"f44236"].CGColor:[UIColor colorWithHexColorString:@"03a9f3"].CGColor;
}
-(void)onUserTap:(UITapGestureRecognizer *)recognizer
{
    UHCenterViewController *uh = [[UHCenterViewController alloc]init];
    uh.mid = recognizer.view.tag;
    uh.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:uh animated:YES];
}
#pragma mark ---膜拜
- (void)onMoBaiCLick:(UIButton *)sender {
    BangDanModel *model = self.dataSource.firstObject;
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@%@",HeadUrl,@"/social/worship"] parameters:@{@"mid":[NSString stringWithFormat:@"%ld",(long)model.mid]} inView:nil sucess:^(id result) {
        [self.tableView.mj_header endRefreshing];
        if (result) {
            if ([result objectForKey:@"code"]) {
                CoreSVPCenterMsg([result objectForKey:@"msg"]);
                [self saveMobaiTime];
            }else{
                NSString *errcode = [result objectForKey:@"errCode"];
                if (errcode.integerValue == 1011) {
                    NSDate *date = [NSDate date];
                    [[NSUserDefaults standardUserDefaults]setObject:date forKey:@"mobaidate"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [self.tableView reloadData];
                }
                CoreSVPCenterMsg([result objectForKey:@"errMsg"]);
            }
        }
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
    }];
}
-(void)saveMobaiTime{
    //存储膜拜时间
    NSDate *date = [NSDate date];
    [[NSUserDefaults standardUserDefaults]setObject:date forKey:@"mobaidate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.tableView reloadData];
    [TalkingDataGA onEvent:KDIANJIMOBAI eventData:@{@"点击_膜拜":@(1)}];
    [self prepareData:1];
}
-(NSMutableAttributedString *)douziMiaoshuStr:(NSMutableAttributedString *)bensStr
{
    
    [bensStr addAttribute:NSForegroundColorAttributeName
                    value:[UIColor colorWithHexColorString:@"777777"]
                    range:NSMakeRange(0, 2)];
    [bensStr addAttribute:NSFontAttributeName
                    value:[UIFont systemFontOfSize:11]
                    range:NSMakeRange(0, 2)];
    
    
    [bensStr addAttribute:NSForegroundColorAttributeName
                    value:[UIColor colorWithHexColorString:@"777777"]
                    range:NSMakeRange(bensStr.length-2, 2)];
    [bensStr addAttribute:NSFontAttributeName
                    value:[UIFont systemFontOfSize:11]
                    range:NSMakeRange(bensStr.length-2, 2)];
    return bensStr;
}
-(void)setCareType:(NSInteger)type Btn:(UIButton *)guanzhuBtn
{
    switch (type) {
        case 0:
        {
            [guanzhuBtn setTitle:@"关注" forState:UIControlStateNormal];
            [guanzhuBtn setTitleColor:[UIColor colorWithHexColorString:@"ff4a4b"] forState:UIControlStateNormal];
            guanzhuBtn.layer.borderColor = [UIColor colorWithHexColorString:@"ff4a4b"].CGColor;
            guanzhuBtn.selected = NO;
        }
            break;
        case 1:
        {
            [guanzhuBtn setTitle:@"已关注" forState:UIControlStateNormal];
            [guanzhuBtn setTitleColor:[UIColor colorWithHexColorString:@"999999"] forState:UIControlStateNormal];
            guanzhuBtn.layer.borderColor = [UIColor colorWithHexColorString:@"999999"].CGColor;
            guanzhuBtn.selected = YES;
        }
            break;
        case 2:
        {
            [guanzhuBtn setTitle:@"互相关注" forState:UIControlStateNormal];
            [guanzhuBtn setTitleColor:[UIColor colorWithHexColorString:@"999999"] forState:UIControlStateNormal];
            guanzhuBtn.layer.borderColor = [UIColor colorWithHexColorString:@"999999"].CGColor;
            guanzhuBtn.selected = YES;
        }
            break;
        default:
            break;
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
