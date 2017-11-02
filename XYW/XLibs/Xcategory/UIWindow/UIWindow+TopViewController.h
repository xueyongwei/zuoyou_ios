//
//  UIWindow+TopViewController.h
//  ZuoYou
//
//  Created by xueyognwei on 16/12/21.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWindow (TopViewController)

/**
 获取window的最上层控制器（当前显示的控制器）

 @return 控制器
 */
+ (UIViewController *)getTopViewController;


/**
 获取rootViewController的某个永不释放的控制器

 @param index 第几个
 @return 控制器
 */
+(UIViewController *)getViewControllerInRootViewControllerWithIndex:(NSInteger)index;

@end
