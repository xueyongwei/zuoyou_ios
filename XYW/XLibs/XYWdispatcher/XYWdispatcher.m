//
//  XYWdispatcher.m
//  roter
//
//  Created by xueyongwei on 16/11/14.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "XYWdispatcher.h"
#import <UIKit/UIKit.h>
@interface XYWdispatcher()
@property (nonatomic,copy)NSString *schemeHost;
@property (nonatomic,strong) NSMutableDictionary *paramDic;
@end
@implementation XYWdispatcher
-(id)initWithHost:(NSString *)host
{
    if (self = [super init] ) {
        self.schemeHost = host;
    };
    return self;
}
+(BOOL)HandleOpenURL:(NSURL *)url withScheme:(NSString *)scheme
{
    NSLog(@"%@",url);
    [[[self alloc]initWithHost:url.host] handleSchemes:url];
    return [url.scheme isEqualToString:scheme];
}
-(void)handleSchemes:(NSURL *)url
{
    NSString *host = [url host];
    NSArray *itms = [[url query] componentsSeparatedByString:@"&"];
    [self jumpVC:host withquerys:itms];
}
-(void)jumpVC:(NSString *)host withquerys:(NSArray *)querys
{
    NSString *vcClz = [self classWithHost];
    if (!vcClz) {
        return;
    }
    id myObj = [[NSClassFromString(vcClz) alloc] init];
    if (!myObj) {
        UIAlertView *alv = [[UIAlertView alloc]initWithTitle:@"需要升级才能完成操作" message:nil delegate:nil cancelButtonTitle:@"好的" otherButtonTitles: nil];
        [alv show];
        return;
    }
    
    //    NSAssert(myObj, @"没有这个%@类",vcClz);
    if (myObj) {
        for (NSString *itm in querys) {
            NSArray *keyvalues = [itm componentsSeparatedByString:@"="];
            NSString *VCkey = [self paramWithQuery:keyvalues.firstObject];
            if ([self getVariableWithClass:[myObj class] varName: VCkey]) {
                [myObj setValue:keyvalues.lastObject forKey:VCkey];
            }else{
                UIAlertView *alv = [[UIAlertView alloc]initWithTitle:@"需要升级才能完成操作" message:nil delegate:nil cancelButtonTitle:@"好的" otherButtonTitles: nil];
                [alv show];
            }
            
        }
    }
    UIViewController *currentVC = [self getCurrentVC];
    if (currentVC.navigationController) {
        currentVC.hidesBottomBarWhenPushed = YES;
        [currentVC.navigationController pushViewController:myObj animated:YES];
        currentVC.hidesBottomBarWhenPushed=NO;
    }else{
        [[self getCurrentVC] presentViewController:myObj animated:YES completion:nil];
    }
}
+(void)jumpToHost:(NSString *)host param:(NSDictionary *)query
{
    NSDictionary *hostObject = [self objectWithHost:host];
    NSString *vcClz = hostObject[@"className"];
    if (!vcClz) {
        return;
    }
    UIViewController *myObj = [[NSClassFromString(vcClz) alloc] init];
    if (!myObj) {
        UIAlertView *alv = [[UIAlertView alloc]initWithTitle:@"需要升级才能完成操作" message:nil delegate:nil cancelButtonTitle:@"好的" otherButtonTitles: nil];
        [alv show];
        return;
    }
    NSDictionary *paramDic = hostObject[@"param"];
    for (NSString *key in query.allKeys) {
        if (paramDic[key]) {
            [myObj setValue:query[key] forKey:paramDic[key]];
        }else{
            UIAlertView *alv = [[UIAlertView alloc]initWithTitle:@"需要升级才能完成操作" message:nil delegate:nil cancelButtonTitle:@"好的" otherButtonTitles: nil];
            [alv show];
            return;
        }
    }
    UIViewController *currentVC = [self valueableViewController];
    if (currentVC.navigationController) {
        myObj.hidesBottomBarWhenPushed = YES;
        [currentVC.navigationController pushViewController:myObj animated:YES];
         myObj.hidesBottomBarWhenPushed=NO;
    }else{
        [[self valueableViewController] presentViewController:myObj animated:YES completion:nil];
    }
    
}
+ (UIViewController *)valueableViewController{
    
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    //app默认windowLevel是UIWindowLevelNormal，如果不是，找到UIWindowLevelNormal的
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
    id  nextResponder = nil;
    UIViewController *appRootVC=window.rootViewController;
    //    如果是present上来的appRootVC.presentedViewController 不为nil
    if (appRootVC.presentedViewController) {
        nextResponder = appRootVC.presentedViewController;
    }else{
        UIView *frontView = [[window subviews] objectAtIndex:0];
        nextResponder = [frontView nextResponder]; //  这方法下面有详解
    }
    
    if ([nextResponder isKindOfClass:[UITabBarController class]]){
        UITabBarController * tabbar = (UITabBarController *)nextResponder;
        UINavigationController * nav = (UINavigationController *)tabbar.viewControllers[tabbar.selectedIndex];
        //        UINavigationController * nav = tabbar.selectedViewController ; 上下两种写法都行
        result=nav.childViewControllers.lastObject;
        
    }else if ([nextResponder isKindOfClass:[UINavigationController class]]){
        UIViewController * nav = (UIViewController *)nextResponder;
        result = nav.childViewControllers.lastObject;
    }else{
        result = nextResponder;
    }
    
    return result;
}
- (UIViewController *)getCurrentVC{
    
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    //app默认windowLevel是UIWindowLevelNormal，如果不是，找到UIWindowLevelNormal的
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
    id  nextResponder = nil;
    UIViewController *appRootVC=window.rootViewController;
    //    如果是present上来的appRootVC.presentedViewController 不为nil
    if (appRootVC.presentedViewController) {
        nextResponder = appRootVC.presentedViewController;
    }else{
        UIView *frontView = [[window subviews] objectAtIndex:0];
        nextResponder = [frontView nextResponder]; //  这方法下面有详解
    }
    
    if ([nextResponder isKindOfClass:[UITabBarController class]]){
        UITabBarController * tabbar = (UITabBarController *)nextResponder;
        UINavigationController * nav = (UINavigationController *)tabbar.viewControllers[tabbar.selectedIndex];
        //        UINavigationController * nav = tabbar.selectedViewController ; 上下两种写法都行
        result=nav.childViewControllers.lastObject;
        
    }else if ([nextResponder isKindOfClass:[UINavigationController class]]){
        UIViewController * nav = (UIViewController *)nextResponder;
        result = nav.childViewControllers.lastObject;
    }else{
        result = nextResponder;
    }
    
    return result;
}

