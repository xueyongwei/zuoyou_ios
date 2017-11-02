//
//  MsgChatRightTableViewCell.h
//  ZuoYou
//
//  Created by xueyongwei on 16/11/11.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimeLabel.h"
@interface MsgChatRightTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImg;
@property (weak, nonatomic) IBOutlet UIImageView *iconCorver;

@property (weak, nonatomic) IBOutlet TimeLabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end
