//
//  JXModel.m
//  HDJ
//
//  Created by xueyongwei on 16/5/13.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "JingXuanModel.h"

@implementation JingXuanModel
+ (instancetype)JingXuanModelWithTitle:(NSString*)title time:(int)time {
    
    JingXuanModel *model = [self new];
    
    model.pkTitle = title;
    model.LeftTimeSeconds = time;
    
    return model;
}
- (void)countDown {
    _LeftTimeSeconds -= 1;
}
//返回固定格式的时间串
- (NSString*)currentTimeString {
    if (_LeftTimeSeconds <= 0) {
        return @"已结束";
    } else {
        return [NSString stringWithFormat:@"%01ld天%02ld:%02ld:%02ld",(long)_LeftTimeSeconds/86400,(long)(_LeftTimeSeconds%86400)/3600,(long)_LeftTimeSeconds%3600/60,(long)_LeftTimeSeconds%60];
    }
}

@end
