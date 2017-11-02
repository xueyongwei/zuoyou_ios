//
//  ShouYiHdView.m
//  HDJ
//
//  Created by xueyongwei on 16/6/14.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "ShouYiHdView.h"
#import "UILabel+FlickerNumber.h"
@implementation ShouYiHdView
-(void)setYueNub:(float)yueNub
{
//    [self.yueLabel fn_setNumber:@(yueNub) duration:1.0f];
    self.yueLabel.text = @"0.00";
}
-(void)awakeFromNib
{
    self.tixianBtn.clipsToBounds = YES;
    self.tixianBtn.layer.cornerRadius = 5;
    self.tixianBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.tixianBtn.layer.borderWidth = 1.0f;
}
- (IBAction)onTixianClick:(UIButton *)sender {
    CoreSVPCenterMsg(@"余额不足，无法提现");
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
