//
//  DouziGongxianTableViewCell.m
//  ZuoYou
//
//  Created by xueyongwei on 16/9/18.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "DouziGongxianTableViewCell.h"

@implementation DouziGongxianTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSeparatorStyleNone;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
