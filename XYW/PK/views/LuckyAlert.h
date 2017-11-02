//
//  LuckyAlert.h
//  ZuoYou
//
//  Created by xueyognwei on 2017/2/28.
//  Copyright © 2017年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LuckyAlert : UIView
-(void)showIn:(UIView *)superView tips:(NSString *)tips okClick:(void (^)(void))okBlock;
@end
