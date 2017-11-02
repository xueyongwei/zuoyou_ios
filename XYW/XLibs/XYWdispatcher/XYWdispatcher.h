//
//  XYWdispatcher.h
//  roter
//
//  Created by xueyongwei on 16/11/14.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  在路由表中配置host与viewController的对应关系
 */
@interface XYWdispatcher : NSObject
+(BOOL)HandleOpenURL:(NSURL *)url withScheme:(NSString *)scheme;
//适合推送来的，有host和query
+(void)jumpToHost:(NSString *)host param:(NSDictionary *)query;
@end
