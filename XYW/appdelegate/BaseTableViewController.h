//
//  BaseTableViewController.h
//  ZuoYou
//
//  Created by xueyongwei on 16/9/13.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Google/Analytics.h>
@interface BaseTableViewController : UITableViewController
@property (nonatomic,strong)NSMutableDictionary *userDataDic;
-(void)customNavi;
//-(void)saveUsers:(NSString *)userIds;
//-(void)setNameLabel:(UILabel *)nameLbl headImageV:(UIImageView *)imgView with:(NSInteger) userID;

////当前用户的ID
//-(NSInteger )mySelfId;
////是否是我
//-(BOOL)isMeOfID:(NSInteger)userId;
@end
