//
//  ZYUserDefaultsManager.h
//  ZuoYou
//
//  Created by xueyongwei on 2016/11/30.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//
/*
 此处纪录和用户相关的本地存储
 */
#import <Foundation/Foundation.h>
@interface ZYLanchADModel : NSObject
@property (nonatomic,copy)NSString *linkUrl;
@property (nonatomic,copy)NSString *imageUrl;
-(void)save;
+(void)clear;
@end
@interface ZYEnvironmentModel: NSObject
@property (nonatomic,assign)BOOL isEnvironment;//是否是生产环境

@end


@interface ZYUserDefaultsManager : NSObject
+(ZYLanchADModel *)zyLabchAD;
+(ZYEnvironmentModel *)zyEnvironment;
+(BOOL)isCareStarUser;//是否已经关注了推荐用户
+(void)setHaveCaredStarUser;//设置已经关注了推荐用户
//@property (nonatomic,strong)ZYLanchADModel *;
@end
