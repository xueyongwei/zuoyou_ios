//
//  XiaoxiChatTableViewCell.m
//  HDJ
//
//  Created by xueyongwei on 16/7/21.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "XiaoxiChatTableViewCell.h"

@implementation XiaoxiChatTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.topSPH.constant = SINGLE_LINE_WIDTH;
    self.bottomSPH.constant = SINGLE_LINE_WIDTH;
    // Initialization code
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
