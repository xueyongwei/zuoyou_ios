//
//  PinglunBodyModel.m
//  HDJ
//
//  Created by xueyongwei on 16/6/29.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "PinglunBodyModel.h"

@implementation PinglunBodyModel
-(void)setCreatedDate:(NSString *)createdDate
{
    _createdDate = createdDate;
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    NSLocale* local =[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    [formater setLocale:local];
    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate* date = [formater dateFromString:createdDate];
    self.timeAgo = fabs([date timeIntervalSinceNow]);
}
-(NSString *)howLongStr{
    NSString *subString = [self.createdDate substringWithRange:NSMakeRange(0, 19)];
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    NSLocale* local =[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    [formater setLocale:local];
    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *lastDate = [formater dateFromString:subString];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    NSString *resultStr = @"";
    if ([lastDate isToday]) {
        [dateFormatter setDateFormat:@"HH:mm"];
    }else if ([lastDate isThisYear]){
        [dateFormatter setDateFormat:@"MM-dd HH:mm"];
    }else{
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    }
    NSString *currentDateStr = [dateFormatter stringFromDate:lastDate];
    return currentDateStr;
    
}
-(NSString *)howLongStr2
{
    double fenzhong = self.timeAgo/60;
    if (fenzhong<=5) {
        return @"刚刚";
    }else if (fenzhong>5&&fenzhong<60){
        return [NSString stringWithFormat:@"%.0f分钟前",fenzhong];;
    }
    double xiaoshi = fenzhong/(60);
    if (xiaoshi<24) {
        return [NSString stringWithFormat:@"%.0f小时前",xiaoshi];
    }
    double tian = xiaoshi/24;
    if (tian<7) {
        return [NSString stringWithFormat:@"%.0f天前",tian];
    }
    double zhou = tian/7;
    if (zhou<4) {
        return [NSString stringWithFormat:@"%.0f周前",zhou];
    }
    double yue = zhou/4;
    if (yue<12) {
        return [NSString stringWithFormat:@"%.0f月前",yue];
    }else{
        return @"早前";
    }
}
@end
