//
//  ChartsTableViewCell.m
//  ZuoYou
//
//  Created by xueyongwei on 2016/11/28.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "ChartsTableViewCell.h"
#import "UserInfoManager.h"
#import "XYWAlert.h"

@implementation  ChartsModel

@end

@implementation ChartsTableViewCell
//类方法，获取一个cell
+(id)dequeueReusableCellIn:(UITableView *)tableView WithStyle:(ChartsTableViewCellStyle)style
{
    NSString *clzName = [self boundleNameWithStyle:style];
    ChartsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:clzName];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:clzName owner:self options:nil]lastObject];
        DbLog(@"创建一个新的cell %@",cell);
        cell.sepHeightConst.constant = SINGLE_LINE_WIDTH;
        cell.careBtn.clipsToBounds = YES;
        cell.careBtn.layer.cornerRadius = 5.0f;
        cell.careBtn.layer.borderColor = [UIColor colorWithHexColorString:@"ff4a4b"].CGColor;
        cell.careBtn.layer.borderWidth = SINGLE_LINE_WIDTH;
        [cell.careBtn addTarget:cell action:@selector(onCareClick:) forControlEvents:UIControlEventTouchUpInside];
        UITapGestureRecognizer *tapIcon = [[UITapGestureRecognizer alloc]initWithTarget:cell action:@selector(tapUserIcon:)];
        cell.userIconImageView.userInteractionEnabled = YES;
        [cell.userIconImageView addGestureRecognizer:tapIcon];
    }
    return cell;
}
//设置数据
-(void)setChartsModel:(ChartsModel *)chartsModel
{
    _chartsModel = chartsModel;
    [UserInfoManager setNameLabel:self.userNameLabel headImageV:self.userIconImageView roleIcon:self.userRoleIcon with:chartsModel.mid];
//    [UserInfoManager setNameLabel:self.userNameLabel headImageV:self.userIconImageView with:chartsModel.mid];
    
    NSArray *detailStrs = [self detailTextWith:self.ModelStyle];
    
    NSString *showValue = @"0";
    if (chartsModel.totalCount) {//需要计算胜率
        showValue = [NSString stringWithFormat:@"%.2f%@",chartsModel.winCount.floatValue/chartsModel.totalCount.floatValue *100,@"%"];
    }else if(chartsModel.val){
        showValue = [NSString stringWithFormat:@"%ld",chartsModel.val.integerValue];
    }
    [self setCareType];
    NSMutableAttributedString * attText = [NSMutableAttributedString new];
    UIFont *font = [UIFont systemFontOfSize:14];
    
    [attText appendAttributedString:[[NSAttributedString alloc] initWithString:detailStrs.firstObject attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexColorString:@"777777"],NSFontAttributeName:font}]];
    [attText appendAttributedString:[[NSAttributedString alloc] initWithString:showValue attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexColorString:@"ff4a4b"],NSFontAttributeName:font}]];
    [attText appendAttributedString:[[NSAttributedString alloc] initWithString:detailStrs.lastObject attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexColorString:@"777777"],NSFontAttributeName:font}]];
    
    self.valueDetailLabel.attributedText = attText;
//    self.valueDetailLabel.text = [NSString stringWithFormat:@"%@%@%@",detailStrs.firstObject,showValue,detailStrs.lastObject];
    self.careBtnHeightConst.constant = [UserInfoManager isMeOfID:chartsModel.mid.integerValue]?0:22;
   
}
//点击了用户头像
-(void)tapUserIcon:(UITapGestureRecognizer *)recognizer
{
    if (self.userIconClickBlock) {
        self.userIconClickBlock(self.chartsModel.mid);
    }
}
//点击了关注按钮
-(void)onCareClick:(UIButton *)sender
{
    if (self.chartsModel.isFollow.integerValue ==1) {
        [XYWAlert XYWAlertTitle:@"确定不再关注TA吗？" message:nil first:@"确定" firstHandle:^{
            NSString *urlStr = [NSString stringWithFormat:@"%@/social/cancelfollow",HeadUrl];
            NSDictionary *param = @{@"mid":self.chartsModel.mid};
            
            [XYWhttpManager XYWpost:urlStr parameters:param inView:nil sucess:^(id result) {
                DbLog(@"%@",result);
                if (![result objectForKey:@"errCode"]) {
                    self.chartsModel.isFollow = @0;
                    [self setCareType];
                    if (self.careClickBlock) {
                        self.careClickBlock();
                    }
                }
            } failure:^(NSError *error) {
                
            }];
            
        } second:nil Secondhandle:nil cancle:@"取消" handle:nil];
    }else{
        NSString *urlStr = [NSString stringWithFormat:@"%@/social/follow",HeadUrl];
        NSDictionary *param = @{@"mid":self.chartsModel.mid};
        [XYWhttpManager XYWpost:urlStr parameters:param inView:nil sucess:^(id result) {
            DbLog(@"%@",result);
            if ([result objectForKey:@"isFollow"]) {
                self.chartsModel.isFollow = @1;
                [self setCareType];
                if (self.careClickBlock) {
                    self.careClickBlock();
                }
            }
        } failure:^(NSError *error) {
            
        }];
    }
    
}
//设置关注状态
-(void)setCareType
{
    NSInteger statusIndex = self.chartsModel.isFollow.integerValue==1 ? self.chartsModel.isFans.integerValue==1 ? 2 : 1 : 0;
    
    switch (statusIndex) {
        case 0:
        {
            [self.careBtn setTitle:@"关注" forState:UIControlStateNormal];
            [self.careBtn setTitleColor:[UIColor colorWithHexColorString:@"ff4a4b"] forState:UIControlStateNormal];
            self.careBtn.layer.borderColor = [UIColor colorWithHexColorString:@"ff4a4b"].CGColor;
        }
            break;
        case 1:
        {
            [self.careBtn setTitle:@"已关注" forState:UIControlStateNormal];
            [self.careBtn setTitleColor:[UIColor colorWithHexColorString:@"999999"] forState:UIControlStateNormal];
            self.careBtn.layer.borderColor = [UIColor colorWithHexColorString:@"999999"].CGColor;
        }
            break;
        case 2:
        {
            [self.careBtn setTitle:@"互相关注" forState:UIControlStateNormal];
            [self.careBtn setTitleColor:[UIColor colorWithHexColorString:@"999999"] forState:UIControlStateNormal];
            self.careBtn.layer.borderColor = [UIColor colorWithHexColorString:@"999999"].CGColor;
        }
            break;
        default:
            break;
    }
    
}

//获取xib名字
+(NSString *)boundleNameWithStyle:(ChartsTableViewCellStyle )style
{
    switch (style) {
        case Charts0TableViewCell:
            return @"Charts0TableViewCell";
            break;
        case Charts1TableViewCell:
            return @"Charts1TableViewCell";
            break;
        case Charts2TableViewCell:
            return @"Charts2TableViewCell";
            break;
        case Charts3TableViewCell:
            return @"Charts3TableViewCell";
            break;
    }
}
//获取显示内容
-(NSArray *)detailTextWith:(ChartsType)type
{
    switch (type) {
        case ChartsTypeWin_week:
            return @[@"胜利",@"场"];
            break;
            
        case ChartsTypeBe_praised_week:
            return @[@"获得",@"赞"];
            break;
        case ChartsTypeFans_total:
            return @[@"拥有",@"粉丝"];
            break;
        case ChartsTypePraise_win_rate:
            return @[@"点赞胜率",@""];
            break;
        case ChartsTypePraise_activity_rank:
            return @[@"胜利",@"场"];
            break;
            
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
