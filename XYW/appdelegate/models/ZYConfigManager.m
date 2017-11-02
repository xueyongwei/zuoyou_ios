//
//  ZYConfigManager.m
//  ZuoYou
//
//  Created by xueyognwei on 16/12/13.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "ZYConfigManager.h"

#define kBadgeOfApp @"notificationBadgeOfApp"

#pragma mark XYWBadgeManager 角标管理器
@implementation XYWBadgeManager
+(void)setBadge:(NSInteger)badge
{
    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
    NSInteger localBadge = [usf integerForKey:kBadgeOfApp]?[usf integerForKey:kBadgeOfApp]:0;
    if (badge == -1) {//badge自增
        localBadge++;
    }else{//设置为服务器设定的badge
        localBadge = badge;
    }
    [usf setInteger:localBadge forKey:kBadgeOfApp];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:localBadge];
    [usf synchronize];
}
@end
#pragma mark ZYConfigManager 升级版本号管理器
@implementation ZYConfigManager
//左右升级版本号（整形数字）
+(NSInteger)thisVersonForUpdata
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *versonStr = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSArray *arr = [versonStr componentsSeparatedByString:@"."];
    if (arr.count ==2) {//eg:2.0
        NSString *a = arr[0];
        NSString *b = arr[1];
        return a.integerValue*100+b.integerValue*10;
    }else if (arr.count ==3){//eg:1.2.2
        NSString *a = arr[0];
        NSString *b = arr[1];
        NSString *c = arr[2];
        return a.integerValue*100+b.integerValue*10+c.integerValue;
    }else{
        return 0;
    }
}

@end
