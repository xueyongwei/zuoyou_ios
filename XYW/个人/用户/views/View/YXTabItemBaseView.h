//
//  YXTabItemBaseView.h
//  仿造淘宝商品详情页
//
//  Created by yixiang on 16/3/29.
//  Copyright © 2016年 yixiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXTabItemBaseViewDelegateModel.h"
@protocol YXTabItemBaseViewDelegate

-(void)setTabNub:(YXTabItemBaseViewDelegateModel*)model;
-(void)reloadTabNumbData;
@end
typedef void(^vcActionBlock)(NSDictionary *dict);

#import "UHCenterViewController.h"

@interface YXTabItemBaseView : UIView<UITableViewDelegate,UITableViewDataSource>
//代理
@property (nonatomic,weak) id<YXTabItemBaseViewDelegate> delegate;
//代码块
@property (nonatomic,strong) vcActionBlock block;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) BOOL canScroll;
@property (nonatomic, assign) BOOL isMe;
@property (nonatomic, strong) NSDictionary *info;
@property (nonatomic,strong)NSNumber *userID;
@property (nonatomic, strong) NSMutableDictionary *userDataDic;
@property (nonatomic,strong) UINavigationController *navc;

-(void)setNameLabel:(UILabel *)nameLbl headImageV:(UIImageView *)imgView with:(NSInteger) userID;
-(void)renderUIWithInfo:(NSDictionary *)info block:(vcActionBlock)block;
-(void)prepareData;
@end
