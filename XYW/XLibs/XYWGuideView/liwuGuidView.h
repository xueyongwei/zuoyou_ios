//
//  liwuGuidView.h
//  GuideDemo
//
//  Created by xueyongwei on 16/8/25.
//  Copyright © 2016年 sunli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Layout.h"
@protocol liwuGuidViewViewDelegate <NSObject>

- (void)liwuGuidViewNext;

@end
@interface liwuGuidView : UIView
@property (nonatomic, weak) id<liwuGuidViewViewDelegate> delegate;
- (void)showInView:(UIView *)view maskBtn:(UIButton *)btn;
@end
