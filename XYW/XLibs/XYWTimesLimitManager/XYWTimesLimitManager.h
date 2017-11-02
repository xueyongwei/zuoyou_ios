//
//  XYWTimesLimitManager.h
//  ZuoYou
//
//  Created by xueyongwei on 16/11/10.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <Foundation/Foundation.h>

//key的宏定义
#define KChallengeTimesPerday @"ChallengeTimesPerday"

@interface XYWTimesLimitManager : NSObject
+(instancetype)defaultManager;
-(BOOL)expireWithkey:(NSString *)key;
-(void)addOnceWithKey:(NSString *)key;
@end
