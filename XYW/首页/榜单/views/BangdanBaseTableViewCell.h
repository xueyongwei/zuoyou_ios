//
//  BangdanBaseTableViewCell.h
//  ZuoYou
//
//  Created by xueyongwei on 16/10/8.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "UserListTableViewCell.h"
#import "BangDanModel.h"


@interface BangdanBaseTableViewCell : UserListTableViewCell

@property (nonatomic,strong)BangDanModel *model;
//豆子数
@property (weak, nonatomic) IBOutlet UILabel *beansLabel;
//分割线
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fengeLabelH;
//点击关注回调
@property (nonatomic,strong) void(^careClickBlock)(void);

-(void)afertSetModelHook;

@end
