//
//  ZYViewController.h
//  ZuoYou
//
//  Created by xueyongwei on 16/10/26.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfoModel.h"
@interface ZYViewController : UIViewController
////根据用户ID设置用户名和昵称
//-(void)setNameLabel:(UILabel *)nameLbl headImageV:(UIImageView *)imgView with:(NSInteger) userID;
////当前用户的ID
//-(NSInteger )mySelfId;
////是否是我
//-(BOOL)isMeOfID:(NSInteger)userId;
////保存用户数据
//-(void)saveUserInfo:(UserInfoModel *)infoModel withID:(NSString *)userID;
////读取用户数据
//-(UserInfoModel *)userInfoWithID:(NSString *)userID;
-(void)customNavi;
@end
