//
//  VideoFramesCollectionViewCell.m
//  ZuoYou
//
//  Created by xueyognwei on 2017/2/28.
//  Copyright © 2017年 xueyongwei. All rights reserved.
//

#import "VideoFramesCollectionViewCell.h"

@implementation VideoFramesCollectionViewCell

//- (void)awakeFromNib {
//    [super awakeFromNib];
////    self.imgView.layer.cornerRadius = 30;
////    self.imgView.layer.borderWidth = 1;
////    self.imgView.layer.borderColor = [UIColor clearColor].CGColor;
////    self.imgView.clipsToBounds = YES;
//    // Initialization code
//}
-(void)setSelected:(BOOL)selected
{
//    [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//        self.imgView.transform = CGAffineTransformMakeScale(0.9, 0.9);
//    } completion:^(BOOL finished) {
//        [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//            self.imgView.transform = CGAffineTransformMakeScale(1, 1);
//        } completion:^(BOOL finished) {
//            
//        }];
//    }];
    
    if (selected) {
        self.corverView.backgroundColor = [UIColor colorWithHexColorString:@"cb7ee1" alpha:0.5];
//        self.imgView.layer.borderColor = [UIColor colorWithHexColorString:KCOlorPKRed].CGColor;
    }else{
        self.corverView.backgroundColor = [UIColor clearColor];
//        self.imgView.layer.borderColor = [UIColor clearColor].CGColor;
    }
}
@end
