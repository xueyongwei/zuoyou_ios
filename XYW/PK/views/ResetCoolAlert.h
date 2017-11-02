//
//  ResetCoolAlert.h
//  ZuoYou
//
//  Created by xueyongwei on 2016/11/28.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResetCoolAlert : UIView

-(void)showWithTime:(NSInteger)sec praiseRestCost:(NSNumber *)count  showIn:(UIView *)superView tips:(NSString *)tips okClick:(void (^)(void))okBlock;
//-(id)initWithTitle:(NSAttributedString *)title Content:(NSAttributedString *)content;
//-(void)show;
-(void)showIn:(UIView *)superView;
-(void)dismiss;
-(void)canUse:(BOOL)can;
@end
