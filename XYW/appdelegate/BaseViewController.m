//
//  BaseViewController.m
//  HDJ
//
//  Created by xueyongwei on 16/6/7.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()<UIAlertViewDelegate>

@end

@implementation BaseViewController
-(NSMutableDictionary *)userDataDic
{
    if (!_userDataDic) {
        _userDataDic = [NSMutableDictionary new];
    }
    return _userDataDic;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexColorString:@"f4f4f4"];
    [self customNavi];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   
}

-(void)customNavi{//自定义了返回键和标题栏属性，之类请继承不覆盖
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -3;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 60, 30);
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [btn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"back_click"] forState:UIControlStateHighlighted];
    
    [btn addTarget:self action:@selector(onBackClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.leftBarButtonItems = @[negativeSpacer,leftBar];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor colorWithHexColorString:@"333333"]}];
    
}
-(void)onBackClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    DbLog(@"清理内存图片缓解内存压力");
    //清理一下图片内存缓存。
    [[SDImageCache sharedImageCache] clearMemory];
    
}

/**
 *  此方法一次性加载N多用户信息
 *
 *  @param userIds 需要的用户们
 */
-(void)saveUsers:(NSString *)userIds
{
    if (userIds.length<5) {
        return;
    }
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",HeadUrl,@"/users/info"];
    NSDictionary *param = @{@"ids":userIds};
    DbLog(@"%@ %@",urlStr,param);
    [XYWhttpManager XYWpost:urlStr parameters:param inView:nil sucess:^(id result) {
        if ([result isKindOfClass:[NSArray class]]) {
            NSArray *users = result;
            for (NSDictionary *dic  in users) {
                if (!dic) {
                    return ;
                }
                DbLog(@"%@",dic);
                
                NSString *idStr = [NSString stringWithFormat:@"%@",dic[@"id"]];
                [self.userDataDic setObject:dic forKey:idStr];
            }
        }
    } failure:^(NSError *error) {
        
    }];
}

-(void)setNameLabel:(UILabel *)nameLbl headImageV:(UIImageView *)imgView with:(NSInteger) userID
{
    if (!userID) {
        return;
    }
    
    NSDictionary *user = [self.userDataDic objectForKey:[NSString stringWithFormat:@"%ld",(long)userID]];
    if (user) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [imgView sd_setImageWithURL:[NSURL URLWithString:user[@"avatar"]] placeholderImage:[UIImage imageNamed:@"1"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if ([imageURL isEqual:[NSURL URLWithString:user[@"avatar"]]]) {
                    imgView.image = image;
                }
            }];
            nameLbl.text = user[@"name"];
        });
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    [imgView sd_setImageWithURL:[NSURL URLWithString:dic[@"avatar"]] placeholderImage:[UIImage imageNamed:@"1"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        if ([imageURL isEqual:[NSURL URLWithString:dic[@"avatar"]]]) {
                            imgView.image = image;
                        }
                    }];
                    nameLbl.text = dic[@"name"];
                });
                [self.userDataDic setObject:dic forKey:[NSString stringWithFormat:@"%ld",(long)userID]];
            }
            
        }
        
    } failure:^(NSError *error) {
        
    }];
    
}
/**
 *  是否是我
 */
-(BOOL)isMe:(NSInteger)userId
{
    return [UserInfoManager isMeOfID:userId];
}
@end
