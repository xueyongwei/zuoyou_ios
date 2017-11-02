//
//  VersusTableViewCell.m
//  ZuoYou
//
//  Created by xueyongwei on 16/10/31.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "VersusTableViewCell.h"

@implementation VersusTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self customCell];
    // Initialization code
}
-(void)customCell
{
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
