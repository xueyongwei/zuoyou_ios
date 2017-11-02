//
//  PinglunTableViewCell.h
//  HDJ
//
//  Created by xueyongwei on 16/6/8.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PinglunModel.h"
@interface PinglunTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *cmtLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userIconImgV;
@property (weak, nonatomic) IBOutlet UIImageView *userCorver;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fengexian;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;


@property (nonatomic,strong)PinglunModel *pinglunModel;

@end
