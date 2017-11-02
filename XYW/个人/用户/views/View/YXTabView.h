//
//  YXTabView.h
//  仿造淘宝商品详情页
//
//  Created by yixiang on 16/3/25.
//  Copyright © 2016年 yixiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXTabTitleView.h"
#import "YXTabItemBaseView.h"
#import "YX.h"
typedef void(^vcActionBlock)(NSDictionary *dict);

@interface YXTabView : UIView
@property (nonatomic, assign) BOOL isMe;
@property (nonatomic, strong) YXTabTitleView *tabTitleView;
-(instancetype)initWithTabConfigArray:(NSArray *)tabConfigArray userId:(NSNumber *)userID block:(vcActionBlock) block;//tab页配置数组

@end
