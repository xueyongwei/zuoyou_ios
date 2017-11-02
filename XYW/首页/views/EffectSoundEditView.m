//
//  EffectSoundEditView.m
//  ZuoYou
//
//  Created by xueyognwei on 2017/2/28.
//  Copyright © 2017年 xueyongwei. All rights reserved.
//

#import "EffectSoundEditView.h"
#import "EffectSoundCollectionLayout.h"
@implementation EffectSoundEditView
-(void)awakeFromNib
{
    [super awakeFromNib];
    if ([UIScreen mainScreen].bounds.size.width<350) {
        self.effectScrolViewHeightConst.constant = 12.5;
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
