//
//  BaseViewController.h
//  HDJ
//
//  Created by xueyongwei on 16/6/7.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TalkingData.h"
#import "MotherViewController.h"

@interface BaseViewController :MotherViewController
@property (nonatomic,strong)NSMutableDictionary *userDataDic;
//-(void)saveUsers:(NSString *)userIds;
//-(void)setNameLabel:(UILabel *)nameLbl headImageV:(UIImageView *)imgView with:(NSInteger) userID;
-(void)customNavi;
//-(void)downLoadCacheImg:(NSString *)imgUrl;
//-(BOOL)isMe:(NSInteger)userId;
////当前用户的ID
//-(NSInteger )mySelfId;
////是否是我
//-(BOOL)isMeOfID:(NSInteger)userId;
@end
