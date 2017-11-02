//
//  MessageHelper.h
//  ZuoYou
//
//  Created by xueyognwei on 2017/2/21.
//  Copyright © 2017年 xueyongwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShouYeViewController.h"
#import "PersonalViewController.h"
#import "XiaoxiViewController.h"

@interface sessionListModel : NSObject
@property (nonatomic,assign) NSInteger showUnreadCount;
@property (nonatomic,assign) NSInteger totalUnreadCount;
@property (nonatomic,strong) NSMutableArray *sessionList;
@end


@interface MessageHelper : NSObject
@property (nonatomic,weak)ShouYeViewController *homepage;
@property (nonatomic,weak)PersonalViewController *personalpage;
@property (nonatomic,weak)XiaoxiViewController *messagepage;
@property (nonatomic,weak)XiaoxiSessionModel *currentSessionPoint;
+(MessageHelper *)shareInstance;
-(void)refreshUnReadCount;
@end
