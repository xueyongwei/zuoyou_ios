//
//  RenwuTableViewCell.m
//  HDJ
//
//  Created by xueyongwei on 16/8/8.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "RenwuTableViewCell.h"
#import "AppDelegate.h"
#import <Google/Analytics.h>
@implementation RenwuTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.fengexianH.constant = SINGLE_LINE_WIDTH;
    self.renwuActionBtn.layer.borderWidth = SINGLE_LINE_WIDTH;
    // Initialization code
}
-(void)setModel:(RenWuListModel *)model
{
    _model = model;
    [self.renwuIconImgV sd_setImageWithURL:[NSURL URLWithString:self.model.icon] placeholderImage:[UIImage imageNamed:@"1"]];
    
    
    NSMutableAttributedString *text = [NSMutableAttributedString new];
    
    UIFont *font = [UIFont systemFontOfSize:11];
    NSString *title = @"奖励 ";
    [text appendAttributedString:[[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexColorString:@"555555"]}]];
    if (model.rewardGoldBeans>0) {
        UIImage *image = [UIImage imageNamed:@"胜方获得金豆"];
        image = [UIImage imageWithCGImage:image.CGImage scale:2 orientation:UIImageOrientationUp];
        NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:image contentMode:UIViewContentModeScaleAspectFit attachmentSize:CGSizeMake(11, 11) alignToFont:font alignment:YYTextVerticalAlignmentCenter];
        [text appendAttributedString:attachText];
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" X%ld",(long)model.rewardGoldBeans] attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexColorString:@"ff4a4b"]}]];
    }
    if (model.rewardRedBeans>0) {
        UIImage *image = [UIImage imageNamed:@"任务红豆"];
        image = [UIImage imageWithCGImage:image.CGImage scale:2 orientation:UIImageOrientationUp];
        NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:image contentMode:UIViewContentModeScaleAspectFit attachmentSize:CGSizeMake(11, 11) alignToFont:font alignment:YYTextVerticalAlignmentCenter];
        [text appendAttributedString:attachText];
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" X%ld",(long)model.rewardRedBeans] attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexColorString:@"ff4a4b"]}]];
    }
    text.yy_alignment = NSTextAlignmentLeft;
    self.renwuContentLabel.attributedText = text;
    self.renwuNameLabl.text  = self.model.name;
    
    if (self.model.renwuID ==1) {
        
        if ([self.model.statusType isEqualToString:@"UNFINISH"]) {
            self.renwuActionBtn.userInteractionEnabled = YES;
            self.renwuActionBtn.layer.borderColor = [UIColor colorWithHexColorString:@"ff4a4b"].CGColor;
            [self.renwuActionBtn setTitleColor:[UIColor colorWithHexColorString:@"ff4a4b"] forState:UIControlStateNormal];
            [self.renwuActionBtn setTitle:@"签到" forState:UIControlStateNormal];
        }else{
            self.renwuActionBtn.userInteractionEnabled = NO;
            self.renwuActionBtn.layer.borderColor = [UIColor colorWithHexColorString:@"999999"].CGColor;
            [self.renwuActionBtn setTitleColor:[UIColor colorWithHexColorString:@"999999"] forState:UIControlStateNormal];
            [self.renwuActionBtn setTitle:@"已签到" forState:UIControlStateNormal];
        }
        
    }else{
        self.renwuActionBtn.userInteractionEnabled = NO;
        self.renwuActionBtn.layer.borderColor = [UIColor clearColor].CGColor;
        
        if ([self.model.statusType isEqualToString:@"UNFINISH"]) {
            [self.renwuActionBtn setTitle:@"待完成" forState:UIControlStateNormal];
            [self.renwuActionBtn setTitleColor:[UIColor colorWithHexColorString:@"ff4a4b"] forState:UIControlStateNormal];
        }else{
            [self.renwuActionBtn setTitle:@"已完成" forState:UIControlStateNormal];
            [self.renwuActionBtn setTitleColor:[UIColor colorWithHexColorString:@"999999"] forState:UIControlStateNormal];
        }
    }
    
}
- (IBAction)onQiandaoCick:(UIButton *)sender {
//    /v1/mission/attend
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"个人中心"
                                                          action:@"点击签到"
                                                           label:nil
                                                           value:@1] build]];
//    NSString *location = [NSString stringWithFormat:@"%@_%s_%d",NSStringFromClass([self class]),__FUNCTION__,__LINE__];
    
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@%@",HeadUrl,@"/mission/attend"] parameters:nil inView:nil sucess:^(id result) {
        if (result&&[result objectForKey:@"code"]) {
            DbLog(@"%@",result);
            self.renwuActionBtn.userInteractionEnabled = NO;
            self.renwuActionBtn.layer.borderColor = [UIColor colorWithHexColorString:@"999999"].CGColor;
            [self.renwuActionBtn setTitleColor:[UIColor colorWithHexColorString:@"999999"] forState:UIControlStateNormal];
            [self.renwuActionBtn setTitle:@"已签到" forState:UIControlStateNormal];
            [self.delegate prepareRenwuList];
        }else{
            CoreSVPCenterMsg([result objectForKey:@"errMsg"]);
        }
    } failure:^(NSError *error) {
        CoreSVPCenterMsg(error.localizedDescription);
        DbLog(@"%@",error.localizedDescription);;
    }];
   
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
