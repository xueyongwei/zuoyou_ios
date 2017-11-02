//
//  ZYContentTableViewCell.m
//  ZuoYou
//
//  Created by xueyognwei on 2017/2/24.
//  Copyright © 2017年 xueyongwei. All rights reserved.
//

#import "ZYContentTableViewCell.h"

@implementation ZYContentTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    DbLog(@" view %@",view);
    return view;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
