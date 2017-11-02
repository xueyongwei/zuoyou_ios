//
//  ZJHonerTableViewCell.m
//  ZuoYou
//
//  Created by xueyongwei on 16/9/23.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "ZJHonerTableViewCell.h"

@implementation ZJHonerTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)setCountdownModel:(TopcountdownModel *)countdownModel
{
    _countdownModel = countdownModel;
    if (countdownModel.win_week.intValue>0) {
        self.heima.image =[UIImage imageNamed:@"UserProfileExplootZJ1L"];
        self.heimaM.text = [NSString stringWithFormat:@"第%@名",countdownModel.win_week];
    }else{
        self.heima.image =[UIImage imageNamed:@"UserProfileExplootZJ1"];
        self.heimaM.text = @"暂未上榜";
    }
    if (countdownModel.be_praised_week.intValue>0) {
        self.xingui.image =[UIImage imageNamed:@"UserProfileExplootZJ2L"];
        self.xinguiM.text = [NSString stringWithFormat:@"第%@名",countdownModel.be_praised_week];
        
    }else{
        self.xingui.image =[UIImage imageNamed:@"UserProfileExplootZJ2"];
        self.xinguiM.text = @"暂未上榜";
    }
    if (countdownModel.fans_total.intValue>0) {
        self.meili.image =[UIImage imageNamed:@"UserProfileExplootZJ3L"];
        self.meiliM.text = [NSString stringWithFormat:@"第%@名",countdownModel.fans_total];
        
    }else{
        self.meili.image =[UIImage imageNamed:@"UserProfileExplootZJ3"];
        self.meiliM.text = @"暂未上榜";
    }
    if (countdownModel.praise_win_rate.intValue>0) {
        self.tuhao.image =[UIImage imageNamed:@"UserProfileExplootZJ4L"];
        self.tuhaoM.text = [NSString stringWithFormat:@"第%@名",countdownModel.praise_win_rate];
    }else{
        self.tuhao.image =[UIImage imageNamed:@"UserProfileExplootZJ4"];
        self.tuhaoM.text = @"暂未上榜";
    }
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
