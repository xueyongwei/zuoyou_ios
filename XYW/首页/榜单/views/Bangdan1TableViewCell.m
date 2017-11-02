//
//  Bangdan1TableViewCell.m
//  HDJ
//
//  Created by xueyongwei on 16/6/16.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "Bangdan1TableViewCell.h"

@implementation Bangdan1TableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // 膜拜按钮
    self.mobaiBtn.clipsToBounds = YES;
    self.mobaiBtn.layer.cornerRadius = 5.0f;
    self.mobaiBtn.layer.borderColor = [UIColor colorWithHexColorString:@"ff4a4b"].CGColor;
    self.mobaiBtn.layer.borderWidth = SINGLE_LINE_WIDTH;
}
/**
 *  设置自己是否是自己的情况，显隐关注和膜拜按钮
 */
//-(void)afertSetModelHook
//{
//    if (self.canMoBai && self.isMyself) {
//        self.canMoBai = NO;
//    }
//    self.guanzhuBtn.hidden = self.isMyself;
//}
-(void)setCanMoBai:(BOOL)canMoBai
{
    _canMoBai = canMoBai;
    if (!canMoBai) {
        self.guanzhuOffConst.constant = 0;
        self.mobaiBtn.hidden = YES;
    }else{
        self.guanzhuOffConst.constant = 38;
        self.mobaiBtn.hidden = NO;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
