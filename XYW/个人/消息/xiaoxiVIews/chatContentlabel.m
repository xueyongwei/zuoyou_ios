//
//  chatContentlabel.m
//  ZuoYou
//
//  Created by xueyognwei on 17/2/7.
//  Copyright © 2017年 xueyongwei. All rights reserved.
//

#import "chatContentlabel.h"

@implementation chatContentlabel
- (void)drawRect:(CGRect)rect {
    // Drawing code
    UIEdgeInsets insets = {12.5, 10, 12.5, 10};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
