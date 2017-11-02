//
//  PinglunTableViewCell.m
//  HDJ
//
//  Created by xueyongwei on 16/6/8.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "PinglunTableViewCell.h"
#import "AppDelegate.h"
@interface PinglunTableViewCell()
@property (nonatomic,strong)NSMutableDictionary *userDataDic;

@end
@implementation PinglunTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.fengexian.constant = SINGLE_LINE_WIDTH;
    // Initialization code
}
-(void)setPinglunModel:(PinglunModel *)pinglunModel
{
    _pinglunModel = pinglunModel;
    self.nickNameLabel.tag = self.pinglunModel.body.mid;
    
    UIColor *myColor;
    if ([pinglunModel.extras.contestantType isEqualToString:@"RED"]) {
        myColor = [UIColor colorWithHexColorString:@"f44236"];
        self.nickNameLabel.textColor = myColor;
    }else if ([pinglunModel.extras.contestantType isEqualToString:@"BLUE"]){
        myColor = [UIColor colorWithHexColorString:@"03a9f3"];
        self.nickNameLabel.textColor = myColor;
    }else{
        myColor = [UIColor clearColor];
        self.nickNameLabel.textColor = [UIColor colorWithHexColorString:@"333333"];
    }
    self.userIconImgV.layer.borderColor = myColor.CGColor;
    
    NSString *repay=@"";
    if (pinglunModel.extras.referredMid!=0) {
        repay = [NSString stringWithFormat:@"回复%@:",pinglunModel.extras.referredNickname];
    }
    NSString *st = [NSString stringWithFormat:@"%@%@",repay,pinglunModel.body.content];
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:st];
    UIColor *nameColor;
    if ([pinglunModel.extras.referredContestantType isEqualToString:@"RED"]) {
        nameColor = [UIColor colorWithHexColorString:@"f44236"];
    }else if ([pinglunModel.extras.referredContestantType isEqualToString:@"BLUE"]){
        nameColor = [UIColor colorWithHexColorString:@"03a9f3"];
    }else{
        nameColor = [UIColor colorWithHexColorString:@"333333"];
    }
    
    [AttributedStr addAttribute:NSForegroundColorAttributeName
                          value:nameColor
                          range:NSMakeRange(2, pinglunModel.extras.referredNickname.length)];
    
    self.cmtLabel.attributedText = AttributedStr;
    self.userIconImgV.layer.borderWidth = 1;
    self.userIconImgV.layer.cornerRadius = 20;
    self.userIconImgV.clipsToBounds = YES;
    
    self.timeLabel.text = [pinglunModel.body howLongStr];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
