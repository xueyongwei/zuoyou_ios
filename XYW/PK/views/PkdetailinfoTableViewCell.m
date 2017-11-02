//
//  PkdetailinfoTableViewCell.m
//  XYW
//
//  Created by xueyongwei on 16/9/1.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "PkdetailinfoTableViewCell.h"
#import "PkProgressView.h"
#import "GongxianModel.h"
#import "AppDelegate.h"
@interface PkdetailinfoTableViewCell()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pinglunXian;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fengexian;
@property (weak, nonatomic) IBOutlet UILabel *leftBeansLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightBeansLabel;
@property (weak, nonatomic) IBOutlet PkProgressView *pkProgressView;
@property (nonatomic,strong) UIImageView *coolAnimationView;
@property (weak, nonatomic) IBOutlet UIButton *leftGiftBtn;
@property (nonatomic,strong)UIButton *coolBtnPointer;

@property (nonatomic,strong)NSMutableDictionary *userDataDic;
@end

@implementation PkdetailinfoTableViewCell
-(UIImageView *)coolAnimationView
{
    if (!_coolAnimationView) {
        _coolAnimationView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
        _coolAnimationView.image = [UIImage imageNamed:@"cooling沙漏icon"];
        _coolAnimationView.userInteractionEnabled = NO;
        
    }
    return _coolAnimationView;
}
-(NSMutableDictionary *)userDataDic
{
    if (!_userDataDic) {
        _userDataDic = [NSMutableDictionary new];
    }
    return _userDataDic;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    self.pinglunXian.constant = SINGLE_LINE_WIDTH;
    self.fengexian.constant = SINGLE_LINE_WIDTH;
    // Initialization code
}
-(void)setL:(NSInteger)lbeans andR:(NSInteger)rbeans
{
    self.leftBeansLabel.text = [NSString stringWithFormat:@"%ld",(long)lbeans];
    self.rightBeansLabel.text = [NSString stringWithFormat:@"%ld",(long)rbeans];
    NSInteger total = lbeans + rbeans;
    
    if (total==0) {
        self.pkProgressView.percent = 0.5;
    }else{
        if (rbeans ==0){
            self.pkProgressView.percent = 0.98;
        }else{
            double per = (double)lbeans / (double)(lbeans+rbeans);
            self.pkProgressView.percent = per;
        }
    }
}
//-(void)setFansIconWithFans:(NSArray *)fans
//{
//    int i = 0;
//    for (UIView *view in self.fansView.subviews) {
//        [view removeFromSuperview];
//    }
//    for (GongxianModel *model in fans) {
//        UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(i*35, 0, 24, 24)];
//        imgV.clipsToBounds = YES;
//        imgV.layer.cornerRadius = 12;
//        [self setIconImageV:imgV with:model.mid];
//        imgV.layer.borderWidth = 1;
//        imgV.layer.borderColor = [model.contestantRole isEqualToString:@"RED"]?[UIColor colorWithHexColorString:@"f44236"].CGColor:[UIColor colorWithHexColorString:@"03a9f3"].CGColor;
//        [self.fansView addSubview:imgV];
//        i++;
//    }
//}

