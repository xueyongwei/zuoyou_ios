//
//  YXTabTitleView.h
//  仿造淘宝商品详情页
//
//  Created by yixiang on 16/3/25.
//  Copyright © 2016年 yixiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXTabItemBaseView.h"
#import "UHVideosTableView.h"
/**
 *  定义点击的block
 *
 *  @param NSInteger 点击column数
 */
typedef void (^YXTabTitleClickBlock)(NSInteger);
@interface YXTabTitleView : UIView<YXTabItemBaseViewDelegate>
@property (nonatomic,strong)UHVideosTableView *videoTableView;
@property (nonatomic, strong) YXTabTitleClickBlock titleClickBlock;
-(instancetype)initWithTitleArray:(NSArray *)titleArray userId:(NSNumber *)userID;

-(void)setItemSelected: (NSInteger)column;
-(void)reloadTabNumbData;



@end
