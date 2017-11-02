//
//  SetAutoPlayTableViewCell.m
//  ZuoYou
//
//  Created by xueyongwei on 16/9/29.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "SetAutoPlayTableViewCell.h"

@implementation SetAutoPlayTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)onSwitchClicj:(UISwitch *)sender {
    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
    [usf setObject:@(sender.on) forKey:PLAYERAUTOPLAY];
    [usf synchronize];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
