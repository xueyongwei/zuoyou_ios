//
//  MyVideoModel.m
//  ZuoYou
//
//  Created by xueyongwei on 16/9/27.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "MyVideoModel.h"
@interface MyVideoModel()
@property (nonatomic,assign)personalVideoType videoType;
@end
@implementation MyVideoModel
+ (NSDictionary *)mj_objectClassInArray
{
    return @{
             @"versus" : @"PKModel",
             };
}
+(NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"videoID":@"id",
             };
}
-(personalVideoType)videoType
{
   if (!(self.m3u8SRC1M && self.m3u8SRC1M.length>4)) {//没有有效的流地址
       NSDateFormatter* formater = [[NSDateFormatter alloc] init];
       NSLocale* local =[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
       [formater setLocale:local];
       [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
       NSDate* date = [formater dateFromString:self.createdDate];
       if ([date moreThan:10]) {//超过10分钟还没有流地址，说明失败了
           return personalVideoTypeFail;
       }else{
           return personalVideoTypeWaiting;
       }
    }
    return personalVideoTypeDone;
}

-(BOOL)canChallenge
{
    if ([self isMeOfID:self.mid]) {
        return NO;
    }
    if ([self videoType] == personalVideoTypeDone) {//视频已经可以ok了
        NSDateFormatter* formater = [[NSDateFormatter alloc] init];
        NSLocale* local =[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        [formater setLocale:local];
        [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate* date = [formater dateFromString:self.createdDate];
        if ([date isPass7Days]) {//还不超过七天
            return NO;
        }else{
            return YES;
        }
    }else{
        return NO;
    }
}
-(NSString *)m3u8
{
    if (self.m3u8SRC1M) {
        return self.m3u8SRC1M;
    }else if (self.m3u8SRC2M){
        return self.m3u8SRC2M;
    }else if (self.m3u8SRC5M){
        return self.m3u8SRC5M;
    }else if (self.m3u8SRC128K){
        return self.m3u8SRC128K;
    }else{
        return nil;
    }
}
/**
 *  是否是我
 */
-(BOOL)isMeOfID:(NSInteger)userId
{
    if ([self mySelfId] == userId) {
        return YES;
    }
    return NO;
}
/**
 *  我的ID
 */
-(NSInteger )mySelfId
{
    return [UserInfoManager mySelfInfoModel].mid.integerValue;
}

-(NSString *)formatertagName
{
    return [NSString stringWithFormat:@"#%@#",_tagName];
}
@end
