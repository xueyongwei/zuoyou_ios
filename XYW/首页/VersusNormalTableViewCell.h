//
//  VersusNormalTableViewCell.h
//  ZuoYou
//
//  Created by xueyongwei on 16/9/14.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYText.h"
#include "YYLabel.h"
#import "PkProgressView.h"
#import "PKModel.h"
#import "ZYVersusVideoImageView.h"

#define kLeadingAnTringVersusNormalTableViewCell 10
#define NOTIFICATION_TIME_CELL  @"NotificationTimeCell"

@interface VersusNormalTableViewCell : UITableViewCell
//上边信息
@property (weak, nonatomic) IBOutlet UILabel *pkTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *pkSumLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet YYLabel *huoshegnLabel;
@property (weak, nonatomic) IBOutlet PkProgressView *pkprogress;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fengexianH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videosViewH;
@property (weak, nonatomic) IBOutlet UILabel *tagHotArea;


//左边的用户
@property (weak, nonatomic) IBOutlet UILabel *pkLeftUserNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *pkLeftUserIconImgV;
@property (weak, nonatomic) IBOutlet UIImageView *pkLeftCorverImgV;
@property (weak, nonatomic) IBOutlet UILabel *pkLeftUserBeansLabel;
@property (weak, nonatomic) IBOutlet UIButton *pkLeftPKbtn;

//右边的用户
@property (weak, nonatomic) IBOutlet UILabel *pkRightUserNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *pkRightUserIconImgV;
@property (weak, nonatomic) IBOutlet UIImageView *pkRightCorverImgV;
@property (weak, nonatomic) IBOutlet UILabel *pkRightUserBeansLabel;
@property (weak, nonatomic) IBOutlet UIButton *pkRightPKbtn;



@property (weak, nonatomic) IBOutlet UIImageView *leftVideoImg;
@property (weak, nonatomic) IBOutlet UIImageView *rightVIdeoImg;
@property (weak, nonatomic) IBOutlet UIImageView *PKV;

@property (nonatomic)       BOOL         clickRightVideo;


@property (nonatomic,weak)PKModel *dataModel;


-(void)updateWinType;
@end
