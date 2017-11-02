//
//  RenWuListModel.m
//  HDJ
//
//  Created by xueyongwei on 16/8/8.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "RenWuListModel.h"

@implementation RenWuListModel
+(NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"renwuDescription":@"description",
             @"renwuID":@"id",
             };
}
@end
