//
//  XiaoxiBodyModel.m
//  HDJ
//
//  Created by xueyongwei on 16/7/22.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "XiaoxiBodyModel.h"

@implementation XiaoxiBodyModel
+(NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"xiaoxiID":@"id",
             };
}
-(void)setContent:(NSString *)content
{
    _content = content;
    _contenText = [[NSMutableAttributedString alloc] initWithData:[content dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    
    
    //段落样式
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    //行间距
    paragraphStyle.lineSpacing = 5.0;
    
//    //段落间距
//    paragraphStyle.paragraphSpacing = 20.0;
    //    paragraphStyle.baseWritingDirection = NSWritingDirectionLeftToRight;
    //    paragraphStyle.firstLineHeadIndent = 10.0;
    //    paragraphStyle.headIndent = 50.0;
    //    paragraphStyle.tailIndent = 200.0;
    [_contenText addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, _contenText.length)];
}
-(void)setCreatedDate:(NSString *)createdDate
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _createdDate = createdDate;
        self.howLongStr = [self changeTheDateString:createdDate];
        self.listTimeStr = [self changeTheDateListString:createdDate];
    });
    
//    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
//    NSLocale* local =[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
//    [formater setLocale:local];
//    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSDate* date = [formater dateFromString:createdDate];
//    self.timeAgo = fabs([date timeIntervalSinceNow]);
}
//-(NSString *)howLongStr{
//    NSString *subString = [self.createdDate substringWithRange:NSMakeRange(0, 19)];
//    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
//    NSLocale* local =[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
//    [formater setLocale:local];
//    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSDate *lastDate = [formater dateFromString:subString];
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    //    NSString *resultStr = @"";
//    if ([lastDate isToday]) {
//        [dateFormatter setDateFormat:@"HH:mm"];
//    }else if ([lastDate isThisYear]){
//        [dateFormatter setDateFormat:@"MM-dd HH:mm"];
//    }else{
//        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
//    }
//    NSString *currentDateStr = [dateFormatter stringFromDate:lastDate];
//    return currentDateStr;
//    
//}
- (NSString *)changeTheDateListString:(NSString *)Str
{
    NSString *subString = [Str substringWithRange:NSMakeRange(0, 19)];
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    NSLocale* local =[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    [formater setLocale:local];
    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate* lastDate = [formater dateFromString:subString];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    NSString *resultStr = @"";
    if ([lastDate isToday]) {
        [dateFormatter setDateFormat:@"HH:mm"];
    }else if ([lastDate isThisYear]){
        [dateFormatter setDateFormat:@"MM-dd"];
    }else{
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    }
    NSString *currentDateStr = [dateFormatter stringFromDate:lastDate];
    return currentDateStr;
}
- (NSString *)changeTheDateString:(NSString *)Str
{
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
