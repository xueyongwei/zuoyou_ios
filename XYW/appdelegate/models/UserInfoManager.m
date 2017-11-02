//
//  UserInfoSetter.m
//  ZuoYou
//
//  Created by xueyongwei on 16/10/31.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "UserInfoManager.h"



static NSString *const kUserInfoKey = @"UserInfoUserDefaultDictinary";
static NSString *const kMyselfInfoKey = @"MyselfInfoUserDefaultData";
@implementation UserInfoManager
#pragma mark ---😊别人的信息
/**
 设置用户信息，roleIcon是小V图标
 
 @param nameLbl 用户名label
 @param imgView 用户头像imageView
 @param roleIcon V的imageView
 @param userId 用户的ID
 */
+(void)setNameLabel:(UILabel *)nameLbl headImageV:(UIImageView *)imgView roleIcon:(UIImageView *)roleIcon with:(NSNumber *) userId
{
    if (!userId) {
        return;
    }
    dispatch_queue_t userSetterQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(userSetterQueue, ^{
        imgView.tag = userId.integerValue;
        nameLbl.tag = userId.integerValue;
        __weak UIImageView *wkImgV = imgView;
        __weak UILabel *wkLbl = nameLbl;
        __weak UIImageView *wkroleIcon = roleIcon;
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",HeadUrl,@"/users/info"];
        NSDictionary *param = @{@"ids":[NSString stringWithFormat:@"%@",userId]};
        
        [XYWhttpManager XYWCachePost:urlStr parameters:param refresh:NO sucess:^(id result) {
            if ([result isKindOfClass:[NSArray class]]) {
                NSDictionary *dic = ((NSArray *)result).firstObject;
                if (!dic) {
                    DbLog(@"%@",[NSString stringWithFormat:@"用户%@数据有误！",userId]);
                    return ;
                }else{
                    UserInfoModel *userInfo = [UserInfoModel mj_objectWithKeyValues:dic];
                    if (userInfo.mid == wkLbl.tag || userInfo.mid == wkImgV.tag) {//如果当前label的tag还是请求的那个才设置界面
                        dispatch_async(dispatch_get_main_queue(), ^{//主线程更新UI
                            if (wkImgV) {//如果有头像的imageView
                                [wkImgV sd_setImageWithURL:[NSURL URLWithString:userInfo.avatar] placeholderImage:[UIImage imageNamed:@"1"]];
                                //设置头像标识
                                wkroleIcon.hidden = !userInfo.memberRoleIcon;
                            }
                            wkLbl?wkLbl.text = userInfo.name:nil;
                        });
                    }else{
                        DbLog(@"网络返回的ID%ld 要现实的ID%ld",(long)userInfo.mid,(long)wkLbl.tag);
                    }
                }
            }
        } failure:^(NSError *error) {
            
        }];
    });
}
+(void)requestUserInfoWithID:(NSInteger)userId finish:(RequestUserInfoComplete)complete{
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",HeadUrl,@"/users/info"];
    if (userId<=0) {
        return;
    }
    NSDictionary *param = @{@"ids":@(userId)};
    [XYWhttpManager XYWCachePost:urlStr parameters:param refresh:NO sucess:^(id result) {
        if ([result isKindOfClass:[NSArray class]]) {
            NSDictionary *dic = ((NSArray *)result).firstObject;
            if (!dic) {
                DbLog(@"%@",[NSString stringWithFormat:@"用户%@数据有误！",@(userId)]);
                return ;
            }else{
                UserInfoModel *userInfo = [UserInfoModel mj_objectWithKeyValues:dic];
                complete(userInfo);
            }
        }
    } failure:^(NSError *error) {
        complete(nil);
    }];
}
/**
 设置用户信息，corverImageV为大于头像imageV的覆盖imageV
 
 @param nameLbl 用户名label
 @param imgView 用户头像imageView
 @param coreverImgV 覆盖头像上的imageView
 @param userId 用户ID
 */
