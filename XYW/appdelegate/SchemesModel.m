//
//  SchemesModel.m
//  ZuoYou
//
//  Created by xueyongwei on 16/8/17.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "SchemesModel.h"

@implementation SchemesModel
+(NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"pkID":@"id",
             };
}
@end
