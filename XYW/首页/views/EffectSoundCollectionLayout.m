//
//  EffectSoundCollectionLayout.m
//  ZuoYou
//
//  Created by xueyognwei on 2017/3/1.
//  Copyright © 2017年 xueyongwei. All rights reserved.
//

#import "EffectSoundCollectionLayout.h"

@implementation EffectSoundCollectionLayout
-(void)awakeFromNib
{
    [super awakeFromNib];
    CGFloat screnW = SCREEN_W;
    
    self.sectionInset = UIEdgeInsetsMake(0, screnW/2-65, 0, screnW/2);
}
@end
