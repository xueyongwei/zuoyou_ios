//
//  ZYConfigManager.h
//  ZuoYou
//
//  Created by xueyognwei on 16/12/13.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//
/*
 此处纪录和设备相关的本地存储
 */
#import <Foundation/Foundation.h>
@interface XYWBadgeManager : NSObject
+(void)setBadge:(NSInteger)badge;
@end

@interface ZYConfigManager : NSObject
//左右升级版本号（整形数字）
+(NSInteger)thisVersonForUpdata;

@end
