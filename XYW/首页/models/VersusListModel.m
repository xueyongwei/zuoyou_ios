//
//  VersusListModel.m
//  ZuoYou
//
//  Created by xueyongwei on 16/10/26.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "VersusListModel.h"
#import "YYText.h"
@implementation VersusListModel
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
    if (self.deadLine<0) {
        self.deadLine = 0;
    }else{
        self.deadLine --;
    }
    
}
-(void)setWinBonus:(NSInteger)winBonus
{
    _winBonus = winBonus;
    if (!_huoshengText) {
        _huoshengText = [NSMutableAttributedString new];
        UIFont *font = [UIFont systemFontOfSize:11];
        NSString *title = @"胜方获得";
        [_huoshengText appendAttributedString:[[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexColorString:@"888888"]}]];
        UIImage *image = [UIImage imageNamed:@"胜方获得金豆"];
        image = [UIImage imageWithCGImage:image.CGImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
        NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:image contentMode:UIViewContentModeScaleAspectFit attachmentSize:CGSizeMake(15, 12) alignToFont:font alignment:YYTextVerticalAlignmentCenter];
        [_huoshengText appendAttributedString:attachText];
        [_huoshengText appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld",(long)self.winBonus] attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexColorString:@"ffc133"]}]];
        _huoshengText.yy_alignment = NSTextAlignmentRight;
    }
}
- (NSString*)currentTimeString {
    
    if (self.winnerVersusContestantId) {
        return @"已结束";
    } else {
        if (self.deadLine <= 0) {
            return @"0天00:00:00";
        }
        return [NSString stringWithFormat:@"%01ld天%02ld:%02ld:%02ld",(long)self.deadLine/86400,(long)(self.deadLine%86400)/3600,(long)self.deadLine%3600/60,(long)self.deadLine%60];
    }
}
- (NSMutableAttributedString*)currentTimeStringInPkdetail {
    
    if (self.winnerVersusContestantId) {
        NSMutableAttributedString *text = [NSMutableAttributedString new];
        UIFont *font = [UIFont systemFontOfSize:11];
        NSString *title = @"赢得";
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexColorString:@"888888"]}]];
        UIImage *image = [UIImage imageNamed:@"胜方获得金豆"];
        image = [UIImage imageWithCGImage:image.CGImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
        NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:image contentMode:UIViewContentModeScaleAspectFit attachmentSize:CGSizeMake(15, 12) alignToFont:font alignment:YYTextVerticalAlignmentCenter];
        [text appendAttributedString:attachText];
        
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld",(long)self.winBonus] attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexColorString:@"ffc133"]}]];
        
        text.yy_alignment = NSTextAlignmentCenter;
        
        return text;
        
    } else {
        NSMutableAttributedString *text = [NSMutableAttributedString new];
        text.yy_alignment = NSTextAlignmentCenter;
        if (self.deadLine <= 0) {
            [text appendAttributedString:[[NSAttributedString alloc] initWithString:@"0天00:00:00" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexColorString:@"888888"]}]];
            return text;
        }
        NSString *timeStr = [NSString stringWithFormat:@"%01ld天%02ld:%02ld:%02ld",(long)self.deadLine/86400,(long)(self.deadLine%86400)/3600,(long)self.deadLine%3600/60,(long)self.deadLine%60];
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:timeStr attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexColorString:@"888888"]}]];
        return text;
    }
}
@end
