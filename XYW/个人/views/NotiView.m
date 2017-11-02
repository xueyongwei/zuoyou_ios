//
//  NotiView.m
//  HDJ
//
//  Created by xueyongwei on 16/8/8.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "NotiView.h"

@implementation NotiView
-(void)show
{
    [[UIApplication sharedApplication].windows.lastObject addSubview:self];
    CGRect rec1 = CGRectMake(0, -64, SCREEN_W, 64);
    CGRect rec2 = CGRectMake(0, 0, SCREEN_W, 64);
    self.frame = rec1;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.frame = rec2;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5 animations:^{
                self.frame = rec1;
            } completion:^(BOOL finished) {
                
            }];
        });
    }];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
