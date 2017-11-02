//
//  UserListTableViewCell.m
//  ZuoYou
//
//  Created by xueyongwei on 16/10/11.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "UserListTableViewCell.h"
#import "XYWAlert.h"
@implementation UserListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.guanzhuBtn.clipsToBounds = YES;
    self.guanzhuBtn.layer.cornerRadius = 5.0f;
    self.guanzhuBtn.layer.borderColor = [UIColor colorWithHexColorString:@"ff4a4b"].CGColor;
    self.guanzhuBtn.layer.borderWidth = SINGLE_LINE_WIDTH;
    
    // Initialization code
}

/**
 *  关注按钮的执行事件
 *  @param sender sender的selected标志了这个按钮的颜色状态
 */
- (IBAction)onGuanzhuClick:(UIButton *)sender {
    if (sender.selected) {
        [XYWAlert XYWAlertTitle:@"确定不再关注TA吗？" message:nil first:@"确定" firstHandle:^{
            NSString *urlStr = [NSString stringWithFormat:@"%@/social/cancelfollow",HeadUrl];
            NSDictionary *param = @{@"mid":@(sender.tag)};
            
            [XYWhttpManager XYWpost:urlStr parameters:param inView:nil sucess:^(id result) {
                DbLog(@"%@",result);
                if (![result objectForKey:@"errCode"]) {
                    //没有错误，让代理刷新数据
                    if (self.delegate) {
                        [self.delegate reloadNewWorkDataSource];
                    }else{
                        NSAssert(1, @"必须设置刷新数据的代理！");
                    }
                }
            } failure:^(NSError *error) {
                
            }];
            
        } second:nil Secondhandle:nil cancle:@"取消" handle:nil];
    }else{
        NSString *urlStr = [NSString stringWithFormat:@"%@/social/follow",HeadUrl];
        NSDictionary *param = @{@"mid":@(sender.tag)};
        [XYWhttpManager XYWpost:urlStr parameters:param inView:nil sucess:^(id result) {
            DbLog(@"%@",result);
            if ([result objectForKey:@"isFollow"]) {
                [self.delegate reloadNewWorkDataSource];
            }
        } failure:^(NSError *error) {
            
        }];
    }

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
