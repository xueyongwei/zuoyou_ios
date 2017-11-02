//
//  GlobalInstance.m
//  ZuoYou
//
//  Created by xueyognwei on 2017/2/21.
//  Copyright © 2017年 xueyongwei. All rights reserved.
//

#import "GlobalInstance.h"

@implementation GlobalInstance
+(GlobalInstance *)shareInstance
{
    static GlobalInstance *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}
-(NSMutableArray *)sessionListDataSource
{
    if (!_sessionListDataSource) {
        _sessionListDataSource = [NSMutableArray new];
    }
    return _sessionListDataSource;
}
@end
