//
//  UploadVideoAlertView.m
//  ZuoYou
//
//  Created by xueyongwei on 16/11/7.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "UploadVideoAlertView.h"

@implementation UploadVideoAlertView
-(void)show
{
    [[UIApplication sharedApplication].windows.lastObject addSubview:self];
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.superview);
    }];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self disMiss];
}
-(void)disMiss
{
    [self removeFromSuperview];
}


@end
