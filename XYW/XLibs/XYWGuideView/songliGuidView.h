//
//  songliGuid.h
//  ZuoYou
//
//  Created by xueyongwei on 16/8/26.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Layout.h"

@protocol songliGuidViewDelegate <NSObject>

- (void)songliGuidNext;

@end
@interface songliGuidView : UIView
@property (nonatomic, weak) id<songliGuidViewDelegate> delegate;
@property (nonatomic, strong) UIImageView *btnMaskView;
@property (nonatomic, strong) UIImageView *arrwoView;

- (void)showInView:(UIView *)view maskBtn:(UIButton *)btn;
@end
