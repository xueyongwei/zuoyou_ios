//
//  MessageHelper.m
//  ZuoYou
//
//  Created by xueyognwei on 2017/2/21.
//  Copyright © 2017年 xueyongwei. All rights reserved.
//

#import "MessageHelper.h"

@implementation sessionListModel
-(NSMutableArray *)sessionList
{
    if (!_sessionList) {
        _sessionList = [NSMutableArray new];
    }
    return _sessionList;
}
@end

#pragma mark -unreadMessageInfo
@interface UnreadMessageInfo : NSObject
@property (nonatomic,assign) NSInteger showUnreadCount;
@property (nonatomic,assign) NSInteger totalUnreadCount;
@end
@implementation UnreadMessageInfo

@end
#pragma mark -MessageHelper
@interface MessageHelper()
@property (nonatomic,strong)UnreadMessageInfo *unreadMessageInfo;
@property (nonatomic,assign)NSInteger currenPage;
@end

@implementation MessageHelper
+(MessageHelper *)shareInstance
{
    static MessageHelper *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
        [instance listenMessageNoti];
    });
    return instance;
}

-(void)listenMessageNoti{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(systemsessionlistHandle:) name:@"systemsessionlist" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(systemsessionlistHandle:) name:@"privatedialog" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshUnReadCount) name:UIApplicationDidBecomeActiveNotification object:nil];
}
#pragma mark ---通知的handle
-(void)systemsessionlistHandle:(NSNotification *)noti
{
    DbLog(@"%@",noti.userInfo);
    if ([noti.name isEqualToString:@"systemsessionlist"]){//消息列表的数据
//        WSmessageModel *model = (WSmessageModel*)noti.userInfo[@"model"];
//        if (![model.body isKindOfClass:[NSArray class]]) {
//            DbLog(@"is not the class we want(nsarray)!");
//        }
//
//        NSArray *bodys = (NSArray *)model.body;
//        for (NSDictionary *dic in bodys) {
//            XiaoxiSessionModel *model = [XiaoxiSessionModel mj_objectWithKeyValues:dic];
//            self
//        }

        [self refreshUnReadCount];
    }else if([noti.name isEqualToString:@"privatedialog"]){//收到新的消息
        [self refreshUnReadCount];
    }
}

-(void)refreshUnReadCount{
//
    __weak typeof(self) wkSelf = self;
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@%@",HeadUrl,@"/social/unreadMessageInfo"] parameters:nil inView:nil sucess:^(id result) {
        DbLog(@"%@",result);
        UnreadMessageInfo *info = [UnreadMessageInfo mj_objectWithKeyValues:result];
        wkSelf.unreadMessageInfo = info;
        [wkSelf customUnreadCountView];
    } failure:^(NSError *error) {
        
    }];
}

/**
 在主线程定制未读数量界面
 */
-(void)customUnreadCountView{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self changeMessageViewState];
    });
}

/**
 更改需要变化的界面
 */
-(void)changeMessageViewState{
    if (self.homepage) {//首页
        [self.homepage setTabbarUnderCount:self.unreadMessageInfo.totalUnreadCount];
    }
    if (self.personalpage) {//个人页面
        [self.personalpage setMessageItemUnreadCount:self.unreadMessageInfo.showUnreadCount totalCount:self.unreadMessageInfo.totalUnreadCount];
    }
    if (self.messagepage) {//聊天页面
//        [self.messagepage reloadList];
    }
}
@end