+(void)setNameLabel:(UILabel *)nameLbl headImageV:(UIImageView *)imgView corverImageV:(UIImageView *)coreverImgV with:(NSNumber *) userId
{
    if (!userId) {
        return;
    }
    dispatch_queue_t userSetterQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(userSetterQueue, ^{
        imgView.tag = userId.integerValue;
        nameLbl.tag = userId.integerValue;
        __weak UIImageView *wkImgV = imgView;
        __weak UILabel *wkLbl = nameLbl;
        __weak UIImageView *wkCorver = coreverImgV;
        __weak typeof(self) wkSelf = self;
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",HeadUrl,@"/users/info"];
        NSDictionary *param = @{@"ids":[NSString stringWithFormat:@"%@",userId]};
        //        NSDictionary *param = @{@"ids":@"<null>"};
        MyselfInfoModel *my = [self mySelfInfoModel];
        if (my.mid.integerValue == userId.integerValue) {
            dispatch_async(dispatch_get_main_queue(), ^{//主线程更新UI
                if (imgView) {
                    [imgView sd_setImageWithURL:[NSURL URLWithString:my.avatar] placeholderImage:[UIImage imageNamed:@"1"]];
                    [self setMyRoleIcon:coreverImgV withModel:my];
                }
                if (nameLbl) {
                    nameLbl.text = my.name;
                }
                return ;
            });
            return ;
        }
        [XYWhttpManager XYWCachePost:urlStr parameters:param refresh:NO sucess:^(id result) {
            if ([result isKindOfClass:[NSArray class]]) {
                NSDictionary *dic = ((NSArray *)result).firstObject;
                if (!dic) {
                    DbLog(@"%@",[NSString stringWithFormat:@"用户%@数据有误！",userId]);
                    return ;
                }else{
                    UserInfoModel *userInfo = [UserInfoModel mj_objectWithKeyValues:dic];
                    if (userInfo.mid == wkLbl.tag || userInfo.mid == wkImgV.tag) {//如果当前label的tag还是请求的那个才设置界面
                        dispatch_async(dispatch_get_main_queue(), ^{//主线程更新UI
                            if (wkImgV) {//如果有头像的imageView
                                [wkImgV sd_setImageWithURL:[NSURL URLWithString:userInfo.avatar] placeholderImage:[UIImage imageNamed:@"1"]];
                                //设置头像标识
                                [wkSelf setMemberRoleIcon:wkCorver withModel:userInfo];
                            }
                            wkLbl?wkLbl.text = userInfo.name:nil;
                        });
                    }else{
                        DbLog(@"网络返回的ID%ld 要现实的ID%ld",(long)userInfo.mid,(long)wkLbl.tag);
                    }
                }
            }
        } failure:^(NSError *error) {
            
        }];
    });
}



/**
 设置用户的身份标识
 
 @param imageView 身份标识要加到这个view上的右下角
 @param model 用户的数据
 */
+(void)setMemberRoleIcon:(UIImageView *)imageView withModel:(UserInfoModel *)model
{
    
    UIImageView *roleIconView = imageView.subviews.firstObject;
    if (model.memberRoleIcon) {//用户有身份
        if (!roleIconView) {//没有身份标识得创建个
            roleIconView = [UIImageView new];
            CGFloat width = imageView.bounds.size.width;
            dispatch_async(dispatch_get_main_queue(), ^{
                roleIconView.frame = CGRectMake(width*0.7, width*0.7, width*0.3, width*0.3);
                [imageView addSubview:roleIconView];
                roleIconView.image = model.memberRoleIcon;
                roleIconView.hidden = NO;
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                roleIconView.image = model.memberRoleIcon;
                roleIconView.hidden = NO;
            });
        }
    }else{
        if (roleIconView) {
            dispatch_async(dispatch_get_main_queue(), ^{
                roleIconView.hidden = YES;
            });
        }
    }
}
+(void)setMyRoleIcon:(UIImageView *)imageView withModel:(MyselfInfoModel *)model
{
    UIImageView *roleIconView = imageView.subviews.firstObject;
    if (model.memberRoleIcon) {//用户有身份
        if (!roleIconView) {//没有身份标识得创建个
            roleIconView = [UIImageView new];
            CGFloat width = imageView.bounds.size.width;
            roleIconView.frame = CGRectMake(width*0.7, width*0.7, width*0.3, width*0.3);
            [imageView addSubview:roleIconView];
        }
        roleIconView.image = model.memberRoleIcon;
        roleIconView.hidden = NO;
    }else{
        if (roleIconView) {
            roleIconView.hidden = YES;
        }
    }
}
/**
 设置用户信息，corverImageV为大于头像imageV的覆盖imageV
 
 @param nameLbl 用户名label
 @param imgView 用户头像imageView
 @param coreverImgV 覆盖头像上的imageView
 @param userId 用户ID
 */
