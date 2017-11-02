//
//  PkdetailUserTableViewCell.m
//  XYW
//
//  Created by xueyongwei on 16/9/1.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "PkdetailUserTableViewCell.h"
@interface PkdetailUserTableViewCell()


@end
@implementation PkdetailUserTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    // Initialization code
}
-(void)setSelectedRight:(BOOL)selectedRight
{
    _selectedRight = selectedRight;//选中右边蓝色
    if (selectedRight) {
        self.leftCorver.image = [UIImage imageNamed:@"头像未选中"];
        self.rightCorver.image = [UIImage imageNamed:@"头像-选中-蓝"];
        
        self.leftNameLabel.textColor = [UIColor colorWithHexColorString:@"333333"];
        self.rightNameLabel.textColor = [UIColor colorWithHexColorString:@"03a9f3"];
    }else{//选中左边红色
        self.leftCorver.image = [UIImage imageNamed:@"头像-选中-红"];
        self.rightCorver.image = [UIImage imageNamed:@"头像未选中"];
        self.leftNameLabel.textColor = [UIColor colorWithHexColorString:@"f44236"];
        self.rightNameLabel.textColor = [UIColor colorWithHexColorString:@"333333"];
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
