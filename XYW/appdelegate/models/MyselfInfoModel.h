//
//  MyselfInfoModel.h
//  ZuoYou
//
//  Created by xueyongwei on 2016/11/24.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyselfInfoModel : NSObject
#warning 添加属性的话需要在.m中添加coding方法
@property (nonatomic,strong) NSNumber *mid;//用户ID
@property (nonatomic,copy) NSString *name;//昵称
@property (nonatomic,copy) NSString *avatar;//头像
@property (nonatomic,strong) NSNumber *gender;//性别
@property (nonatomic,copy) NSString *signature;//个性签名
@property (nonatomic,strong) NSNumber *balance;
@property (nonatomic,strong) NSDictionary *permissionDeny;//被禁止的东西
@property (nonatomic,copy) NSString *token;//token
@property (nonatomic,copy) NSString *refreshedToken;//刷新token后得到的最新token
@property (nonatomic,copy) NSString *tokenExpireAt;//过期时间
@property (nonatomic,strong) NSNumber *memberRoles;//用户角色
@property (nonatomic,strong) UIImage *memberRoleIcon;//角色的标志图
@property (nonatomic,copy) NSString *createdDate;
@property (nonatomic,copy)NSString *memberRolesDesc;
@property (nonatomic,strong) NSNumber *profitBalance;
@end
