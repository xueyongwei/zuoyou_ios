//
//  PkdetailDescTableViewCell.m
//  XYW
//
//  Created by xueyongwei on 16/9/1.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "PkdetailDescTableViewCell.h"

@interface PkdetailDescTableViewCell()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *TR;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *LE;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *BO;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *TO;
@property (weak, nonatomic) IBOutlet UIView *xianView;
@property (weak, nonatomic) IBOutlet UIImageView *leftWho;
@property (weak, nonatomic) IBOutlet UIImageView *rightWho;


@end

@implementation PkdetailDescTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.TO.constant = SINGLE_LINE_WIDTH;
    self.BO.constant = SINGLE_LINE_WIDTH;
    self.TR.constant = SINGLE_LINE_WIDTH;
    self.LE.constant = SINGLE_LINE_WIDTH;
    // Initialization code
}

-(void)setSelectedRight:(BOOL)selectedRight
{
    _selectedRight = selectedRight;
    if (selectedRight) {
        self.xianView.backgroundColor = [UIColor colorWithHexColorString:KCOlorPKBlue];
        self.rightWho.hidden = NO;
        self.leftWho.hidden = YES;
    }else{
        self.xianView.backgroundColor = [UIColor colorWithHexColorString:KCOlorPKRed];
        self.rightWho.hidden = YES;
        self.leftWho.hidden = NO;
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
