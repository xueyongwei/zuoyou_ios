//
//  chognzhiListModel.m
//  HDJ
//
//  Created by xueyongwei on 16/8/8.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "chognzhiListModel.h"

@implementation chognzhiListModel
+(NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"productID":@"id",
             };
}
@end
