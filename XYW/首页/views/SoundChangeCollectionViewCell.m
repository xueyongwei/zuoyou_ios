//
//  SoundChangeCollectionViewCell.m
//  ZuoYou
//
//  Created by xueyognwei on 17/2/5.
//  Copyright © 2017年 xueyongwei. All rights reserved.
//

#import "SoundChangeCollectionViewCell.h"

@implementation SoundChangeCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.imgView.layer.cornerRadius = 30;
    self.imgView.layer.borderWidth = 1;
    self.imgView.layer.borderColor = [UIColor clearColor].CGColor;
    self.imgView.clipsToBounds = YES;
    // Initialization code
    if ([UIScreen mainScreen].bounds.size.width<350) {
        self.soundChangeImageViewWidthConst.constant = 50;
        self.imgView.layer.cornerRadius = 25;
    }
    
}
-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    
    
    if (selected) {
        [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.imgView.transform = CGAffineTransformMakeScale(1.1, 1.1);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.imgView.transform = CGAffineTransformMakeScale(1, 1);
            } completion:^(BOOL finished) {
                
            }];
        }];
        self.imgView.layer.borderColor = [UIColor colorWithHexColorString:KCOlorPKRed].CGColor;
        self.txtLabel.textColor = [UIColor colorWithHexColorString:KCOlorPKRed];
    }else{
        self.imgView.layer.borderColor = [UIColor clearColor].CGColor;
        self.txtLabel.textColor = [UIColor colorWithHexColorString:@"333333"];
    }
}
@end
