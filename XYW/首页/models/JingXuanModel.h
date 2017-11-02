//
//  JXModel.h
//  HDJ
//
//  Created by xueyongwei on 16/5/13.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JingXuanModel : NSObject
@property (nonatomic,copy)NSString *pkTitle;
@property (nonatomic,assign)int LeftTimeSeconds;
@property (nonatomic,assign)int shengfangMoney;
@property (nonatomic,copy)NSString *user1Icon;
@property (nonatomic,copy)NSString *user1Name;
@property (nonatomic,assign)int user1Suport;
@property (nonatomic,copy)NSString *user1PKimg;
@property (nonatomic,copy)NSString *user2Icon;
@property (nonatomic,copy)NSString *user2Name;
@property (nonatomic,assign)int user2Suport;
@property (nonatomic,copy)NSString *user2PKimg;
/**
 *  便利构造器
 *
 *  @param title         标题
 *  @param countdownTime 倒计时
 *
 *  @return 实例对象
 */
+ (instancetype)JingXuanModelWithTitle:(NSString*)title time:(int)time;
/**
 *  计数减1(countdownTime - 1)
 */
- (void)countDown;

/**
 *  将当前的countdownTime信息转换成字符串
 */
- (NSString *)currentTimeString;
@end