+(void)setNameLabel:(UILabel *)nameLbl headImageV:(UIImageView *)imgView memberRoul:(BOOL)memberRoul with:(NSNumber *) userId
{
    if (!userId) {
        return;
    }
    
    imgView.tag = userId.integerValue;
    nameLbl.tag = userId.integerValue;
    __weak UIImageView *wkImgV = imgView;
    __weak UILabel *wkLbl = nameLbl;
    
    __weak typeof(self) wkSelf = self;
    
    MyselfInfoModel *my = [self mySelfInfoModel];
    if (my.mid.integerValue == userId.integerValue) {//我自己
        if (wkImgV) {
            [self setMyRoleIcon:wkImgV withModel:my];
            [wkImgV sd_setImageWithURL:[NSURL URLWithString:my.avatar] placeholderImage:[UIImage imageNamed:@"1"] options:SDWebImageAvoidAutoSetImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                UIImage * iconimage= image?[image roundImage]:[[UIImage imageNamed:@"1"] roundImage];
                dispatch_async(dispatch_get_main_queue(), ^{//主线程更新UI
                    wkImgV.image = iconimage;
                    if (nameLbl) {
                        nameLbl.text = my.name;
                    }
                });
            }];
        }
        return ;
    }else{
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",HeadUrl,@"/users/info"];
        NSDictionary *param = @{@"ids":[NSString stringWithFormat:@"%@",userId]};
        [XYWhttpManager XYWCachePost:urlStr parameters:param refresh:NO sucess:^(id result) {
            if ([result isKindOfClass:[NSArray class]]) {
                NSDictionary *dic = ((NSArray *)result).firstObject;
                if (!dic) {
                    DbLog(@"%@",[NSString stringWithFormat:@"用户%@数据有误！",userId]);
                    return ;
                }else{
                    //返回的用户信息
                    UserInfoModel *userInfo = [UserInfoModel mj_objectWithKeyValues:dic];
                    if (userInfo.mid == wkLbl.tag || userInfo.mid == wkImgV.tag) {//如果当前label的tag还是请求的那个才设置界面
                        if (wkImgV) {//如果有头像的imageView
                            [wkSelf setMemberRoleIcon:wkImgV withModel:userInfo];
                            [wkImgV sd_setImageWithURL:[NSURL URLWithString:userInfo.avatar] placeholderImage:[UIImage imageNamed:@"1"] options:SDWebImageAvoidAutoSetImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                UIImage * iconimage= image?[image roundImage]:[[UIImage imageNamed:@"1"] roundImage];
                                dispatch_async(dispatch_get_main_queue(), ^{//主线程更新UI
                                    wkImgV.image = iconimage;
                                    if (wkLbl) {
                                        wkLbl.text = userInfo.name;
                                    }
                                });
                            }];
                        }
                    }else{
                        DbLog(@"网络返回的ID%ld 要现实的ID%ld",(long)userInfo.mid,(long)wkLbl.tag);
                    }
                }
            }
        } failure:^(NSError *error) {
            
        }];
    }
    
}


