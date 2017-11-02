//
//  IncomeDetailTableViewCell.h
//  ZuoYou
//
//  Created by xueyognwei on 16/12/21.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmallVersusCardView.h"
@interface IncomeDetailTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UIButton *stateBtn;
//@property (weak, nonatomic) IBOutlet UILabel *tagNameLabel;
//@property (weak, nonatomic) IBOutlet UIImageView *leftIcon;
//@property (weak, nonatomic) IBOutlet UIImageView *leftCorver;
//@property (weak, nonatomic) IBOutlet UIImageView *rightIcon;
//@property (weak, nonatomic) IBOutlet UIImageView *rightCorver;
@property (weak, nonatomic) IBOutlet SmallVersusCardView *versusView;

@end
