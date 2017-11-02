//
//  ZYHonCommonLayout.m
//  ZuoYou
//
//  Created by xueyognwei on 17/2/5.
//  Copyright © 2017年 xueyongwei. All rights reserved.
//

#import "ZYHonCommonLayout.h"

@implementation ZYHonCommonLayout
-(void)awakeFromNib
{
    [super awakeFromNib];
    self.minimumInteritemSpacing = 0;
    self.minimumLineSpacing = 0;
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
}
@end