//-(void)setPraiseBtnLight:(BOOL)PraiseBtnLight
//{
//    _PraiseBtnLight = PraiseBtnLight;
//    if (PraiseBtnLight) {
//        [self.leftGiftBtn setImage:[UIImage imageNamed:@"礼物-红"] forState:UIControlStateNormal];
//        [self.rightGiftBtn setImage:[UIImage imageNamed:@"礼物-蓝"] forState:UIControlStateNormal];
//    }else{
//        UIImage *img = [UIImage imageNamed:@"礼物按钮灰"];
//        [self.leftGiftBtn setImage:img forState:UIControlStateNormal];
//        [self.rightGiftBtn setImage:img forState:UIControlStateNormal];
//        [self spinWithOptions:UIViewAnimationOptionCurveLinear];
//    }
//}
-(void)setPraiseBtnState:(versusPraiseBtnState)praiseBtnState
{
    if (praiseBtnState==versusPraiseStateNormal) {//正常
        [self.leftGiftBtn setImage:[UIImage imageNamed:@"支持-红icon"] forState:UIControlStateNormal];
        [self.leftGiftBtn setImage:[UIImage imageNamed:@"支持-红icon-click"] forState:UIControlStateHighlighted];
        [self.rightGiftBtn setImage:[UIImage imageNamed:@"支持-蓝icon"] forState:UIControlStateNormal];
        [self.rightGiftBtn setImage:[UIImage imageNamed:@"支持-蓝icon-click"] forState:UIControlStateHighlighted];
        if (_coolAnimationView && _coolAnimationView.superview) {//不能有动画图
            [_coolAnimationView removeFromSuperview];
        }
    }
    if (praiseBtnState == versusPraiseStateEnd) {//结束
        [self.leftGiftBtn setImage:[UIImage imageNamed:@"支持-红icon-灰"] forState:UIControlStateNormal];
        [self.rightGiftBtn setImage:[UIImage imageNamed:@"支持-蓝icon-灰"] forState:UIControlStateNormal];
        if (_coolAnimationView && _coolAnimationView.superview) {//不能有动画图
            [_coolAnimationView removeFromSuperview];
        }
    }
    if (praiseBtnState == versusPraiseStateCoolingLeft) {//左边在冷却
        [self.leftGiftBtn setImage:[UIImage imageNamed:@"沙漏-红icon-bg"] forState:UIControlStateNormal];
        [self.rightGiftBtn setImage:[UIImage imageNamed:@"支持-蓝icon-灰"] forState:UIControlStateNormal];
        [self.leftGiftBtn addSubview:self.coolAnimationView];
        [self showAnimation];
    }
    if (praiseBtnState == (versusPraiseStateCoolingLeft|versusPraiseStateCooled)) {//左边冷却好了
        [self.leftGiftBtn setImage:[UIImage imageNamed:@"支持-红icon"] forState:UIControlStateNormal];
        [self.rightGiftBtn setImage:[UIImage imageNamed:@"支持-蓝icon-灰"] forState:UIControlStateNormal];
        [self.leftGiftBtn addSubview:self.coolAnimationView];
        if (_coolAnimationView && _coolAnimationView.superview) {//不能有动画图
            [_coolAnimationView removeFromSuperview];
        }
    }
    if (praiseBtnState == versusPraiseStateCoolingRight) {//右边在冷却
        [self.leftGiftBtn setImage:[UIImage imageNamed:@"支持-红icon-灰"] forState:UIControlStateNormal];
        [self.rightGiftBtn setImage:[UIImage imageNamed:@"沙漏-蓝icon-bg"] forState:UIControlStateNormal];
        [self.rightGiftBtn addSubview:self.coolAnimationView];
        [self showAnimation];
    }
    if (praiseBtnState == (versusPraiseStateCoolingRight|versusPraiseStateCooled)) {//右边冷却好了
        [self.leftGiftBtn setImage:[UIImage imageNamed:@"支持-红icon-灰"] forState:UIControlStateNormal];
        [self.rightGiftBtn setImage:[UIImage imageNamed:@"支持-蓝icon"] forState:UIControlStateNormal];
        [self.rightGiftBtn addSubview:self.coolAnimationView];
        if (_coolAnimationView && _coolAnimationView.superview) {//不能有动画图
            [_coolAnimationView removeFromSuperview];
        }
    }
}
//    switch (praiseBtnState) {
//        case versusPraiseStateNormal:
//        {
//            [self.leftGiftBtn setImage:[UIImage imageNamed:@"支持-红icon"] forState:UIControlStateNormal];
//            [self.leftGiftBtn setImage:[UIImage imageNamed:@"支持-红icon-click"] forState:UIControlStateHighlighted];
//            [self.rightGiftBtn setImage:[UIImage imageNamed:@"支持-蓝icon"] forState:UIControlStateNormal];
//            [self.rightGiftBtn setImage:[UIImage imageNamed:@"支持-蓝icon-click"] forState:UIControlStateHighlighted];
//            if (_coolAnimationView && _coolAnimationView.superview) {//不能有动画图
//                [_coolAnimationView removeFromSuperview];
//            }
//        }
//            break;
//        case versusPraiseStateEnd:
//        {
//            [self.leftGiftBtn setImage:[UIImage imageNamed:@"支持-红icon-灰"] forState:UIControlStateNormal];
//            [self.rightGiftBtn setImage:[UIImage imageNamed:@"支持-蓝icon-灰"] forState:UIControlStateNormal];
//            if (_coolAnimationView && _coolAnimationView.superview) {//不能有动画图
//                [_coolAnimationView removeFromSuperview];
//            }
//        }
//            break;
//        case versusPraiseStateCoolingLeft:
//        {
//            [self.leftGiftBtn setImage:[UIImage imageNamed:@"沙漏-红icon-bg"] forState:UIControlStateNormal];
//            [self.rightGiftBtn setImage:[UIImage imageNamed:@"支持-蓝icon-灰"] forState:UIControlStateNormal];
//            [self.leftGiftBtn addSubview:self.coolAnimationView];
//            [self showAnimation];
//        }
//            break;
//        case versusPraiseStateCoolingRight:
//        {
//            [self.leftGiftBtn setImage:[UIImage imageNamed:@"支持-红icon-灰"] forState:UIControlStateNormal];
//            [self.rightGiftBtn setImage:[UIImage imageNamed:@"沙漏-蓝icon-bg"] forState:UIControlStateNormal];
//            [self.rightGiftBtn addSubview:self.coolAnimationView];
//            [self showAnimation];
//        }
//            break;
//
//    }
//}
//static BOOL overCircle = NO;
-(void)showAnimation
{
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveLinear
                     animations: ^{
                         self.coolAnimationView.transform = CGAffineTransformRotate(self.coolAnimationView.transform, M_PI );
                     }
                     completion: ^(BOOL finished) {
                         //                         if (finished) {
                         //                                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                         //                                     [self showAnimation];
                         //                                 });
                         ////                             }else{
                         ////                                 [self showAnimation];
                         ////                             }
                         ////                             overCircle = !overCircle;
                         //                         }
                     }];
    
}
//- (void) spinWithOptions: (UIViewAnimationOptions) options {
//    DbLog(@"hahahhaha");
//    if (animating) {
//        return;
//    }
//    [UIView animateWithDuration: 1.0f
//                          delay: 0.0f
//                        options: options
//                     animations: ^{
//                         animating = YES;
//                         self.leftGiftBtn.transform = CGAffineTransformRotate(self.leftGiftBtn.transform, M_PI );
//                     }
//                     completion: ^(BOOL finished) {
//                         if (finished) {
//                             animating = NO;
//                         }
//                     }];
//}

- (IBAction)onLeftClick:(id)sender {
    [self.delegate onLeftGiftsClick];
}
- (IBAction)onRightClick:(id)sender {
    [self.delegate onRightGiftsClick];
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
