//
//  WelcomeView.h
//  XYW
//
//  Created by xueyongwei on 16/8/29.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WelcomeView : UIView<UIScrollViewDelegate>

-(void)showStartClick:(void(^)(void))finishBlock;
@end
