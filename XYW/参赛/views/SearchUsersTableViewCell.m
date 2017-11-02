//
//  SearchUsersTableViewCell.m
//  ZuoYou
//
//  Created by xueyognwei on 16/12/26.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "SearchUsersTableViewCell.h"

@implementation SearchUsersTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.sepHeightConst.constant = SINGLE_LINE_WIDTH;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