- (BOOL)getVariableWithClass:(Class) myClass varName:(NSString *)name{
    unsigned int outCount, i;
    Ivar *ivars = class_copyIvarList(myClass, &outCount);
    for (i = 0; i < outCount; i++) {
        Ivar property = ivars[i];
        NSString *keyName = [NSString stringWithCString:ivar_getName(property) encoding:NSUTF8StringEncoding];
        keyName = [keyName stringByReplacingOccurrencesOfString:@"_" withString:@""];
        if ([keyName isEqualToString:name]) {
            return YES;
        }
    }
    return NO;
}
/**
 *  返回VC的各参数名
 *
 */
-(NSString *)paramWithQuery:(NSString *)query
{
    if (!self.paramDic) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"XYWdispatcherRouter" ofType:@"plist"];
        NSMutableDictionary *routerData = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        NSDictionary *vcClz = [routerData objectForKey:self.schemeHost];
        NSDictionary *param = [vcClz objectForKey:@"param"];
        self.paramDic = [NSMutableDictionary dictionaryWithDictionary:param];
    }
    return [self.paramDic objectForKey:query];
}
/**
 *  返回VC的类名
 *
 */
-(NSString *)classWithHost
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"XYWdispatcherRouter" ofType:@"plist"];
    
    NSMutableDictionary *routerData = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    if ([[routerData objectForKey:self.schemeHost] isKindOfClass:[NSString class]]) {
        return nil;
    }
    NSDictionary *vcClz = [routerData objectForKey:self.schemeHost];
    return vcClz[@"className"];
}
+(NSDictionary *)objectWithHost:(NSString *)host
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"XYWdispatcherRouter" ofType:@"plist"];
    
    NSMutableDictionary *routerData = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    if ([[routerData objectForKey:host] isKindOfClass:[NSDictionary class]]) {
        return [routerData objectForKey:host];
    }
    return nil;
}
@end
