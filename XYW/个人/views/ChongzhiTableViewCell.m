//
//  ChongzhiTableViewCell.m
//  HDJ
//
//  Created by xueyongwei on 16/6/13.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "ChongzhiTableViewCell.h"

@implementation ChongzhiTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.moneyLabel.layer.borderWidth = SINGLE_LINE_WIDTH;
    self.fengeLabelH.constant = SINGLE_LINE_WIDTH;
    self.moneyLabel.layer.borderColor = [UIColor redColor].CGColor;
    self.moneyLabel.clipsToBounds = YES;
    self.moneyLabel.layer.cornerRadius = 5.0f;
    
    // Initialization code
}
-(void)setYouHui:(BOOL)YouHui
{
    self.youhuiLabel.hidden = !YouHui;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
