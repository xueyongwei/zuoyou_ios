//
//  XYWTimesLimitManager.m
//  ZuoYou
//
//  Created by xueyongwei on 16/11/10.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "XYWTimesLimitManager.h"

@implementation XYWTimesLimitManager
+(instancetype)defaultManager
{
    static XYWTimesLimitManager *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [[self alloc] init];
    });
    return sharedAccountManagerInstance;
}
-(NSInteger)timesLimitForKey:(NSString *)key
{
    if ([key isEqualToString:KChallengeTimesPerday]) {
        return 3;
    }
    return 0;
}
-(BOOL)expireWithkey:(NSString *)key
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[self dicWithKey:key]];
    NSDate *localDate = [dic objectForKey:@"date"];
    if (localDate && [localDate isToday]) {//有时间且是今天
        NSNumber *timesNub = [dic objectForKey:@"times"];
        if (timesNub.integerValue>[self timesLimitForKey:key]) {//次数超过了
            return YES;
        }
    }
    return NO;
}
-(void)addOnceWithKey:(NSString *)key
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[self dicWithKey:key]];
    NSDate *localDate = [dic objectForKey:@"date"];
    if (localDate && [localDate isToday]) {//有时间且是今天
        NSNumber *timesNub = [dic objectForKey:@"times"];
        NSInteger times = timesNub.integerValue +1;
        [dic setObject:@(times) forKey:@"times"];
    }else{
        [dic setObject:[NSDate date] forKey:@"date"];
        [dic setObject:@1 forKey:@"times"];
    }
    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
    [usf setObject:dic forKey:key];
    [usf synchronize];
}
-(NSMutableDictionary *)dicWithKey:(NSString *)key
{
    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *localDic = [usf objectForKey:key];
    if (localDic && [localDic isKindOfClass:[NSMutableDictionary class]]) {
        return localDic;
    }else{
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [usf setObject:dic forKey:key];
        [usf synchronize];
        return dic;
    }
}
@end
