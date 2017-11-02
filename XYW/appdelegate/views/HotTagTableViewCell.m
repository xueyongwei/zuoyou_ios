//
//  HotTagTableViewCell.m
//  ZuoYou
//
//  Created by xueyognwei on 16/12/19.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "HotTagTableViewCell.h"

@implementation HotTagTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.sepHeightConst.constant = SINGLE_LINE_WIDTH;
//    self.TagThumbImageView.clipsToBounds = YES;
//    self.TagThumbImageView.layer.cornerRadius = 8;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
