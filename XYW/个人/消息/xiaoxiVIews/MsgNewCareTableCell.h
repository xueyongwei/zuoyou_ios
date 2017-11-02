//
//  MsgNewCareTableCell.h
//  ZuoYou
//
//  Created by xueyongwei on 16/9/27.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MsgNewCareTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fenggeConst;
@property (weak, nonatomic) IBOutlet UIImageView *userIcon;
@property (weak, nonatomic) IBOutlet UIImageView *userCorver;

@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;


@end
