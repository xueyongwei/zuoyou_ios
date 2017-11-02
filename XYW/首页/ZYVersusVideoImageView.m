//
//  ZYVersusVideoImageView.m
//  ZuoYou
//
//  Created by xueyongwei on 16/11/9.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "ZYVersusVideoImageView.h"

@implementation ZYVersusVideoImageView
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    gestureRecognizer.cancelsTouchesInView = NO;
    return YES;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
