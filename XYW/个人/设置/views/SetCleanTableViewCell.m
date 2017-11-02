//
//  SetCleanTableViewCell.m
//  ZuoYou
//
//  Created by xueyongwei on 16/9/29.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "SetCleanTableViewCell.h"

@implementation SetCleanTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.fengeConst.constant = SINGLE_LINE_WIDTH;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
