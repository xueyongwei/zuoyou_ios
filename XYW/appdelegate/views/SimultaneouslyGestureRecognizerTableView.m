//
//  SimultaneouslyGestureRecognizerTableView.m
//  ZuoYou
//
//  Created by xueyognwei on 17/2/5.
//  Copyright © 2017年 xueyongwei. All rights reserved.
//

#import "SimultaneouslyGestureRecognizerTableView.h"

@implementation SimultaneouslyGestureRecognizerTableView
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
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
