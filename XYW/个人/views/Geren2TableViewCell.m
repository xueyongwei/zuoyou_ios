//
//  Geren2TableViewCell.m
//  ZuoYou
//
//  Created by xueyongwei on 16/9/9.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "Geren2TableViewCell.h"

@implementation Geren2TableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.topH.constant = SINGLE_LINE_WIDTH;
    self.botH.constant = SINGLE_LINE_WIDTH;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
