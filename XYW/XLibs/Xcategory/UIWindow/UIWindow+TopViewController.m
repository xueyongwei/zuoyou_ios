//
//  UIWindow+TopViewController.m
//  ZuoYou
//
//  Created by xueyognwei on 16/12/21.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "UIWindow+TopViewController.h"

@implementation UIWindow (TopViewController)
/**
 获取window的最上层控制器（当前显示的控制器）
 
 @return 控制器
 */
+ (UIViewController *)getTopViewController
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}
/**
 获取rootViewController的某个永不释放的控制器
 
 @param index 第几个
 @return 控制器
 */
+(UIViewController *)getViewControllerInRootViewControllerWithIndex:(NSInteger)index
{
    //获取window的rootViewController
    UITabBarController *rotVC = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    //左右中，tabbarVC都是以navi为rootVC
    UINavigationController *navi = rotVC.childViewControllers[index];
    UIViewController *destinationVC = navi.childViewControllers.firstObject;
    return destinationVC;
}
@end
