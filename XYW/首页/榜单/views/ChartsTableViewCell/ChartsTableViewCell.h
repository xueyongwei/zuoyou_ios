//
//  ChartsTableViewCell.h
//  ZuoYou
//
//  Created by xueyongwei on 2016/11/28.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
    ChartsTypeWin_week,
    ChartsTypeBe_praised_week,
    ChartsTypeFans_total,
    ChartsTypePraise_win_rate,
    ChartsTypePraise_activity_rank,
}ChartsType;

typedef enum{
    Charts0TableViewCell,
    Charts1TableViewCell,
    Charts2TableViewCell,
    Charts3TableViewCell,
} ChartsTableViewCellStyle;

@interface ChartsModel : UITableViewController
@property (nonatomic,strong)NSNumber* mid;
@property (nonatomic,strong)NSNumber* isFans;
@property (nonatomic,strong)NSNumber* isFollow;
@property (nonatomic,strong)NSNumber* val;
@property (nonatomic,strong)NSNumber* winCount;
@property (nonatomic,strong)NSNumber* totalCount;
@end



@interface ChartsTableViewCell : UITableViewCell
+(id)dequeueReusableCellIn:(UITableView *)tableView WithStyle:(ChartsTableViewCellStyle)style;

@property (weak, nonatomic) IBOutlet UIImageView *userIconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *userIconCorver;
@property (weak, nonatomic) IBOutlet UIImageView *userRoleIcon;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueDetailLabel;
@property (weak, nonatomic) IBOutlet UIButton *careBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sepHeightConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *careBtnHeightConst;

@property (weak, nonatomic) IBOutlet UILabel *flagNumberLabel;

//点击关注回调
@property (nonatomic,strong) void(^careClickBlock)(void);
//点击头像回调
@property (nonatomic,strong) void(^userIconClickBlock)(NSNumber *userId);

@property (nonatomic,strong)ChartsModel *chartsModel;
@property (nonatomic,assign)ChartsType ModelStyle;
@end
