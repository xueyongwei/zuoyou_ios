//
//  UHCaresTableViewCell.m
//  ZuoYou
//
//  Created by xueyongwei on 16/9/23.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "UHCaresTableViewCell.h"

@implementation UHCaresTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectedBackgroundView = [[UIView alloc]initWithFrame:self.bounds];
    self.selectedBackgroundView.backgroundColor = [UIColor colorWithHexColorString:@"e1e1e1"];

    self.fengeH.constant = SINGLE_LINE_WIDTH;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
