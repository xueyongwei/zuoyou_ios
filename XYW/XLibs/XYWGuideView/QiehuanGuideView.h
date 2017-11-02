//
//  GuideView.h
//  GuideDemo
//
//  Created by 李剑钊 on 15/7/23.
//  Copyright (c) 2015年 sunli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Layout.h"
//#import "UIImage+Mask.h"
@protocol QiehuanGuideViewDelegate <NSObject>

- (void)QiehuanGuideNext;

@end

@interface QiehuanGuideView : UIView
@property (nonatomic, weak) id<QiehuanGuideViewDelegate> delegate;
@property (nonatomic, strong) UIImageView *btnMaskView;
@property (nonatomic, strong) UIImageView *arrwoView;

- (void)showInView:(UIView *)view maskBtn:(UIButton *)btn;

@end
