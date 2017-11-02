//
//  BgmListFirstTableViewCell.m
//  ZuoYou
//
//  Created by xueyognwei on 2017/3/6.
//  Copyright © 2017年 xueyongwei. All rights reserved.
//

#import "BgmListFirstTableViewCell.h"

@implementation BgmListFirstTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        self.flagImageView.image = [UIImage imageNamed:@"addBgm音乐勾选"];
        self.nameLabel.textColor = [UIColor colorWithHexColorString:@"ff4a4b"];
    }else{
        self.flagImageView.image = [UIImage imageNamed:@"addBgm无音乐"];
        self.nameLabel.textColor = [UIColor colorWithHexColorString:@"333333"];
    }
    // Configure the view for the selected state
}

@end
