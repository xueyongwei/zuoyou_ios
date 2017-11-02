//
//  BlackListTableViewCell.m
//  ZuoYou
//
//  Created by xueyognwei on 2017/2/10.
//  Copyright © 2017年 xueyongwei. All rights reserved.
//

#import "BlackListTableViewCell.h"

@implementation BlackListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.actionBtn.layer.borderColor = [UIColor colorWithHexColorString:@"999999"].CGColor;
    self.actionBtn.layer.borderWidth = SINGLE_LINE_WIDTH;
    self.actionBtn.layer.cornerRadius = 5;
    self.actionBtn.clipsToBounds = YES;
    self.sepheightConst.constant = SINGLE_LINE_WIDTH;
    // Initialization code
}
- (IBAction)onActionClick:(UIButton *)sender {
    if (self.delegate) {
        [self.delegate onActionBtnClick:self];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
