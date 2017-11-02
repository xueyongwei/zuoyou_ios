//
//  PKModel.m
//  HDJ
//
//  Created by xueyongwei on 16/6/8.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "PKModel.h"
#import "YYText.h"
@implementation PraiseInfoModel

@end
@implementation PKModel
+ (NSDictionary *)mj_objectClassInArray
{
    return @{
             @"contestantVideos" : @"contestantVideosModel",
             };
}
+(NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
                @"pkID":@"id",
             };
}
-(void)cutDown
{
    if (self.praiseInfo) {//点赞冷却时间
        if (self.praiseInfo.praiseColdDownSec<=0) {
            self.praiseInfo.praiseColdDownSec = 0;
        }else{
            self.praiseInfo.praiseColdDownSec --;
        }
    }
}
-(void)setWinBonus:(NSInteger)winBonus
{
    _winBonus = winBonus;
}
-(NSMutableAttributedString *)huoshengText
{
    NSMutableAttributedString *_huoshengText = [NSMutableAttributedString new];
    UIFont *font = [UIFont systemFontOfSize:11];
    NSString *title = @"胜方获得";
    [_huoshengText appendAttributedString:[[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexColorString:@"888888"],NSFontAttributeName:font}]];
    UIImage *image = [UIImage imageNamed:@"胜方获得金豆"];
    image = [UIImage imageWithCGImage:image.CGImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:image contentMode:UIViewContentModeScaleAspectFit attachmentSize:CGSizeMake(15, 12) alignToFont:font alignment:YYTextVerticalAlignmentCenter];
    [_huoshengText appendAttributedString:attachText];
    [_huoshengText appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld",(long)self.winBonus] attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexColorString:@"ffc133"],NSFontAttributeName:font}]];
    _huoshengText.yy_alignment = NSTextAlignmentRight;
    return _huoshengText;
}
- (NSString*)currentTimeString {
    long seconds = [self SecondSinceNow];
    if (self.winnerVersusContestantId) {
        return @"已结束";
    } else {
        if (seconds <= 0) {
            return @"00:00:00";
        }
        if (seconds/86400 > 0) {
            return [NSString stringWithFormat:@"%01ld天%02ld:%02ld:%02ld",seconds/86400,(seconds%86400)/3600,seconds%3600/60,seconds%60];
        }else{
            return [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(seconds%86400)/3600,seconds%3600/60,seconds%60];
        }
    }
}
-(long)SecondSinceNow
{
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    NSLocale* local =[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    [formater setLocale:local];
    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate* date = [formater dateFromString:self.deadLine];
    return  [date timeIntervalSinceNow];
}
-(NSString *)formatertagName
{
    return [NSString stringWithFormat:@"#%@#",_tagName];
}

//- (NSMutableAttributedString*)currentTimeStringInPkdetail {
//    
//    if (self.winnerVersusContestantId) {
//        NSMutableAttributedString *text = [NSMutableAttributedString new];
//        UIFont *font = [UIFont systemFontOfSize:11];
//        NSString *title = @"赢得";
//        [text appendAttributedString:[[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexColorString:@"888888"]}]];
//        UIImage *image = [UIImage imageNamed:@"胜方获得金豆"];
//        image = [UIImage imageWithCGImage:image.CGImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
//        NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:image contentMode:UIViewContentModeScaleAspectFit attachmentSize:CGSizeMake(15, 12) alignToFont:font alignment:YYTextVerticalAlignmentCenter];
//        [text appendAttributedString:attachText];
//        
//        [text appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld",(long)self.winBonus] attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexColorString:@"ffc133"]}]];
//        
//        text.yy_alignment = NSTextAlignmentCenter;
//        
//        return text;
//        
//    } else {
//        NSMutableAttributedString *text = [NSMutableAttributedString new];
//        text.yy_alignment = NSTextAlignmentCenter;
//        if (self.deadLine <= 0) {
//            [text appendAttributedString:[[NSAttributedString alloc] initWithString:@"0天00:00:00" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexColorString:@"888888"]}]];
//            return text;
//        }
//        NSString *timeStr = [NSString stringWithFormat:@"%01ld天%02ld:%02ld:%02ld",(long)self.deadLine/86400,(long)(self.deadLine%86400)/3600,(long)self.deadLine%3600/60,(long)self.deadLine%60];
//        [text appendAttributedString:[[NSAttributedString alloc] initWithString:timeStr attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexColorString:@"888888"]}]];
//        return text;
//    }
//}

@end
