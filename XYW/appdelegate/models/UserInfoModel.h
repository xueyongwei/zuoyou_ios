//
//  MyInfoModel.h
//  ZuoYou
//
//  Created by xueyongwei on 16/10/28.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface UserInfoModel : NSObject
@property (nonatomic,assign) NSInteger mid;//用户ID
@property (nonatomic,copy) NSString *name;//昵称
@property (nonatomic,copy) NSString *avatar;//头像
@property (nonatomic,assign) NSInteger gender;//性别
@property (nonatomic,copy) NSString *signature;//个性签名
@property (nonatomic,assign) NSInteger memberRoles;//用户角色
-(UIImage *)memberRoleIcon;//角色的标志图
-(NSString *)memberRolesDesc;//角色描述
//@property (nonatomic,strong) UIImage *memberRoleIcon;//角色的标志图

@end

