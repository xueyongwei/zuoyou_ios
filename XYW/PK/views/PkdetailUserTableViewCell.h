//
//  PkdetailUserTableViewCell.h
//  XYW
//
//  Created by xueyongwei on 16/9/1.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYLabel.h"
#import "YYText.h"

@interface PkdetailUserTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *leftIconImgV;
@property (weak, nonatomic) IBOutlet UIImageView *leftCorver;
@property (weak, nonatomic) IBOutlet UIImageView *leftType;

@property (weak, nonatomic) IBOutlet UILabel *leftNameLabel;

@property (weak, nonatomic) IBOutlet YYLabel *timeLabel;

@property (weak, nonatomic) IBOutlet UIImageView *rightIconImgV;
@property (weak, nonatomic) IBOutlet UIImageView *rightCorver;
@property (weak, nonatomic) IBOutlet UIImageView *rightType;

@property (weak, nonatomic) IBOutlet UILabel *rightNameLabel;

@property (nonatomic,assign)BOOL selectedRight;

@end
