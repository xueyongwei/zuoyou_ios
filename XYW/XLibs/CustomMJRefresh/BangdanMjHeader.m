//
//  BangdanMjHeader.m
//  ZuoYou
//
//  Created by xueyongwei on 16/8/15.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "BangdanMjHeader.h"

@implementation BangdanMjHeader
- (void)prepare
{
    [super prepare];
    self.lastUpdatedTimeLabel.hidden = YES;
    // 设置普通状态的动画图片
    NSMutableArray *idleImages = [NSMutableArray array];
    for (int i = 1; i<=14; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"榜单头刷新加载动画%d", 200+i]];
        [idleImages addObject:image];
    }
    
    [self setImages:idleImages forState:MJRefreshStateIdle];
    
    // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
//    NSMutableArray *refreshingImages = [NSMutableArray array];
//    for (NSUInteger i = 1; i<=3; i++) {
//        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"dropdown_loading_0%zd", i]];
//        [refreshingImages addObject:image];
//    }
    [self setImages:idleImages forState:MJRefreshStatePulling];
    
    // 设置正在刷新状态的动画图片
    [self setImages:idleImages forState:MJRefreshStateRefreshing];
}
-(void)placeSubviews
{
    [super placeSubviews];
    self.stateLabel.font = [UIFont systemFontOfSize:11];
    
    self.gifView.frame = CGRectMake(SCREEN_W/2-110, 0, 60, 60);
    self.gifView.contentMode = UIViewContentModeScaleAspectFit;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
