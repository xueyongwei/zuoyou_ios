//
//  UserInfoSetter.h
//  ZuoYou
//
//  Created by xueyongwei on 16/10/31.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MyselfInfoModel.h"
#import "UserInfoModel.h"

typedef void(^RefreshMyselfInfoFinishedBlock) (void);
typedef void(^RefreshMyselfInfoCompleteBlock) (MyselfInfoModel *my);
typedef void(^RequestUserInfoComplete) (UserInfoModel *user);

@class MyselfInfoModel;

/**
 *  用户信息设置器
 */

@interface UserInfoManager : NSObject

+(void)requestUserInfoWithID:(NSInteger)userId finish:(RequestUserInfoComplete)complete;
/**
 设置用户信息，corverImageV为大于头像imageV的覆盖imageV

 @param nameLbl 用户名label
 @param imgView 用户头像imageView
 @param coreverImgV 覆盖头像上的imageView
 @param userId 用户ID
 */
+(void)setNameLabel:(UILabel *)nameLbl headImageV:(UIImageView *)imgView corverImageV:(UIImageView *)coreverImgV with:(NSNumber *) userId;
+(void)setNameLabel:(UILabel *)nameLbl headImageV:(UIImageView *)imgView memberRoul:(BOOL)memberRoul with:(NSNumber *) userId;
/**
 设置用户信息，roleIcon是小V图标

 @param nameLbl 用户名label
 @param imgView 用户头像imageView
 @param roleIcon V的imageView
 @param userId 用户的ID
 */
+(void)setNameLabel:(UILabel *)nameLbl headImageV:(UIImageView *)imgView roleIcon:(UIImageView *)roleIcon with:(NSNumber *) userId;


//这个userid是否是我自己
+(BOOL)isMeOfID:(NSInteger)userId;
//保存我的信息到本地
+(void)saveMyselfInfo:(NSDictionary *)dic;
//同步个人信息
+(void)synchronizeMyselfInfoModel:(MyselfInfoModel *)model;
//读取本地我的信息
+(MyselfInfoModel *)mySelfInfoModel;

//退出时清理我的信息，
+(void)cleanMyselfInfo;

//有本地已登陆用户
+(BOOL)haveLogined;
//刷新我的信息
+(void)refreshMyselfInfoFinished:(RefreshMyselfInfoFinishedBlock)block;
@end
