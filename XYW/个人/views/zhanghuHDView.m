//
//  zhanghuHDView.m
//  HDJ
//
//  Created by xueyongwei on 16/5/24.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "zhanghuHDView.h"
#import "UILabel+FlickerNumber.h"
@implementation zhanghuHDView
{
    int i;
}
-(void)setYueNumber:(NSNumber *)yueNumber
{
//    NSTimeInterval timer = 0.5;
    [self.yueNumLabel fn_setNumber:yueNumber format:@"%.0f"];
//    [self.yueNumLabel fn_setNumber:yueNumber duration:timer];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
