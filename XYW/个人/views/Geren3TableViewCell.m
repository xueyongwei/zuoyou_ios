//
//  Geren3TableViewCell.m
//  ZuoYou
//
//  Created by xueyongwei on 16/9/9.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "Geren3TableViewCell.h"

@implementation Geren3TableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.progressView.color = [UIColor colorWithHexColorString:@"ff4a4b"];
    self.progressView.flat = @YES;
    self.progressView.showText = @NO;
    self.progressView.showBackgroundInnerShadow = @0;
    self.progressView.progress = 0.0;
    self.progressView.animate = @NO;
    self.progressView.background = [UIColor colorWithHexColorString:@"e6e6e6"];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
