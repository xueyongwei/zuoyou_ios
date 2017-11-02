//
//  ItmHeaderView.m
//  ZuoYou
//
//  Created by xueyognwei on 16/12/19.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "ItmHeaderView.h"

@implementation ItmHeaderView
-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self customUI];
    }
    return self;
}
-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self customUI];
    }
    return self;
}
-(void)customUI
{
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
