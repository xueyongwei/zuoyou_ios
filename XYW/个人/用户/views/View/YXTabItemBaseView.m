//
//  YXTabItemBaseView.m
//  仿造淘宝商品详情页
//
//  Created by yixiang on 16/3/29.
//  Copyright © 2016年 yixiang. All rights reserved.
//

#import "YXTabItemBaseView.h"
#import "YX.h"

@implementation YXTabItemBaseView

-(void)renderUIWithInfo:(NSDictionary *)info block:(vcActionBlock)block{
    self.info = info;
    self.block = block;
    NSNumber *position = info[@"position"];
    int num = [position intValue];
    self.userDataDic = [NSMutableDictionary new];
    CGRect rect = self.isMe?CGRectMake(num*SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT-kTopBarHeight-kTabTitleViewHeight):CGRectMake(num*SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT-kTopBarHeight-kBottomBarHeight-kTabTitleViewHeight);
    self.frame = rect;
    
    self.tableView = [[UITableView alloc]initWithFrame:self.bounds style:UITableViewStyleGrouped];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithHexColorString:@"f4f4f4"];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    //_tableView.scrollEnabled = NO;
    [self addSubview:self.tableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:kGoTopNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:kLeaveTopNotificationName object:nil];//其中一个TAB离开顶部的时候，如果其他几个偏移量不为0的时候，要把他们都置为0
    [self prepareData];
}
-(UINavigationController *)navc
{
    UITabBarController *rootVC = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    if (rootVC.childViewControllers.count>2) {
        UINavigationController *nVC = rootVC.childViewControllers[2];
        if ([nVC isKindOfClass:[UINavigationController class]]) {
            return nVC;
        }
    }
    return nil;
}
-(void)prepareData
{
    
}
-(void)acceptMsg : (NSNotification *)notification{
    //NSLog(@"%@",notification);
    NSString *notificationName = notification.name;
    if ([notificationName isEqualToString:kGoTopNotificationName]) {
        NSDictionary *userInfo = notification.userInfo;
        NSString *canScroll = userInfo[@"canScroll"];
        if ([canScroll isEqualToString:@"1"]) {
            self.canScroll = YES;
            self.tableView.showsVerticalScrollIndicator = YES;
        }
    }else if([notificationName isEqualToString:kLeaveTopNotificationName]){
        self.tableView.contentOffset = CGPointZero;
        self.canScroll = NO;
        self.tableView.showsVerticalScrollIndicator = NO;
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}


//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return nil;
//}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (!self.canScroll) {
        [scrollView setContentOffset:CGPointZero];
    }
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY<0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kLeaveTopNotificationName object:nil userInfo:@{@"canScroll":@"1"}];
    }
}
-(void)setNameLabel:(UILabel *)nameLbl headImageV:(UIImageView *)imgView with:(NSInteger) userID
{
    if (!userID) {
        return;
    }
    
    NSDictionary *user = [self.userDataDic objectForKey:[NSString stringWithFormat:@"%ld",(long)userID]];
    if (user) {
        [imgView sd_setImageWithURL:[NSURL URLWithString:user[@"avatar"]] placeholderImage:[UIImage imageNamed:@"1"]];
//            [imgView sd_setImageWithURL:[NSURL URLWithString:user[@"avatar"]] placeholderImage:[UIImage imageNamed:@"1"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//                cacheType = SDImageCacheTypeDisk;
//                if ([imageURL isEqual:[NSURL URLWithString:user[@"avatar"]]]) {
//                    imgView.image = image;
//                }
//            }];
            nameLbl.text = user[@"name"];
        return;
    }
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",HeadUrl,@"/users/info"];
    NSDictionary *param = @{@"ids":[NSString stringWithFormat:@"%ld",(long)userID]};
    DbLog(@"%@ %@",urlStr,param);
    [XYWhttpManager XYWpost:urlStr parameters:param inView:nil sucess:^(id result) {
        if ([result isKindOfClass:[NSArray class]]) {
            NSDictionary *dic = ((NSArray *)result).firstObject;
            if (!dic) {
                NSString *msg =[NSString stringWithFormat:@"用户%ld数据有误！",(long)userID];
                dispatch_async(dispatch_get_main_queue(), ^{
                    CoreSVPCenterMsg(msg);
                });
            }else{
                [imgView sd_setImageWithURL:[NSURL URLWithString:dic[@"avatar"]] placeholderImage:[UIImage imageNamed:@"1"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if ([imageURL isEqual:[NSURL URLWithString:dic[@"avatar"]]]) {
                        imgView.image = image;
                    }
                }];
                nameLbl.text = dic[@"name"];
                [self.userDataDic setObject:dic forKey:[NSString stringWithFormat:@"%ld",(long)userID]];
            }
            
        }
        
    } failure:^(NSError *error) {
        
    }];
    
}

@end
