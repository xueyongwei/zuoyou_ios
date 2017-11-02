//
//  ZJHonerTableViewCell.h
//  ZuoYou
//
//  Created by xueyongwei on 16/9/23.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopcountdownModel.h"
@interface ZJHonerTableViewCell : UITableViewCell
@property (nonatomic,strong)TopcountdownModel *countdownModel;


@property (weak, nonatomic) IBOutlet UIImageView *heima;
@property (weak, nonatomic) IBOutlet UILabel *heimaM;

@property (weak, nonatomic) IBOutlet UIImageView *xingui;
@property (weak, nonatomic) IBOutlet UILabel *xinguiM;

@property (weak, nonatomic) IBOutlet UIImageView *meili;
@property (weak, nonatomic) IBOutlet UILabel *meiliM;

@property (weak, nonatomic) IBOutlet UIImageView *tuhao;
@property (weak, nonatomic) IBOutlet UILabel *tuhaoM;

@end
