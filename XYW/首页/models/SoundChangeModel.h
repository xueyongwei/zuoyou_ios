//
//  SoundChangeModel.h
//  ZuoYou
//
//  Created by xueyognwei on 17/2/5.
//  Copyright © 2017年 xueyongwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "soundChangeEffect.h"
@interface SoundChangeModel : NSObject
@property (nonatomic,copy)NSString *name;
@property (nonatomic,copy)NSString *imgName;
@property (nonatomic,strong)SoundChangeEffect *effect;

/**
 初始化方法

 @param name 显示名
 @param imgName 图片名
 @param tempo 语速
 @param rate 速率
 @param pitch 音调
 @return 自己
 */
-(id)initWithName:(NSString *)name imgName:(NSString *)imgName tempo:(int)tempo rate:(int)rate pitch:(int)pitch;
@end
