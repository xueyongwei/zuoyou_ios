//
//  ZYUserDefaultsManager.m
//  ZuoYou
//
//  Created by xueyongwei on 2016/11/30.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "ZYUserDefaultsManager.h"

static NSString *const kZYLanchADModel = @"kZYLanchADModeluserDefaultsKey";
static NSString *const kZYEnvironmentModel = @"kZYEnvironmentModeluserDefaultsKey";

@implementation ZYLanchADModel
+(void)clear
{
    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
    [usf removeObjectForKey:kZYLanchADModel];
    [usf synchronize];
}
-(void)save
{
    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = @{@"imageUrl":self.imageUrl,@"linkUrl":self.linkUrl};
    [usf setObject:dic forKey:kZYLanchADModel];
    [usf synchronize];
}
@end
//服务器指定的运行环境
@implementation ZYEnvironmentModel

@end

@implementation ZYUserDefaultsManager
//启动闪屏
+(ZYLanchADModel *)zyLabchAD
{
    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [usf objectForKey:kZYLanchADModel];
    ZYLanchADModel *model = [ZYLanchADModel new];
    model.imageUrl = dic[@"imageUrl"];
    model.linkUrl = dic[@"linkUrl"];
    return model;
}
//运行环境
+(ZYEnvironmentModel *)zyEnvironment
{
    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [usf objectForKey:kZYEnvironmentModel];
    ZYEnvironmentModel *model = [ZYEnvironmentModel new];
    model.isEnvironment = dic[@"isEnvironment"];
    return model;
}
//记录程序启动次数
+(void)recoderLauchTimes
{
    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
    if (![usf objectForKey:GUID]) {
        NSString *str = [NSString stringWithUUID];
        DbLog(@"新生成一个guid = %@",str);
        [usf setObject:str forKey:GUID];
    }
    NSNumber *openTimes = [usf objectForKey:GLOUBOPENTIMES];
    if (openTimes&&openTimes.integerValue>=0) {
        NSInteger time = openTimes.integerValue;
        time++;
        if (time > NSIntegerMax) {//防止未知错误
            time = NSIntegerMax;
        }
        [usf setObject:@(time) forKey:GLOUBOPENTIMES];
    }else{
        [usf setObject:@(1) forKey:GLOUBOPENTIMES];
    }
    [usf synchronize];
}
//查询已经启动的次数
-(NSInteger)lauchTimes
{
    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
    NSNumber *openTimes = [usf objectForKey:GLOUBOPENTIMES];
    return openTimes.integerValue;
}
+(BOOL )isCareStarUser{
    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
    NSNumber *caredStarUser = [usf objectForKey:@"haveCaredStarUser"];
    if (caredStarUser) {
        return YES;
    }
    return NO;
}
+(void)setHaveCaredStarUser{
    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
    [usf setObject:@1 forKey:@"haveCaredStarUser"];
    [usf synchronize];
}
@end
