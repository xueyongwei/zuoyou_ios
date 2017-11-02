//
//  BangdanBaseTableViewCell.m
//  ZuoYou
//
//  Created by xueyongwei on 16/10/8.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "BangdanBaseTableViewCell.h"
#import "XYWAlert.h"
@implementation BangdanBaseTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.fengeLabelH.constant = SINGLE_LINE_WIDTH;
}
-(void)setModel:(BangDanModel *)model
{
    _model = model;
    [self afertSetModelHook];
}
/**
 *  子类重写方法
 */
-(void)afertSetModelHook
{
    
}


@end
