//
//  BangdanTableViewCell.m
//  HDJ
//
//  Created by xueyongwei on 16/6/16.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "BangdanTableViewCell.h"

@implementation BangdanTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // 用户头像
    [self.iconImgV setContentMode:UIViewContentModeScaleAspectFill];
    self.iconImgV.layer.cornerRadius = 22.5;
    self.iconImgV.clipsToBounds = YES;
    
}
/**
 *  设置自己是否是自己的情况，显隐关注和膜拜按钮
 */
//-(void)afertSetModelHook
//{
//    self.guanzhuBtn.hidden = self.isMyself;
//}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
