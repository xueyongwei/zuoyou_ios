//
//  MsgContentVersusCell.h
//  HDJ
//
//  Created by xueyongwei on 16/8/8.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmallVersusCardView.h"
@interface MsgContentVersusCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *cntLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet SmallVersusCardView *VersusView;
//@property (weak, nonatomic) IBOutlet UILabel *tagNameLabel;
//@property (weak, nonatomic) IBOutlet UIImageView *leftUserIconImgV;
//@property (weak, nonatomic) IBOutlet UIImageView *leftCorver;
//
//@property (weak, nonatomic) IBOutlet UIImageView *rightUserIconImgV;
//@property (weak, nonatomic) IBOutlet UIImageView *rightCorver;

@end
