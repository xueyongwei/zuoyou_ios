//
//  GuideView.m
//  GuideDemo
//
//  Created by 李剑钊 on 15/7/23.
//  Copyright (c) 2015年 sunli. All rights reserved.
//

#import "QiehuanGuideView.h"


@interface QiehuanGuideView ()

@property (nonatomic, weak) UIView *parentView;
@property (nonatomic, strong) UIView *maskBg;
@property (nonatomic, strong) UIButton *okBtn;

@property (nonatomic, weak) UIButton *maskBtn;

@property (nonatomic, strong) UIView *topMaskView;
@property (nonatomic, strong) UIView *bottomMaskView;
@property (nonatomic, strong) UIView *leftMaskView;
@property (nonatomic, strong) UIView *rightMaskView;

@end

@implementation QiehuanGuideView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.topMaskView];
        [self addSubview:self.bottomMaskView];
        [self addSubview:self.leftMaskView];
        [self addSubview:self.rightMaskView];
        [self addSubview:self.okBtn];
        [self addSubview:self.btnMaskView];
        [self addSubview:self.arrwoView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.frame = _parentView.bounds;
    _maskBg.frame = self.bounds;
    _btnMaskView.center = [_maskBtn.superview convertPoint:_maskBtn.center toView:_maskBtn.superview];
    
    CGRect btnMaskRect = _btnMaskView.frame;
    btnMaskRect.size = CGSizeMake(floor(btnMaskRect.size.width), floor(btnMaskRect.size.height));
    btnMaskRect.origin = CGPointMake(floor(btnMaskRect.origin.x), floor(btnMaskRect.origin.y+64));
    _btnMaskView.frame = btnMaskRect;
    
    
    
    _topMaskView.left = 0;
    _topMaskView.top = 0;
    _topMaskView.height = _btnMaskView.top;
    _topMaskView.width = self.width;
    
    _bottomMaskView.left = 0;
    _bottomMaskView.top = _btnMaskView.bottom;
    _bottomMaskView.width = self.width;
    _bottomMaskView.height = self.height - _bottomMaskView.top;
    
    _leftMaskView.left = 0;
    _leftMaskView.top = _btnMaskView.top;
    _leftMaskView.width = _btnMaskView.left;
    _leftMaskView.height = _btnMaskView.height;
    
    _rightMaskView.left = _btnMaskView.right;
    _rightMaskView.top = _btnMaskView.top;
    _rightMaskView.width = self.width - _rightMaskView.left;
    _rightMaskView.height = _btnMaskView.height;
    
    _arrwoView.right = _btnMaskView.left;
    _arrwoView.bottom = _btnMaskView.bottom - 15;
    
    _okBtn.centerX = self.width-35;
    _okBtn.top = self.top+30;
}
-(void)onNextTap:(UITapGestureRecognizer *)recognizer
{
    [self.delegate QiehuanGuideNext];
    [self dismiss];
}


- (void)showInView:(UIView *)view maskBtn:(UIButton *)btn {
    self.parentView = view;
    self.maskBtn = btn;
    
    self.alpha = 0;
    [view addSubview:self];
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1;
    } completion:nil];
}

- (void)dismiss {
    [[NSUserDefaults standardUserDefaults]setObject:@YES forKey:KGuider];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self removeFromSuperview];
//    [UIView animateWithDuration:0.2 animations:^{
//        self.alpha = 0;
//    } completion:^(BOOL finished) {
//        [self removeFromSuperview];
//    }];
}

#pragma mark - getter and setter

- (UIView *)maskBg {
    if (!_maskBg) {
        UIView *view = [[UIView alloc] init];
        _maskBg = view;
    }
    return _maskBg;
}

- (UIButton *)okBtn {
    if (!_okBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"guideokBtn"] forState:UIControlStateNormal];
        [btn sizeToFit];
        [btn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        _okBtn = btn;
    }
    return _okBtn;
}

- (UIImageView *)btnMaskView {
    if (!_btnMaskView) {
        UIImage *image0 = [UIImage imageNamed:@"guideguanggan"];
        UIImage *image1 = [UIImage imageNamed:@"guideguanggan1"];
        UIImage *image2 = [UIImage imageNamed:@"guideguanggan2"];
        UIImage *image3 = [UIImage imageNamed:@"guideguanggan1"];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 110, 110)];
        imageView.animationImages = @[image0,image1,image2,image3];
        imageView.animationDuration = 1.0;
        imageView.animationRepeatCount = 0;
        [imageView startAnimating];
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onNextTap:)];
        [imageView addGestureRecognizer:tap];
        _btnMaskView = imageView;
    }
    return _btnMaskView;
}

- (UIImageView *)arrwoView {
    if (!_arrwoView) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"guideqiehuan"]];
        _arrwoView = imageView;
    }
    return _arrwoView;
}


- (UIView *)topMaskView {
    if (!_topMaskView) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _topMaskView = view;
    }
    return _topMaskView;
}

- (UIView *)bottomMaskView {
    if (!_bottomMaskView) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _bottomMaskView = view;
    }
    return _bottomMaskView;
}

- (UIView *)leftMaskView {
    if (!_leftMaskView) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _leftMaskView = view;
    }
    return _leftMaskView;
}

- (UIView *)rightMaskView {
    if (!_rightMaskView) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _rightMaskView = view;
    }
    return _rightMaskView;
}

@end
