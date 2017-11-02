//
//  Bangdan3TableViewCell.m
//  ZuoYou
//
//  Created by xueyongwei on 16/8/23.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "Bangdan3TableViewCell.h"

@implementation Bangdan3TableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
   
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
