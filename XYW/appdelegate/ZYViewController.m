//
//  ZYViewController.m
//  ZuoYou
//
//  Created by xueyongwei on 16/10/26.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "ZYViewController.h"
#import "SchemesModel.h"
#import "PKDetailViewController.h"
#import "UserInfoModel.h"
#import "UIImage+Color.h"
@interface ZYViewController ()

@end

@implementation ZYViewController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
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
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithHexColorString:@"f4f4f4"];
}
-(void)removeSchemeNoti
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"SCHEMES" object:nil];
}
-(void)prepareSchemes
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(schemesListen:) name:@"SCHEMES" object:nil];
}
/**
 *  监听uri
 *  来自网页打开赛事详情时
 *  @param noti 通知的消息
 */
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
/**
 *  自定义了返回键和标题栏属性
 *  子类请继承不覆盖
 */
-(void)customNavi{
    if (self.navigationController) {
        //如果不是导航的第一个VC，且还没有添加返回按钮才添加，才添加返回按钮
        if (self.navigationController.childViewControllers.count>1 && self.navigationItem.leftBarButtonItems.count<2) {
                UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                                   initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                   target:nil action:nil];
                negativeSpacer.width = -3;//修正间隙
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.frame = CGRectMake(0, 0, 44, 44);
                btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                [btn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
                [btn setImage:[UIImage imageNamed:@"back_click"] forState:UIControlStateHighlighted];
                [btn addTarget:self action:@selector(onBackClick:) forControlEvents:UIControlEventTouchUpInside];
                UIBarButtonItem *leftBar = [[UIBarButtonItem alloc]initWithCustomView:btn];
                self.navigationItem.leftBarButtonItems = @[negativeSpacer,leftBar];
        }
        //导航栏标题的颜色和大小
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor colorWithHexColorString:@"333333"]}];

        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageFromContextWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.shadowImage = [UIImage imageFromContextWithColor:[UIColor colorWithHexColorString:@"e6e6e6"]];
        self.navigationController.view.backgroundColor = [UIColor whiteColor];
        self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        
    }
}
-(void)dealHeadLine:(UIView *)view
{
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        UIView *nv = [[UIView alloc]initWithFrame:view.frame];
        nv.backgroundColor = [UIColor colorWithHexColorString:@"e6e6e6"];
        [view.superview addSubview:nv];
        [view removeFromSuperview];
    }else{
        for (UIView *subview in view.subviews) {
            [self dealHeadLine:subview];
        }
    }
}
/**
 *  点击自定义的返回键时
 *
 *  @param sender 返回键
 */
-(void)onBackClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  根据用户ID设置用户的昵称和头像
 *
 *  @param nameLbl 用户的昵称显示框
 *  @param imgView 用户的头像显示框
 *  @param userID  要显示的用户的ID
 */
-(void)setNameLabel:(UILabel *)nameLbl headImageV:(UIImageView *)imgView with:(NSInteger) userID
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (!userID || userID<10000) {
            NSString *errMsg = [NSString stringWithFormat:@"用户%ld不存在！",(long)userID];
            DbLog("%@",errMsg);
            return;
        }
        UserInfoModel *localUser = [self userInfoWithID:[NSString stringWithFormat:@"%ld",(long)userID]];
        if (localUser) {//如果本地有了信息
            dispatch_async(dispatch_get_main_queue(), ^{
                [imgView sd_setImageWithURL:[NSURL URLWithString:localUser.avatar] placeholderImage:[UIImage imageNamed:@"1"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if ([imageURL isEqual:[NSURL URLWithString:localUser.avatar]]) {
                        imgView.image = image;
                        nameLbl.text = localUser.name;
                    }
                }];
            });
            
            //防止信息过期，需要后台刷新一下这个用户的信息，下次再用就会是最新的
            [self refreshInfoBackgroundWithUserId:[NSString stringWithFormat:@"%ld",(long)userID]];
            return;
        }
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",HeadUrl,@"/users/info"];
        NSDictionary *param = @{@"ids":[NSString stringWithFormat:@"%ld",(long)userID]};
        DbLog(@"%@ %@",urlStr,param);
        [XYWhttpManager XYWpost:urlStr parameters:param inView:nil sucess:^(id result) {
            if ([result isKindOfClass:[NSArray class]]) {
                NSDictionary *dic = ((NSArray *)result).firstObject;
                if (!dic) {
                    DbLog(@"%@",[NSString stringWithFormat:@"用户%ld数据有误！",(long)userID]);
                    return ;
                }else{
                    UserInfoModel *userInfo = [UserInfoModel mj_objectWithKeyValues:dic];
                    [self saveUserInfo:userInfo withID:[NSString stringWithFormat:@"%ld",(long)userID]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [imgView sd_setImageWithURL:[NSURL URLWithString:localUser.avatar] placeholderImage:[UIImage imageNamed:@"1"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                            if ([imageURL isEqual:[NSURL URLWithString:localUser.avatar]]) {
                                imgView.image = image;
                                nameLbl.text = localUser.name;
                            }
                        }];
                    });
                    
                }
            }
        } failure:^(NSError *error) {
            
        }];
    });
    
}
/**
 *  使用后台线程（优先级最低）更新用户信息
 *  不做任何提示
 *  @param userID 要更新用户的ID
 */
-(void)refreshInfoBackgroundWithUserId:(NSString *)userID
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(queue, ^{
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",HeadUrl,@"/users/info"];
        NSDictionary *param = @{@"ids":userID};
        DbLog(@"%@ %@",urlStr,param);
        [XYWhttpManager XYWpost:urlStr parameters:param inView:nil sucess:^(id result) {
            if ([result isKindOfClass:[NSArray class]]) {
                NSDictionary *dic = ((NSArray *)result).firstObject;
                if (!dic) {
                    NSString *msg =[NSString stringWithFormat:@"用户%ld数据有误！",(long)userID];
                    DbLog(@"%@",msg);
                }else{
                    UserInfoModel *userInfo = [UserInfoModel mj_objectWithKeyValues:dic];
                    [self saveUserInfo:userInfo withID:[NSString stringWithFormat:@"%ld",(long)userID]];
                }
            }
        } failure:^(NSError *error) {
            
        }];
    });
}
/**
 *  保存用户信息
 *  防止存取后就用用户信息，此处主线程同步处理
 *
 *  @param infoModel 用户信息数据模型
 *  @param userID    要保存的用户ID
 */
-(void)saveUserInfo:(UserInfoModel *)infoModel withID:(NSString *)userID
{
    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
    NSData *udObject = [NSKeyedArchiver archivedDataWithRootObject:infoModel];
    [usf setObject:udObject forKey:userID];
    [usf synchronize];
}
/**
 *  读取用户信息
 *
 *  @param userID 要读的用户ID
 *
 *  @return 用户的信息
 */
-(UserInfoModel *)userInfoWithID:(NSString *)userID
{
    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
    NSData *udObject = [usf objectForKey:userID];
    if (udObject) {
        UserInfoModel *info = [NSKeyedUnarchiver unarchiveObjectWithData:udObject] ;
        return info;
    }else
    {
        return nil;
    }
    
}
/**
 *  内存压力
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    DbLog(@"清理内存图片缓解内存压力");
    [[SDImageCache sharedImageCache] clearMemory];
}
/**
 *  是否是我
 */
-(BOOL)isMeOfID:(NSInteger)userId
{
    if ([self mySelfId] == userId) {
        return YES;
    }
    return NO;
}
/**
 *  我的ID
 */
-(NSInteger )mySelfId
{
    return [UserInfoManager mySelfInfoModel].mid.integerValue;
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
