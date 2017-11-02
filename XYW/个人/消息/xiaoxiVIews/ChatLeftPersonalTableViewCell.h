//
//  ChatLeftPersonalTableViewCell.h
//  ZuoYou
//
//  Created by xueyognwei on 17/2/7.
//  Copyright © 2017年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimeLabel.h"
#import "chatContentlabel.h"

@interface ChatLeftPersonalTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet TimeLabel *timeLabel;
@property (weak, nonatomic) IBOutlet chatContentlabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userIconImgV;
@property (weak, nonatomic) IBOutlet UIImageView *iconCorverImgV;
@property (weak, nonatomic) IBOutlet UIButton *retryBtn;
@property (weak, nonatomic) IBOutlet UIImageView *contentBgImageV;
@end
