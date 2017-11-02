//
//  PkProgressView.m
//  XYW
//
//  Created by xueyongwei on 16/6/3.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "PkProgressView.h"
#define PkPadding 2
@implementation PkProgressView
{
    UIView *_v1;
    UIView *_v2;
}
//-(id)initWithFrame:(CGRect)frame
//{
//    if (self = [super initWithFrame:frame]) {
//        [self initSubviews];
//    }
//    return self;
//}
//-(id)initWithCoder:(NSCoder *)aDecoder
//{
//    if (self = [super initWithCoder:aDecoder]) {
//        [self initSubviews];
//    }
//    return self;
//}
//-(void)initSubviews
//{
////    _v1 = [UIView new];
////    _v1.alpha = 1.0;
////    
////    _v1.backgroundColor = [UIColor redColor];
////    _v1.clipsToBounds = YES;
////    _v1.layer.cornerRadius = self.frame.size.height/2;
////    [self addSubview:_v1];
////    
////    _v2 = [UIView new];
////    _v2.clipsToBounds = YES;
////    _v2.layer.cornerRadius = self.frame.size.height/2;
//////    _v2.backgroundColor = [UIColor colorWithHexColorString:@"03a9f3"];
////    _v2.backgroundColor = [UIColor blackColor];
////    [self addSubview:_v2];
////    [_v1 mas_makeConstraints:^(MASConstraintMaker *make) {
////        make.top.equalTo(self.mas_top);
////        make.bottom.equalTo(self.mas_bottom);
////        make.left.equalTo(self.mas_left);
////        make.width.equalTo(self.mas_width).multipliedBy(0.5);
////    }];
////    
////    [_v2 mas_makeConstraints:^(MASConstraintMaker *make) {
////        make.top.equalTo(self.mas_top);
////         make.bottom.equalTo(self.mas_bottom);
////        make.left.equalTo(_v1.mas_right).offset(PkPadding);
////        make.right.equalTo(self.mas_right);
////    }];
//    
//}
-(void)setPercent:(double)percent
{
    if (percent<0.01) {
        percent = 0.01;
    }else if (percent>0.98){
        percent = 0.98;
    }
    _percent = percent;
    CGFloat valueWidth = self.frame.size.width-PkPadding;
    _v1.frame = CGRectMake(0, 0, valueWidth*percent, 5);
    _v2.frame = CGRectMake(valueWidth*percent+PkPadding, 0, valueWidth*(1.0-percent), 5);
//    _percent = percent;
//    DbLog(@"percent=%f",percent);
//    if (percent<0.01) {
//        percent = 0.01;
//    }else if (percent>0.98){
//        percent = 0.98;
//    }
//    [_v1 mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.mas_top);
//        make.bottom.equalTo(self.mas_bottom);
//        make.left.equalTo(self.mas_left);
//        make.width.equalTo(self.mas_width).multipliedBy(0.8);
//    }];
//    [_v2 mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.mas_top);
//        make.bottom.equalTo(self.mas_bottom);
//        make.left.equalTo(_v1.mas_right).offset(PkPadding);
//        make.right.equalTo(self.mas_right);
//    }];
//    [self updateConstraints];
//    [self layoutIfNeeded];
//    [self bringSubviewToFront:_v1];
//    [self bringSubviewToFront:_v2];

}
-(void)drawRect:(CGRect)rect
{
    if (_v1) {
        [_v1 removeFromSuperview];
    }
    if (_v2) {
        [_v2 removeFromSuperview];
    }
    _v1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width*0.5-PkPadding/2, 5)];
    
    _v1.backgroundColor = [UIColor colorWithHexColorString:@"ff4a4b"];
    _v1.clipsToBounds = YES;
    _v1.layer.cornerRadius = self.frame.size.height/2;
    [self addSubview:_v1];
    
    _v2 = [[UIView alloc]initWithFrame:CGRectMake(self.frame.size.width*0.5 + PkPadding, 0, self.frame.size.width*0.5-PkPadding/2, 5)];
    _v2.clipsToBounds = YES;
    _v2.layer.cornerRadius = self.frame.size.height/2;
        _v2.backgroundColor = [UIColor colorWithHexColorString:@"03a9f3"];
//    _v2.backgroundColor = [UIColor blackColor];
    [self addSubview:_v2];
//    [_v1 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.mas_top);
//        make.bottom.equalTo(self.mas_bottom);
//        make.left.equalTo(self.mas_left);
//        make.width.equalTo(self.mas_width).multipliedBy(0.5);
//    }];
//    
//    [_v2 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.mas_top);
//        make.bottom.equalTo(self.mas_bottom);
//        make.left.equalTo(_v1.mas_right).offset(PkPadding);
//        make.right.equalTo(self.mas_right);
//    }];
}

@end
