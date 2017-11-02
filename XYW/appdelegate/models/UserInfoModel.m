//
//  MyInfoModel.m
//  ZuoYou
//
//  Created by xueyongwei on 16/10/28.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "UserInfoModel.h"

@implementation UserInfoModel

+(NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"mid":@"id",
             };
}
-(UIImage *)memberRoleIcon
{
    switch (_memberRoles) {
        case 6:{
            return [UIImage imageNamed:@"userProfileRolesIconV"];
        }
            break;
        case 16:{
            return [UIImage imageNamed:@"userProfileRolesIcon1V"];
        }
            break;
        default:
        {
            return nil;
        }
            break;
    }
}
-(NSString *)memberRolesDesc
{
    switch (_memberRoles) {
        case 6:{
            return @"认证PK主";
        }
            break;
        case 16:{
            return @"特级PK主";
        }
            break;
        default:
        {
            return nil;
        }
            break;
    }
}
@end
