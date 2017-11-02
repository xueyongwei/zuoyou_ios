//
//  ChatPersonalViewController.h
//  ZuoYou
//
//  Created by xueyognwei on 17/2/8.
//  Copyright © 2017年 xueyongwei. All rights reserved.
//

#import "ZYViewController.h"
#import "XiaoxiSessionModel.h"
@protocol ChatPersonalViewControllerDelegate <NSObject>
-(void)removeSeessionModel:(XiaoxiSessionModel *)sessionModel;
-(void)topSessionModel:(XiaoxiSessionModel *)sessionModel;
@end
@interface ChatPersonalViewController : ZYViewController
@property (nonatomic,weak)id <ChatPersonalViewControllerDelegate> delegate;
@property (nonatomic,assign)NSInteger mid;
@property (nonatomic,copy)NSString *userName;
@property (nonatomic,copy)NSString *iconUrl;
@property (nonatomic,assign)BOOL backWhenGoToHomePage;
@property (nonatomic,copy)NSString *messageSessionKey;
@property (nonatomic,strong) XiaoxiSessionModel *sessionModel;
@end
