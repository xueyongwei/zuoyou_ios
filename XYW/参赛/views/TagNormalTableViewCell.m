//
//  TagNormalTableViewCell.m
//  ZuoYou
//
//  Created by xueyognwei on 17/1/6.
//  Copyright © 2017年 xueyongwei. All rights reserved.
//

#import "TagNormalTableViewCell.h"

@implementation TagNormalTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.sepHightConst.constant = SINGLE_LINE_WIDTH;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
