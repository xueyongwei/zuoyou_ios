//
//  LuckyAlert.m
//  ZuoYou
//
//  Created by xueyognwei on 2017/2/28.
//  Copyright © 2017年 xueyongwei. All rights reserved.
//

#import "LuckyAlert.h"

@implementation LuckyAlert
{
    void(^okTmpBlock)(void);
}
-(void)showIn:(UIView *)superView tips:(NSString *)tips okClick:(void (^)(void))okBlock
{
    okTmpBlock = okBlock;
    [self showIn:superView];
}
-(void)showIn:(UIView *)superView
{
    self.frame = superView.bounds;
    [superView addSubview:self];
}
-(void)dismiss
{
    [self removeFromSuperview];
}
- (IBAction)onCancle:(UIButton *)sender {
    [self dismiss];
}
- (IBAction)onOk:(UIButton *)sender {
    [self dismiss];
    okTmpBlock();
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
