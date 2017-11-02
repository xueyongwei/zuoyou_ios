//
//  SuggestedFollowsCollectionViewCell.m
//  ZuoYou
//
//  Created by xueyognwei on 2017/2/27.
//  Copyright © 2017年 xueyongwei. All rights reserved.
//

#import "SuggestedFollowsCollectionViewCell.h"

@implementation SuggestedFollowsCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
//    self.selected = YES;
    // Initialization code
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapUserIcon:)];
    self.userIconImageView.userInteractionEnabled = YES;
    [self.userIconImageView addGestureRecognizer:tap];
}
- (void)tapUserIcon:(UITapGestureRecognizer *)sender {
    if ([self.delegate respondsToSelector:@selector(onUserIconTap:)]) {
        [self.delegate onUserIconTap:sender];
    }
}
-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    _selectStatusBtn.selected = selected;
}
@end
