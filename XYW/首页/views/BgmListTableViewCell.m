//
//  BgmListTableViewCell.m
//  ZuoYou
//
//  Created by xueyognwei on 2017/3/6.
//  Copyright © 2017年 xueyongwei. All rights reserved.
//

#import "BgmListTableViewCell.h"

@implementation BgmListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        self.flagLabel.hidden = YES;
        self.flagImageView.hidden = NO;
        self.nameLabel.textColor = [UIColor colorWithHexColorString:@"ff4a4b"];
    }else{
        self.flagLabel.hidden = NO;
        self.flagImageView.hidden = YES;
        self.nameLabel.textColor = [UIColor colorWithHexColorString:@"333333"];
    }
    // Configure the view for the selected state
}

@end
