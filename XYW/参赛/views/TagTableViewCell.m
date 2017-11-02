//
//  TagTableViewCell.m
//  ZuoYou
//
//  Created by xueyongwei on 16/11/4.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "TagTableViewCell.h"

@implementation TagTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.sepreatConstH.constant = SINGLE_LINE_WIDTH;
    // Initialization code
}
-(void)setHiddenIcon:(BOOL)hiddenIcon
{
    _hiddenIcon = hiddenIcon;
    self.IconConstH.constant = hiddenIcon?0:32;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