#pragma mark ---😊关于我自己的信息
// 是否是我自己
+(BOOL)isMeOfID:(NSInteger)userId
{
    if ([self mySelfInfoModel].mid.integerValue == userId) {
        return YES;
    }
    return NO;
}
//保存我的信息
+(void)saveMyselfInfo:(NSDictionary *)dic
{
    MyselfInfoModel *infoModel = [MyselfInfoModel mj_objectWithKeyValues:dic] ;
    [self saveMyModelToUsf:infoModel];
}
//把model保存到Usf
+(void)saveMyModelToUsf:(MyselfInfoModel *)model
{
    //把model转为data以便本地存储
    NSData *userInfoData = [NSKeyedArchiver archivedDataWithRootObject:model];
    //保存model，再把dic存到本地
    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
    [usf setObject:userInfoData forKey:kMyselfInfoKey];
    //同步
    [usf synchronize];
}
//把新model保存到usf
+(void)synchronizeMyselfInfoModel:(MyselfInfoModel *)model
{
    //把model转为data以便本地存储
    NSData *userInfoData = [NSKeyedArchiver archivedDataWithRootObject:model];
    //保存model，再把dic存到本地
    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
    [usf setObject:userInfoData forKey:kMyselfInfoKey];
    //同步
    [usf synchronize];
}
//获取我的信息
+(MyselfInfoModel *)mySelfInfoModel
{
    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
    NSData *userInfoData = [usf objectForKey:kMyselfInfoKey];
    if (!userInfoData) {
        return nil;
    }
    MyselfInfoModel *infoModel = [NSKeyedUnarchiver unarchiveObjectWithData:userInfoData];
    return infoModel;
}
//清理我的信息
+(void)cleanMyselfInfo
{
    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
    [usf removeObjectForKey:kMyselfInfoKey];
    [usf synchronize];
}
+(BOOL)haveLogined
{
    return [self mySelfInfoModel] && [self mySelfInfoModel].token.length>0;
}
//发起网络请求更新我的信息
+(void)refreshMyselfInfoFinished:(RefreshMyselfInfoFinishedBlock)block
{
    __weak typeof(self) wkSelf = self;
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@%@",HeadUrl,@"/users/info"] parameters:@{} inView:nil sucess:^(id result) {
        if (result) {
            DbLog(@"%@",result);
            NSDictionary *rsp = (NSDictionary*)result;
            if ([rsp objectForKey:@"errCode"]) {
                CoreSVPCenterMsg([rsp objectForKey:@"errMsg"]);
                DbLog(@"%@",[rsp objectForKey:@"errMsg"]);
            }else{
                [wkSelf refreshToNewInfo:rsp];
                block();
            }
        }
    } failure:^(NSError *error) {
        CoreSVPCenterMsg(error.localizedDescription);
        DbLog(@"%@",error.localizedDescription);
    }];
}
//发起网络请求更新我的信息，并返回最新信息
+(void)refreshMyselfInfoomplete:(RefreshMyselfInfoCompleteBlock)block
{
    __weak typeof(self) wkSelf = self;
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@%@",HeadUrl,@"/users/info"] parameters:@{} inView:nil sucess:^(id result) {
        if (result) {
            DbLog(@"%@",result);
            NSDictionary *rsp = (NSDictionary*)result;
            if ([rsp objectForKey:@"errCode"]) {
                CoreSVPCenterMsg([rsp objectForKey:@"errMsg"]);
                DbLog(@"%@",[rsp objectForKey:@"errMsg"]);
            }else{
                MyselfInfoModel *my = [wkSelf mySelfInfoModel];
                NSArray *keys = rsp.allKeys;
                for (NSString *key in keys) {
                    if ([key isEqualToString:@"id"]) {
                        [my setValue:[rsp objectForKey:key] forKey:@"mid"];
                        continue;
                    }
                    SEL proty = NSSelectorFromString(key);
                    DbLog(@"%@",key);
                    if ([MyselfInfoModel instancesRespondToSelector:proty]) {
                        [my setValue:[rsp objectForKey:key] forKey:key];
                        
                    }else{
                        DbLog(@"%@",key);
                    }
                }
                [wkSelf saveMyModelToUsf:my];
                block(my);
            }
        }
    } failure:^(NSError *error) {
        CoreSVPCenterMsg(error.localizedDescription);
        DbLog(@"%@",error.localizedDescription);
    }];
}
//更新字典里的最新内容，字典里可能不包含所有字段，因此只更新你给的新字段
+(void)refreshToNewInfo:(NSDictionary *)newInfo
{
    MyselfInfoModel *my = [self mySelfInfoModel];
    NSArray *keys = newInfo.allKeys;
    for (NSString *key in keys) {
        if ([key isEqualToString:@"id"]) {
            [my setValue:[newInfo objectForKey:key] forKey:@"mid"];
            continue;
        }
        SEL proty = NSSelectorFromString(key);
        DbLog(@"%@",key);
        if ([MyselfInfoModel instancesRespondToSelector:proty]) {
            [my setValue:[newInfo objectForKey:key] forKey:key];
            
        }else{
            DbLog(@"%@",key);
        }
    }
    [self saveMyModelToUsf:my];
}
@end
