//
//  MsgChatLeftVersysTableViewCell.h
//  ZuoYou
//
//  Created by xueyongwei on 16/11/11.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmallVersusCardView.h"

@interface MsgChatLeftVersysTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImgV;
@property (weak, nonatomic) IBOutlet UIImageView *incoCorver;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet SmallVersusCardView *versusView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *versusHeightConst;
//@property (weak, nonatomic) IBOutlet UILabel *tagNameLabel;
//@property (weak, nonatomic) IBOutlet UIImageView *rightCorver;
//@property (weak, nonatomic) IBOutlet UIImageView *redIcon;
//@property (weak, nonatomic) IBOutlet UIImageView *leftCorver;
//
//@property (weak, nonatomic) IBOutlet UIImageView *blueIcon;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
