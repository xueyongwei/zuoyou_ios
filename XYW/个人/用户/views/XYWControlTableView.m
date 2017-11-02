//
//  XYWControlTableView.m
//  ZuoYou
//
//  Created by xueyongwei on 16/10/14.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "XYWControlTableView.h"

@implementation XYWControlTableView
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    gestureRecognizer.cancelsTouchesInView = NO;
    return NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
