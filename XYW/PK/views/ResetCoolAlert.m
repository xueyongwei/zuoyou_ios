//
//  ResetCoolAlert.m
//  ZuoYou
//
//  Created by xueyongwei on 2016/11/28.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "ResetCoolAlert.h"
#import "YYLabel.h"
#import "YYText.h"

@interface ResetCoolAlert()
@property (weak, nonatomic) IBOutlet YYLabel *JumpTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
@property (weak, nonatomic) IBOutlet UIButton *useBtn;

@property (nonatomic,strong) void(^okTmpBlock)(void);
@property (nonatomic,assign)NSInteger sec;
@end
@implementation ResetCoolAlert
-(void)awakeFromNib
{
    [super awakeFromNib];
    
}
-(void)showWithTime:(NSInteger)sec praiseRestCost:(NSNumber *)count  showIn:(UIView *)superView tips:(NSString *)tips okClick:(void (^)(void))okBlock
{
    NSMutableAttributedString *yyCoolText = [NSMutableAttributedString new];
    UIFont *font = [UIFont systemFontOfSize:14];
    NSString *title = @"使用";
    [yyCoolText appendAttributedString:[[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexColorString:@"333333"],NSFontAttributeName:font}]];
    UIImage *image = [UIImage imageNamed:@"胜方获得金豆"];
    image = [UIImage imageWithCGImage:image.CGImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:image contentMode:UIViewContentModeScaleAspectFit attachmentSize:CGSizeMake(15, 13) alignToFont:font alignment:YYTextVerticalAlignmentCenter];
    [yyCoolText appendAttributedString:attachText];
    
    [yyCoolText appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"x%@",count] attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexColorString:@"ffc10d"],NSFontAttributeName:font}]];
    [yyCoolText appendAttributedString:[[NSAttributedString alloc] initWithString:@"跳过等待" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexColorString:@"333333"],NSFontAttributeName:font}]];
    yyCoolText.yy_alignment = NSTextAlignmentCenter;
    self.JumpTextLabel.attributedText = yyCoolText;
    self.timeLabel.text = [NSString stringWithFormat:@"%@后可点赞",[self stringWithSec:sec]];
    self.tipsLabel.text = tips;
    self.okTmpBlock = okBlock;
    self.sec = sec;
//    [self show];
    [self showIn:superView];
}
-(void)timerTast
{
    self.sec--;
    self.timeLabel.text = [NSString stringWithFormat:@"%@后可点赞",[self stringWithSec:self.sec]];
}
-(NSString *)stringWithSec:(NSInteger)sec
{
    NSInteger h = sec/3600>0?sec/3600>=0:0;
    NSInteger m = (sec%3600)/60>0?(sec%3600)/60:0;
    NSInteger s = sec%60>0?sec%60:0;
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld",h,m,s];
}
-(void)show
{
    [[UIApplication sharedApplication].windows.lastObject addSubview:self];
    self.frame = [UIApplication sharedApplication].windows.lastObject.bounds;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(timerTast) name:GLOBLETIMER object:nil];
}
-(void)showIn:(UIView *)superView
{
    self.frame = superView.bounds;
    [superView addSubview:self];
}
-(void)dismiss
{
    [self removeFromSuperview];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (IBAction)onCancle:(UIButton *)sender {
    [self dismiss];
}
- (IBAction)onOk:(UIButton *)sender {
    [self canUse:NO];
    self.okTmpBlock();
}

-(void)canUse:(BOOL)can{
    self.useBtn.enabled = can;
}

@end
